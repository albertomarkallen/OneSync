import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart'; // Import your 'navigation.dart' file
import 'package:onesync/screens/Order/payment_screen.dart';

class CartScreen extends StatefulWidget {
  final Map<String, int> cart;
  final List<Map<String, dynamic>> items;
  final Function(Map<String, int>) onUpdateCart;

  const CartScreen(
      {super.key,
      required this.cart,
      required this.items,
      required this.onUpdateCart});

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

  void _updateTotalInFirebase() {
    int total = _calculateTotal().toInt();
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child('RFID').update({'Total': total});
  }

  void _incrementQuantity(String itemName) {
    setState(() {
      if (widget.cart.containsKey(itemName)) {
        int currentQuantity = widget.cart[itemName]!;
        int availableStock = widget.items
            .firstWhere((item) => item['name'] == itemName)['stock'];

        if (currentQuantity < availableStock) {
          widget.cart[itemName] = currentQuantity + 1;
          _updateTotalInFirebase();
          widget.onUpdateCart(widget.cart);
        } else {
          // Show a snackbar or dialog indicating that the stock is insufficient
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Insufficient stock for $itemName'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _decrementQuantity(String itemName) {
    setState(() {
      if (widget.cart.containsKey(itemName) && widget.cart[itemName]! > 0) {
        widget.cart[itemName] = widget.cart[itemName]! - 1;
        if (widget.cart[itemName] == 0) {
          widget.cart
              .remove(itemName); // Ensure the item is removed from the cart
        }
        _updateTotalInFirebase();
        widget.onUpdateCart(widget.cart);
      }
    });
  }

  Widget _buildCheckoutButton(BuildContext context) {
    int totalItems =
        widget.cart.values.fold(0, (prev, quantity) => prev + quantity);
    num totalPrice = _calculateTotal();
    // Determine the correct singular or plural form of "Item"
    String itemText = totalItems == 1 ? 'Item' : 'Items';

    return totalItems > 0
        ? Container(
            color: Colors.blue[700], // Use a deep blue color for the background
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$totalItems $itemText', // Use the correct singular or plural form
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Total: ₱$totalPrice',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _goToWaitForRfid(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue[800],
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Text(
                        'Pay Now',
                        style: TextStyle(color: Colors.blue[800]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink(); // Return an empty container if no items
  }

  // Navigate to a new page to wait for RFID
  void _goToWaitForRfid(BuildContext context) async {
    num totalPrice = _calculateTotal();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreenPage(
          totalPrice: totalPrice,
          cart: widget.cart, // Pass the cart data
        ),
      ),
    );
    // Proceed to order submission
  }

  Future<void> _submitOrder(BuildContext context) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    int total = _calculateTotal().toInt();

    // Retrieve the last used transaction number from the database
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

    // Update last used transaction number
    await db.collection('Meta').doc('TransactionNumber').set({
      'number': nextTransactionNumber,
    });

    await db
        .collection('Transactions')
        .doc(transactionId)
        .set(orderData)
        .then((_) {
      print('Order successfully submitted!');
      Navigator.pop(context);
    }).catchError((error) {
      // ... Error handling ...
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text('Order Details',
              style: TextStyle(
                color: Color(0xFF212121),
                fontSize: 28,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              )),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cart.length,
              itemBuilder: (context, index) {
                String itemName = widget.cart.keys.elementAt(index);
                int itemQuantity = widget.cart.values.elementAt(index);
                Map<String, dynamic> item =
                    widget.items.firstWhere((item) => item['name'] == itemName);
                int itemPrice = item['price'];
                String imageUrl = item['imageUrl'];
                int subtotal = itemPrice * itemQuantity;

                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      shape: BoxShape.rectangle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Subtotal: ₱${subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color(0xFFDBEDFF),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          onPressed: () => _decrementQuantity(itemName),
                          icon: Icon(Icons.remove, color: Color(0xFF4196F0)),
                          tooltip: 'Decrease quantity',
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(itemQuantity.toString(),
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color(0xFF4196F0),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          onPressed: () => _incrementQuantity(itemName),
                          icon: Icon(Icons.add, color: Color(0xFFFFFFFF)),
                          tooltip: 'Increase quantity',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildCheckoutButton(context),
        ],
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
