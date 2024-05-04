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
          displayMessage = 'Please tap your RFID card';
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
            'Student with RFID not found. Please reload RFID.');
        return;
      }

      int studentBalance = studentSnapshot.docs.first.get('Balance');
      if (studentBalance < total) {
        _updateStatus(1); // Insufficient balance
        _showMessageAndRedirect('Insufficient balance. Please reload RFID.');
        Timer(Duration(seconds: 3), () {
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
          'type': 'order'
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

      Timer(Duration(seconds: 5), () {
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => OrderScreen()));
      _clearRealtimeDatabaseValues();
    });
  }

  void _clearRealtimeDatabaseValues() {
    Timer(Duration(seconds: 5), () {
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
          child: Text('Payment',
              style: TextStyle(
                color: Color(0xFF212121),
                fontSize: 28,
                fontFamily: 'Poppins',
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
}
