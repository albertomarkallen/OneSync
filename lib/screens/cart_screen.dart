import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatefulWidget {
  final Map<String, int> cart;
  final List<Map<String, dynamic>> items;

  const CartScreen({Key? key, required this.cart, required this.items})
      : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  num _calculateTotal() {
    return widget.cart.entries
        .map((entry) =>
            widget.items
                .firstWhere((item) => item['name'] == entry.key)['price'] *
            entry.value)
        .fold(0, (previousValue, element) => previousValue + element);
  }

  void _incrementQuantity(String itemName) {
    setState(() {
      if (widget.cart.containsKey(itemName)) {
        widget.cart[itemName] = widget.cart[itemName]! + 1;
      }
    });
  }

  void _decrementQuantity(String itemName) {
    setState(() {
      if (widget.cart.containsKey(itemName) && widget.cart[itemName]! > 0) {
        widget.cart[itemName] = widget.cart[itemName]! - 1;
      }
    });
  }

  Widget _buildCheckoutButton(BuildContext context) {
    int totalItems = widget.cart.values
        .fold(0, (previousValue, quantity) => previousValue + quantity);
    num totalPrice = _calculateTotal();

    return totalItems > 0
        ? Container(
            color: Colors.blue[700], // Use a deep blue color for the background
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ₱$totalPrice',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _submitOrder(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue[800],
                      backgroundColor: Colors.white, // Button color
                      elevation: 0, // Removes shadow for a flat design
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8), // Adjust the radius as needed
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.0),
                      child: Text(
                        'Pay Now',
                        style: TextStyle(color: Colors.blue[800]), // Text color
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : SizedBox.shrink(); // Return an empty container if no items
  }

  Future<void> _submitOrder(BuildContext context) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    int total = _calculateTotal().toInt();

    // Fetch the last used transaction number from the database
    DocumentSnapshot lastTransactionDoc =
        await db.collection('Meta').doc('TransactionNumber').get();

    int lastTransactionNumber =
        lastTransactionDoc.exists ? lastTransactionDoc.get('number') : 0;

    int nextTransactionNumber = lastTransactionNumber + 1;
    String transactionId = 'Transaction$nextTransactionNumber';

    Map<String, dynamic> orderData = {
      'date': Timestamp.fromDate(DateTime.now()), // Adjust for GMT+8
      'totalPrice': total,
      'items': widget.cart.entries
          .map((entry) => {'name': entry.key, 'quantity': entry.value})
          .toList(),
    };

    // Update the last used transaction number in the database
    await db.collection('Meta').doc('TransactionNumber').set({
      'number': nextTransactionNumber,
    });

    await db
        .collection('Transactions')
        .doc(transactionId)
        .set(orderData)
        .then((_) {
      print('Order successfully submitted!');
      Navigator.pop(
          context); // Optionally navigate back after submitting the order
    }).catchError((error) {
      print('Failed to submit order: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit order. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cart.length,
              itemBuilder: (context, index) {
                String itemName = widget.cart.keys.elementAt(index);
                int itemQuantity = widget.cart.values.elementAt(index);
                int itemPrice = widget.items
                    .firstWhere((item) => item['name'] == itemName)['price'];
                int subtotal = itemPrice * itemQuantity;
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(itemName),
                      SizedBox(
                          height:
                              4), // Add some vertical space between product name and subtotal
                      Text('Subtotal: ₱${subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _decrementQuantity(itemName),
                        icon: Icon(Icons.remove),
                      ),
                      SizedBox(width: 8), // Add some space between the buttons
                      Text(itemQuantity
                          .toString()), // Show quantity here if needed
                      SizedBox(width: 8), // Add some space between the buttons
                      IconButton(
                        onPressed: () => _incrementQuantity(itemName),
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildCheckoutButton(
              context), // Place this where you want the button to appear
        ],
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
