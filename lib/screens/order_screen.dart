import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onesync/navigation.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final List<Map<String, dynamic>> items = [];
  Map<String, int> cart = {}; // {productId: quantity}
  bool isLoading = true;

  // Currency formatter
  final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'fil', symbol: '₱');

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Menu').get();

      items.clear();

      querySnapshot.docs.forEach((doc) {
        items.add({
          'name': doc.get('name'),
          'price': doc.get('price'),
          'stock': doc.get('stock'),
          'inCart': false, // Add a flag to track if item is in cart
          'quantity': 0, // Add quantity for each item
        });
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  void _addToCart(int index) {
    setState(() {
      if (items[index]['stock'] > 0) {
        String productId = items[index]['name']; // Assuming name is unique ID
        items[index]['inCart'] = true;
        items[index]['quantity'] = 1;
        cart[productId] = 1;
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      String productId = items[index]['name'];
      items[index]['inCart'] = false;
      items[index]['quantity'] = 0;
      cart.remove(productId);
    });
  }

  void _incrementQuantity(int index) {
    setState(() {
      String productId = items[index]['name'];
      if (items[index]['stock'] > cart[productId]!) {
        cart[productId] = (cart[productId] ?? 0) + 1;
        items[index]['quantity'] = cart[productId]!;
      }
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      String productId = items[index]['name'];
      if (cart[productId]! > 0) {
        cart[productId] = (cart[productId] ?? 0) - 1;
        items[index]['quantity'] = cart[productId]!;
        if (cart[productId] == 0) {
          _removeFromCart(index);
        }
      }
    });
  }

  int _calculateTotal() {
    double total = 0.0;
    cart.forEach((key, value) {
      total += (items[items.indexWhere((item) => item['name'] == key)]['price']
              as int) *
          (value ?? 0).toInt();
    });
    return total.toInt();
  }

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Order'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to place this order?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _submitOrder(); // Call function to submit order
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OrderScreen(), // Navigate back to the same screen
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitOrder() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    // Fetch the last used transaction number from the database
    DocumentSnapshot lastTransactionDoc =
        await db.collection('Meta').doc('TransactionNumber').get();

    int lastTransactionNumber = lastTransactionDoc.exists
        ? lastTransactionDoc.get('number')
        : 0; // If no document exists, start with 0

    int nextTransactionNumber = lastTransactionNumber + 1;
    String transactionId = 'Transaction$nextTransactionNumber';

    Map<String, dynamic> orderData = {
      'date': Timestamp.fromDate(DateTime.now()), // Adjust for GMT+8
      'totalPrice': _calculateTotal(),
    };

    // Update the last used transaction number in the database
    await db.collection('Meta').doc('TransactionNumber').set({
      'number': nextTransactionNumber,
    });

    await db
        .collection('Transactions')
        .doc(transactionId)
        .set(orderData)
        .then((_) => print('Order successfully submitted!'))
        .catchError((error) => print('Failed to submit order: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2.0,
                          child: InkWell(
                            onTap: () {
                              if (!items[index]['inCart']) {
                                _addToCart(index);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    items[index]['name'],
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text('Stock: ${items[index]['stock']}'),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    '\₱${items[index]['price'].toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  const SizedBox(height: 8.0),
                                  if (items[index]['inCart'])
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              _decrementQuantity(index),
                                          icon: const Icon(Icons.remove_circle),
                                        ),
                                        Text(
                                          '${items[index]['quantity']}',
                                          style:
                                              const TextStyle(fontSize: 16.0),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              _incrementQuantity(index),
                                          icon: const Icon(Icons.add_circle),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 8.0),
                                  if (items[index]['inCart'])
                                    Text(
                                      'Total: ${_currencyFormatter.format(items[index]['price'] * items[index]['quantity'])}',
                                      style: const TextStyle(fontSize: 14.0),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey[200],
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ${_currencyFormatter.format(_calculateTotal())}',
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      ElevatedButton(
                        onPressed: _showConfirmationDialog,
                        child: const Text('Place Order'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Navigation(),
    );
  }
}
