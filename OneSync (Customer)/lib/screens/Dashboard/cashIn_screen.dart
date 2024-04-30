import 'dart:math'; // Import to generate random codes

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CashInScreen extends StatefulWidget {
  @override
  _CashInScreenState createState() => _CashInScreenState();
}

class _CashInScreenState extends State<CashInScreen> {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Cash In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter Cash In Amount',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 345,
              height: 45,
              child: TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: "Amount",
                  labelStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4D4D4D),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFABBED1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: Colors.red), // Red border for error
                  ),
                  errorStyle: TextStyle(
                    color: Colors
                        .red, // Set the text color of the error message to red
                    fontSize: 14, // Set the font size of the error message
                    fontFamily:
                        'Inter', // Set the font family of the error message
                    fontWeight: FontWeight
                        .w400, // Set the font weight of the error message
                  ),
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
                backgroundColor: Color(0xFF0671E0), // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              child: Text(
                'Cash In',
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
                int updatedBalance =
                    await _deductAmountFromBalance(int.parse(_confirmedAmount));
                if (updatedBalance > 0) {
                  await _storeCashOutTransaction(int.parse(_confirmedAmount));
                }
                Navigator.pop(
                    context, updatedBalance); // Return the updated balance
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
          .collection('Student-Users')
          .doc(currentUserId)
          .get();

      if (!vendorDoc.exists) {
        print('Vendor not found');
        return 0;
      }

      int currentBalance = vendorDoc.get('Balance') ?? 0;
      int updatedBalance = currentBalance + amount;

      FirebaseFirestore db = FirebaseFirestore.instance;

      await db.collection('Student-Users').doc(currentUserId).update({
        'Balance': updatedBalance,
      });

      print('Amount deducted: $amount, Updated balance: $updatedBalance');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Amount added: $amount'),
      ));

      return updatedBalance;
    } catch (e) {
      print('Error adding amount: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error adding amount. Please try again.'),
      ));
      return 0;
    }
  }

  Future<void> _storeCashOutTransaction(int amount) async {
    try {
      String currentUserId = await getCurrentUserId();
      String rfid = await _fetchRfid(currentUserId);

      FirebaseFirestore db = FirebaseFirestore.instance;

      String transactionId =
          _generateRandomTransactionId(); // Generate transaction ID

      Map<String, dynamic> transactionData = {
        'type': 'cashout',
        'totalPrice': amount,
        'date': FieldValue.serverTimestamp(),
        'currentUid': currentUserId,
        'transactionId': transactionId,
        'rfid': rfid
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

  Future<String> _fetchRfid(String userId) async {
    try {
      final rfidSnapshot = await FirebaseFirestore.instance
          .collection('Student-Users')
          .doc(userId)
          .get();

      if (rfidSnapshot.exists && rfidSnapshot.data() != null) {
        return rfidSnapshot.data()!['rfid'] ?? '';
      } else {
        throw Exception('RFID not found for user');
      }
    } catch (e) {
      throw Exception('Error fetching RFID: $e');
    }
  }
}
