import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:onesync/screens/payment_successful_screen.dart';

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
    final rfidRef = FirebaseDatabase.instance
        .ref('RFID/Current-UID');

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
      // ********** 1. Your Existing Order Submission to Firestore ********** 
      FirebaseFirestore db = FirebaseFirestore.instance;
      int total = widget.totalPrice.toInt(); 

      // Retrieve the last used transaction number
      DocumentSnapshot lastTransactionDoc =
          await db.collection('Meta').doc('TransactionNumber').get();

      int lastTransactionNumber = lastTransactionDoc.exists
          ? lastTransactionDoc.get('number')
          : 0;
      int nextTransactionNumber = lastTransactionNumber + 1;
      transactionId = 'Transaction$nextTransactionNumber'; 

      Map<String, dynamic> orderData = {
        'date': Timestamp.fromDate(DateTime.now()),
        'totalPrice': total,
        'items': widget.cart.entries
            .map((entry) => {'name': entry.key, 'quantity': entry.value})
            .toList(),
        'rfid': _rfidUid // Add the RFID data to the order
      };

      // Update transaction number for the next transaction
      await db.collection('Meta').doc('TransactionNumber').set({
        'number': nextTransactionNumber,
      });

      await db
          .collection('Transactions')
          .doc(transactionId)
          .set(orderData)
          .then((_) {
        print('Order successfully submitted!');
      }).catchError((error) {
        print('Error submitting order: $error');
        // Handle the error appropriately 
      });
      // *******************************************************************

      // 2. Update Firebase Realtime Database to clear "Current-UID"
      await FirebaseDatabase.instance.ref('RFID/Current-UID').set(null);

      // 3. Navigate to Payment Successful screen and clear cart
      Navigator.pushReplacement( 
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessfulScreen(totalPrice: widget.totalPrice),
        ),
      );

    } catch (e) {
      print('Error submitting order: $e');
      // Handle general errors
    } finally {
      setState(() {
        _isLoading = false; 
      });
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
}


