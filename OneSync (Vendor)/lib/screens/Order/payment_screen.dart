import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:onesync/screens/MenuList/menu_screen.dart';
import 'package:onesync/screens/Order/order_screen.dart';
import 'package:onesync/screens/Order/payment_successful_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class BreathingCircle extends StatefulWidget {
  @override
  _BreathingCircleState createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 100,
          height: 100,
          child: Center(
            child: Container(
              width: 100 * _animation.value,
              height: 100 * _animation.value,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

class PaymentScreenPage extends StatefulWidget {
  final num totalPrice;
  final Map<String, int> cart;

  const PaymentScreenPage(
      {Key? key, required this.totalPrice, required this.cart})
      : super(key: key);

  @override
  _PaymentScreenPageState createState() => _PaymentScreenPageState();
}

class _PaymentScreenPageState extends State<PaymentScreenPage> {
  bool _isLoading = false;
  String? _rfidUid;
  String transactionId = '';
  String? currentUid;
  String displayMessage = 'Please tap your RFID card';
  DatabaseReference rfidRef = FirebaseDatabase.instance.ref('RFID');

  @override
  void initState() {
    super.initState();
    _startRfidListener();
    rfidRef.update(
        {'Tapped': 1}); // Set 'Tapped' to 1 to indicate waiting for RFID
  }

  void _startRfidListener() {
    rfidRef.child('UID').onValue.listen((event) {
      final newUid = event.snapshot.value as String?;
      if (newUid != null && newUid.isNotEmpty) {
        setState(() {
          _rfidUid = newUid;
          _submitOrder(context);
        });
      } else {
        // RFID key is empty, indicate waiting for RFID
        setState(() {
          _rfidUid = null;
          displayMessage = 'Payment in Progress';
        });
      }
    });
  }

  Future<void> _submitOrder(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      transactionId = _generateRandomTransactionId();
      FirebaseFirestore db = FirebaseFirestore.instance;
      int total = widget.totalPrice.toInt();
      currentUid = await getCurrentUserId();

      final vendorDoc = await db.collection('Menu').doc(currentUid).get();
      if (!vendorDoc.exists) throw Exception('Vendor not found');

      QuerySnapshot studentSnapshot = await db
          .collection('Student-Users')
          .where('rfid', isEqualTo: _rfidUid)
          .get();
      if (studentSnapshot.docs.isEmpty) {
        _updateStatus(2); // RFID not found in database
        _showMessageAndRedirect(
            'Student with RFID not found. Please register RFID.');
        return;
      }

      int studentBalance = studentSnapshot.docs.first.get('Balance');
      if (studentBalance < total) {
        _updateStatus(1); // Insufficient balance
        _showMessageAndRedirect('Insufficient balance. Please reload RFID.');
        Timer(Duration(seconds: 2), () {
          _clearRealtimeDatabaseValues();
        });
        return;
      }

      int updatedStudentBalance = studentBalance - total;
      int vendorBalance = vendorDoc.get('Balance') ?? 0;
      int updatedVendorBalance = vendorBalance + total;

      // Update stocks in vendor's Menu
      List<Map<String, dynamic>> updatedItems = [];
      for (var entry in widget.cart.entries) {
        DocumentSnapshot itemSnapshot = await db
            .collection('Menu')
            .doc(currentUid)
            .collection('vendorProducts')
            .doc(entry.key)
            .get();
        if (!itemSnapshot.exists) {
          throw Exception("Item with id ${entry.key} not found");
        }
        int currentStock = itemSnapshot.get('stock');
        if (currentStock < entry.value) {
          throw Exception("Not enough stock for ${itemSnapshot.get('name')}");
        }
        updatedItems
            .add({'id': entry.key, 'newStock': currentStock - entry.value});
      }

      await db.runTransaction((transaction) async {
        transaction.update(studentSnapshot.docs.first.reference,
            {'Balance': updatedStudentBalance});
        transaction.update(db.collection('Menu').doc(currentUid),
            {'Balance': updatedVendorBalance});

        for (var item in updatedItems) {
          DocumentReference itemRef = db
              .collection('Menu')
              .doc(currentUid)
              .collection('vendorProducts')
              .doc(item['id']);
          transaction.update(itemRef, {'stock': item['newStock']});
        }

        Map<String, dynamic> orderData = {
          'date': Timestamp.fromDate(DateTime.now()),
          'totalPrice': total,
          'items': widget.cart.entries
              .map((entry) => {'name': entry.key, 'quantity': entry.value})
              .toList(),
          'rfid': _rfidUid,
          'currentUid': currentUid,
          'type': 'order',
          'transactionId': transactionId
        };

        transaction.set(
            db.collection('Transactions').doc(transactionId), orderData);
        _updateStatus(3); // Order successful
      });

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PaymentSuccessfulScreen(totalPrice: widget.totalPrice)));

      Timer(Duration(seconds: 2), () {
        _clearRealtimeDatabaseValues();
      });
    } catch (e) {
      print('Error fetching vendor data or submitting order: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('An error occurred during payment. Please try again.')));
    }
  }

  void _resetTotalInFirebase() {
    rfidRef.update({'Total': 0});
  }

  void _resetStatusAndTapped() {
    rfidRef.update({'Status': 0, 'Tapped': 0});
  }

  void _updateStatus(int status) {
    rfidRef.update({'Status': status});
  }

  void _clearUID(int status) {
    rfidRef.update({'UID': ''});
  }

  void _showMessageAndRedirect(String message) {
    setState(() {
      displayMessage = message;
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        textAlign:
            TextAlign.center, // Center align the text within the SnackBar
        style: TextStyle(
            fontSize: 16, // Optional: adjust the font size as needed
            color: Colors.white // Optional: adjust the text color as needed
            ),
      ),
      behavior:
          SnackBarBehavior.floating, // Optional: make the SnackBar floating
      margin: EdgeInsets.all(10), // Optional: adjust margin around the SnackBar
      backgroundColor:
          Colors.blue, // Optional: change background color of the SnackBar
      duration: Duration(seconds: 2),
    ));
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => OrderScreen()));
      _clearRealtimeDatabaseValues();
    });
  }

  void _clearRealtimeDatabaseValues() {
    Timer(Duration(seconds: 2), () {
      rfidRef.update({'Status': 0, 'Tapped': 0, 'Total': 0, 'UID': ''});
    });
  }

  String _generateRandomTransactionId() {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random.secure();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<String> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Payment',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF212121),
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayMessage,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4D4D4D), // Font color changed to 4D4D4D
                  ),
                ),
                SizedBox(
                    height: 5), // Added spacing between message and total price
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Baseline(
                      baseline: 0,
                      baselineType: TextBaseline.alphabetic,
                      child: Text(
                        'PHP',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF0671E0), // Change color to 0671E0
                          fontSize: 16, // Adjust font size as needed
                        ),
                      ),
                    ),
                    Text(
                      '${widget.totalPrice}.00',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 48,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height:
                        50), // Added spacing between total price and indicator
                if (_isLoading) CircularProgressIndicator(),
                SizedBox(
                    height: 20), // Added spacing between indicator and text
                BreathingCircle(), // Breathing circle widget
                SizedBox(height: 40), // Added spacing at the bottom
                Text(
                  'Place Card on the Reader',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20), // Added more spacing before buttons

                // Row containing the buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Update Status and Tapped to 0 before navigating away
                        rfidRef.update({'Status': 0, 'Tapped': 0}).then((_) {
                          // Navigate back or to the editing screen after updating
                          Navigator.pop(context);
                        }).catchError((error) {
                          // Handle any errors here
                          print("Error updating RFID settings: $error");
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Failed to reset RFID status. Please try again.')));
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        side: MaterialStateProperty.all<BorderSide>(
                          BorderSide(color: Color(0xFF0671E0)),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(Size(
                            150, 40)), // Set minimumSize for width and height
                      ),
                      child: Text(
                        'Edit Order',
                        style: TextStyle(
                          color: Color(0xFF0671E0),
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),

                    SizedBox(width: 20), // Increased spacing between buttons
                    ElevatedButton(
                      onPressed: () {
                        // Update Status and Tapped to 0 before navigating away
                        rfidRef.update({
                          'Status': 0,
                          'Tapped': 0,
                          'Total': 0,
                          'UID': ''
                        }).then((_) {
                          // Navigate to the OrderScreen after updating
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderScreen(),
                            ),
                          );
                        }).catchError((error) {
                          // Handle any errors here
                          print("Error updating RFID settings: $error");
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Failed to reset RFID status. Please try again.')));
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Color(0xFFEEF5FC)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(Size(
                            150, 40)), // Set minimumSize for width and height
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF0671E0),
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
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
