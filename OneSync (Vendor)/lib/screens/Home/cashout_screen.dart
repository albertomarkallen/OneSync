import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math'; // Import to generate random codes

class CashOutScreen extends StatefulWidget {
  @override
  _CashOutScreenState createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  TextEditingController _amountController = TextEditingController();
  bool _showConfirmation = false;
  String _confirmedAmount = '';

  // Generate a random 8-digit alphanumeric code
  String _generateRandomTransactionId() {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random.secure();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cash Out'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter Cash Out Amount',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.monetization_on),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                // Add additional validation if needed
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showConfirmation = true;
                  _confirmedAmount = _amountController.text;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Background color
              ),
              child: Text(
                'Cash Out',
                style: TextStyle(
                  color: Colors.white, // Text color
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _showConfirmation
          ? FloatingActionButton(
              onPressed: () async {
                print('Cash Out confirmed: $_confirmedAmount');
                int updatedBalance =
                    await _deductAmountFromBalance(int.parse(_confirmedAmount));
                if (updatedBalance > 0) {
                  await _storeCashOutTransaction(int.parse(_confirmedAmount));
                }
                setState(() {
                  _showConfirmation = false;
                });
                Navigator.pop(context, updatedBalance);
              },
              child: Icon(Icons.check),
            )
          : null,
    );
  }

  Future<int> _deductAmountFromBalance(int amount) async {
    try {
      String currentUserId = await getCurrentUserId();

      final vendorDoc = await FirebaseFirestore.instance
          .collection('Menu')
          .doc(currentUserId)
          .get();

      if (!vendorDoc.exists) {
        print('Vendor not found');
        return 0;
      }

      int currentBalance = vendorDoc.get('Balance') ?? 0;
      int updatedBalance = currentBalance - amount;

      FirebaseFirestore db = FirebaseFirestore.instance;

      await db.collection('Menu').doc(currentUserId).update({
        'Balance': updatedBalance,
      });

      print('Amount deducted: $amount, Updated balance: $updatedBalance');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Amount deducted: $amount'),
      ));

      return updatedBalance;
    } catch (e) {
      print('Error deducting amount: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error deducting amount. Please try again.'),
      ));
      return 0;
    }
  }

  Future<void> _storeCashOutTransaction(int amount) async {
    try {
      String currentUserId = await getCurrentUserId();

      FirebaseFirestore db = FirebaseFirestore.instance;

      String transactionId =
          _generateRandomTransactionId(); // Generate transaction ID

      // Fetch RFID from Firestore
      DocumentSnapshot rfidDoc =
          await db.collection('Student-Users').doc(currentUserId).get();

      if (!rfidDoc.exists) {
        print('RFID not found for user');
        return;
      }

      String rfid = rfidDoc.get('rfid');

      Map<String, dynamic> transactionData = {
        'type': 'cashout',
        'totalPrice': amount,
        'date': FieldValue.serverTimestamp(),
        'currentUid': currentUserId,
        'transactionId': transactionId,
        'rfid': rfid, // Include RFID in transaction data
      };

      await db
          .collection('Transactions')
          .doc(transactionId)
          .set(transactionData);

      print('Cashout transaction stored in Firestore with ID: $transactionId');
    } catch (e) {
      print('Error storing cashout transaction: $e');
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
}
