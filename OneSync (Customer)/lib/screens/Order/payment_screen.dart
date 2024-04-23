import 'dart:math'; // Import to generate random codes

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/Order/payment_successful_screen.dart';

class PaymentScreenPage extends StatefulWidget {
  final num totalPrice;
  final Map<String, int> cart;

  const PaymentScreenPage(
      {super.key, required this.totalPrice, required this.cart});

  @override
  _PaymentScreenPageState createState() => _PaymentScreenPageState();
}

class _PaymentScreenPageState extends State<PaymentScreenPage> {
  bool _isLoading = false;
  String? _rfidUid;
  String transactionId = '';

  // Generate a random 8-digit alphanumeric code
  String _generateRandomTransactionId() {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random.secure();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
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
      }
    });
  }

  Future<void> _submitOrder(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Generate the random transaction ID
      transactionId = _generateRandomTransactionId();

      FirebaseFirestore db = FirebaseFirestore.instance;
      int total = widget.totalPrice.toInt();

      // Fetch Vendor Data with Error Handling
      String currentUserId = await getCurrentUserId();
      final vendorDoc = await db.collection('Menu').doc(currentUserId).get();

      if (!vendorDoc.exists) {
        throw Exception('Vendor not found');
      }

      DocumentSnapshot vendorSnapshot =
          await db.collection('Menu').doc(currentUserId).get();

      QuerySnapshot studentSnapshot = await db
          .collection('Student-Users')
          .where('UID', isEqualTo: _rfidUid)
          .get();

      if (studentSnapshot.docs.isEmpty) {
        print('Student with UID $_rfidUid not found in Firestore database');
        // Handle student not found (display a message, etc.)
        return;
      }

      String studentName = studentSnapshot.docs.first.get('Name');
      int studentBalance = studentSnapshot.docs.first.get('Balance');

      if (studentBalance < total) {
        print('Insufficient balance');
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Insufficient balance'),
        ));
        return;
      }

      int updatedBalance = studentBalance - total;

      // Find the vendor's document based on the RFID
      QuerySnapshot vendorRFIDSnapshot = await FirebaseFirestore.instance
          .collection('Menu') // Replace 'rfids' with your collection name
          .where(currentUserId)
          .get();

      if (vendorRFIDSnapshot.docs.isEmpty) {
        print('Vendor RFID record not found');

        return;
      }

      vendorRFIDSnapshot.docs.first.get('UID');
      DocumentSnapshot linkedVendorSnapshot =
          await db.collection('Menu').doc(currentUserId).get();
      int vendorBalance =
          linkedVendorSnapshot.exists ? linkedVendorSnapshot.get('Balance') : 0;
      int updatedVendorBalance = vendorBalance + total;

      return db.runTransaction((transaction) async {
        transaction.update(
            studentSnapshot.docs.first.reference, {'Balance': updatedBalance});
        transaction.update(db.collection('Menu').doc(currentUserId),
            {'Balance': updatedVendorBalance});

        Map<String, dynamic> orderData = {
          'date': Timestamp.fromDate(DateTime.now()),
          'totalPrice': total,
          'items': widget.cart.entries
              .map((entry) => {'name': entry.key, 'quantity': entry.value})
              .toList(),
          'rfid': _rfidUid
        };

        transaction.set(
            db.collection('Transactions').doc(transactionId), orderData);

        // Update the vendor's RFID balance
        await _updateVendorRFIDBalance(_rfidUid!, total);

        return null;
      }).then((_) {
        print('Order successfully submitted and balances updated!');
        // _clearDatabase();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PaymentSuccessfulScreen(totalPrice: widget.totalPrice),
          ),
        );
      }).catchError((error) {
        print('Failed to update balances: $error');
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

  Future<void> _updateVendorRFIDBalance(String rfid, int amount) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final vendorRFIDDoc = await FirebaseFirestore.instance
          .collection('rfids') // Replace with your collection name
          .where('uid', isEqualTo: currentUserId)
          .get();

      if (vendorRFIDDoc.docs.isNotEmpty) {
        final vendorRFIDRef = vendorRFIDDoc.docs.first.reference;
        final vendorData = await vendorRFIDRef.get(); // Fetch the document
        int currentBalance = vendorData.get('balance') as int ?? 0;
        await vendorRFIDRef.update({'balance': currentBalance + amount});
      } else {
        print('Vendor RFID document not found');
      }
    } catch (e) {
      print('Error updating vendor RFID balance: $e');
    }
  }

  // Future<void> _clearDatabase() async {
  //   try {
  //     final dbRef = FirebaseDatabase.instance.ref('/');
  //     await dbRef.remove();
  //     print('Database cleared successfully');
  //   } catch (error) {
  //     print('Error clearing database: $error');
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _startRfidListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment in Progress'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _rfidUid == null
                  ? 'Please tap your RFID card'
                  : 'Order submitted',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Total: ₱${widget.totalPrice}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            if (_isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
      bottomNavigationBar: const Navigation(),
    );
  }

  Future<String> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not logged in');
    }
  }
}
