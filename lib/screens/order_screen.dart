import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/cart_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final List<Map<String, dynamic>> items = [];
  Map<String, int> cart = {};
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> displayedItems = [];

  int _calculateTotal() {
    int total = 0;
    cart.forEach((key, quantity) {
      final item = items.firstWhere((item) => item['name'] == key);
      int itemTotal =
          (item['price'] * quantity).round(); // Round to the nearest integer
      total += itemTotal;
    });
    return total;
  }

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchItems() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Menu').get();

      final List<Map<String, dynamic>> fetchedItems =
          querySnapshot.docs.map((doc) {
        return {
          'name': doc.get('name'),
          'price': doc.get('price'),
          'stock': doc.get('stock'),
          'inCart': false, // Add a flag to track if item is in cart
          'quantity': 0, // Add quantity for each item
        };
      }).toList();

      setState(() {
        items.addAll(fetchedItems);
        displayedItems = List.from(fetchedItems);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  void _filterItems(String query) {
    String lowerCaseQuery = query.toLowerCase();
    setState(() {
      displayedItems = items.where((item) {
        return item['name'].toLowerCase().contains(lowerCaseQuery);
      }).toList();
    });
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: _filterItems,
        decoration: InputDecoration(
          labelText: 'Search',
          suffixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }

  Widget _menuList(BuildContext context, Map<String, dynamic> item, int index) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          if (!item['inCart']) {
            _addToCart(index);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Image.network(
                "https://via.placeholder.com/110x78", // Replace with item image URL
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock: ${item['stock']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '₱${item['price']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (item['inCart'])
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _decrementQuantity(index),
                      icon: Icon(Icons.remove_circle_outline,
                          color: Colors.blue[800]),
                    ),
                    Text(
                      ' ${item['quantity']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _incrementQuantity(index),
                      icon: Icon(Icons.add_circle_outline,
                          color: Colors.blue[800]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the bottom padding for the GridView,
    // taking into account the height of the bottomSheet if it exists.
    double bottomPadding = 0;
    Widget? totalDisplay = _buildTotalDisplay(context);
    if (totalDisplay != null) {
      // You can adjust this value if the bottom sheet is larger or smaller
      bottomPadding = 60.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                        4.0, 4.0, 4.0, bottomPadding), // Adjusted padding
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: displayedItems.length,
                    itemBuilder: (context, index) {
                      return _menuList(context, displayedItems[index], index);
                    },
                  ),
                ),
        ],
      ),
      bottomNavigationBar: Navigation(),
      bottomSheet: totalDisplay, // Use the variable here
    );
  }

  Widget? _buildTotalDisplay(BuildContext context) {
    int totalItems = cart.values
        .fold(0, (previousValue, quantity) => previousValue + quantity);
    String itemsText = totalItems == 1 ? 'Item' : 'Items';

    if (totalItems > 0) {
      return Container(
        color: Colors.blue[700], // Use a deep blue color for the background
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalItems $itemsText',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Total: ₱${_calculateTotal()}',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CartScreen(cart: cart, items: items),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue[800],
                  backgroundColor: Colors.white, // Button color
                  elevation: 0, // Removes shadow for a flat design
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // Adjust the radius as needed
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                  child: Row(
                    children: [
                      Text(
                        'View Order',
                        style: TextStyle(color: Colors.blue[800]), // Text color
                      ),
                      Icon(
                        Icons.arrow_right_alt,
                        color: Colors.blue[800],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return null; // Return null when there are no items in the cart
    }
  }

  // Add this part for the total price
}
