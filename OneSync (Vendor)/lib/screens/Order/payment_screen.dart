import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:onesync/screens/MenuList/menu_screen.dart';
import 'package:onesync/screens/Order/cart_screen.dart'; // Adjust the import to your actual CartScreen path
import 'package:onesync/screens/Order/payment_successful_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'dart:async'; // Import for Timer

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

  @override
  void initState() {
    super.initState();
    _startRfidListener();
  }

  void _startRfidListener() {
    final rfidRef = FirebaseDatabase.instance.ref('RFID/UID');
    rfidRef.onValue.listen((event) {
      print('Waiting for RFID card...');
      final newUid = event.snapshot.value as String?;
      if (newUid != null) {
        setState(() {
          _rfidUid = newUid;
          _submitOrder(context);
        });
      } else {
        _showMessageAndRedirect('RFID not found. Please reload RFID.');
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
        _showMessageAndRedirect(
            'Student with RFID $_rfidUid not found. Please reload RFID.');
        return;
      }

      int studentBalance = studentSnapshot.docs.first.get('Balance');
      if (studentBalance < total) {
        _showMessageAndRedirect('Insufficient balance. Please reload RFID.');
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

      return db.runTransaction((transaction) async {
        // Update customer balance
        transaction.update(studentSnapshot.docs.first.reference,
            {'Balance': updatedStudentBalance});

        // Update vendor balance
        transaction.update(db.collection('Menu').doc(currentUid), {
          'Balance': updatedVendorBalance,
        });

        // Update each item stock in the transaction
        for (var item in updatedItems) {
          DocumentReference itemRef = db
              .collection('Menu')
              .doc(currentUid)
              .collection('vendorProducts')
              .doc(item['id']);
          transaction.update(itemRef, {'stock': item['newStock']});
        }

        // Other transaction operations (e.g., log the transaction)
        Map<String, dynamic> orderData = {
          'date': Timestamp.fromDate(DateTime.now()),
          'totalPrice': total,
          'items': widget.cart.entries
              .map((entry) => {'name': entry.key, 'quantity': entry.value})
              .toList(),
          'rfid': _rfidUid,
          'currentUid': currentUid, // Include currentUid in orderData
          'type': 'order'
        };

        transaction.set(
            db.collection('Transactions').doc(transactionId), orderData);

        return null;
      }).then((_) {
        print('Order successfully submitted, balances and stocks updated!');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PaymentSuccessfulScreen(totalPrice: widget.totalPrice)));
      }).catchError((error) {
        print('Failed to update balances and stocks: $error');
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An error occurred during payment. Please try again.'),
        ));
      });
    } catch (e) {
      print('Error fetching vendor data or submitting order: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An error occurred during payment. Please try again.'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessageAndRedirect(String message) {
    setState(() {
      displayMessage = message;
      _isLoading = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MenuScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            70, // Increase or adjust this as needed to give more vertical space
        title: Padding(
          padding: EdgeInsets.only(top: 4), // Fine-tune this value as needed
          child: Text('Payment',
              style: TextStyle(
                color: Color(0xFF212121),
                fontSize: 28,
                fontFamily: 'Poppins', // or 'Inter'
                fontWeight: FontWeight.w700,
              )),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(displayMessage,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Total: ₱${widget.totalPrice}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 40),
            if (_isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }

  // Helper method to generate random transaction ID
  String _generateRandomTransactionId() {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random.secure();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  // Helper method to get current user ID
  Future<String> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not logged in');
    }
  }
}
