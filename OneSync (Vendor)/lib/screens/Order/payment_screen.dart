import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:onesync/screens//Order/payment_successful_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math'; // Import to generate random codes

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
  String? currentUid; // Field to store currentUid

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

      currentUid = await getCurrentUserId(); // Store currentUid

      final vendorDoc = await db.collection('Menu').doc(currentUid).get();

      if (!vendorDoc.exists) {
        throw Exception('Vendor not found');
      }

      QuerySnapshot studentSnapshot = await db
          .collection('Student-Users')
          .where('UID', isEqualTo: _rfidUid)
          .get();

      if (studentSnapshot.docs.isEmpty) {
        print('Student with UID $_rfidUid not found');
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
        transaction.update(
            studentSnapshot.docs.first.reference, {'Balance': updatedBalance});

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

  Future<String> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not logged in');
    }
  }

  @override
  void initState() {
    super.initState();
    _startRfidListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment in Progress'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _rfidUid == null
                  ? 'Please tap your RFID card'
                  : 'Order submitted',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Total: ₱${widget.totalPrice}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            if (_isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
