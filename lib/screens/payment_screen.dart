import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:onesync/screens/payment_successful_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesync/screens/profile_screen.dart';

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
      FirebaseFirestore db = FirebaseFirestore.instance;
      int total = widget.totalPrice.toInt();

      DocumentSnapshot lastTransactionDoc =
          await db.collection('Meta').doc('TransactionNumber').get();
      int lastTransactionNumber =
          lastTransactionDoc.exists ? lastTransactionDoc.get('number') : 0;
      int nextTransactionNumber = lastTransactionNumber + 1;
      transactionId = 'Transaction$nextTransactionNumber';

      // Fetch Vendor Data with Error Handling
      String currentUserId = await getCurrentUserId();
      final vendorDoc = await db
          .collection('Menu')
          .doc(currentUserId)
          .get();

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
        // Handle case where the vendor RFID isn't found 
        return;
      }

      vendorRFIDSnapshot.docs.first.get('UID');
      DocumentSnapshot linkedVendorSnapshot =
          await db.collection('Menu')
          .doc(currentUserId)
          .get();
      int vendorBalance =
          linkedVendorSnapshot.exists ? linkedVendorSnapshot.get('Balance') : 0;
      int updatedVendorBalance = vendorBalance + total;

      return db.runTransaction((transaction) async {
        transaction.update(studentSnapshot.docs.first.reference,
            {'Balance': updatedBalance});
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
        transaction.update(db.collection('Meta').doc('TransactionNumber'),
            {'number': nextTransactionNumber});

        // Update the vendor's RFID balance
        await _updateVendorRFIDBalance(_rfidUid!, total);

        return null;
      }).then((_) {
        print('Order successfully submitted and balances updated!');
        _clearDatabase();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessfulScreen(
                totalPrice: widget.totalPrice),
          ),
        );
      }).catchError((error) {
        print('Failed to update balances: $error');
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('An error occurred during payment. Please try again.'),
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

  Future<void> _clearDatabase() async {
    try {
      final dbRef = FirebaseDatabase.instance.ref('/');
      await dbRef.remove();
      print('Database cleared successfully');
    } catch (error) {
      print('Error clearing database: $error');
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
                  : 'Order submitted for RFID: $_rfidUid',
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

  Future<String> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not logged in');
    }
  }
}
