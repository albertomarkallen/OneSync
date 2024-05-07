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
  int _currentBalance = 0;

  @override
  void initState() {
    super.initState();
    _fetchCurrentBalance(); // Fetch and update current balance on screen initialization
  }

  // Fetch the current balance of the user
  Future<void> _fetchCurrentBalance() async {
    try {
      String currentUserId = await getCurrentUserId();

      final vendorDoc = await FirebaseFirestore.instance
          .collection('Menu')
          .doc(currentUserId)
          .get();

      if (!vendorDoc.exists) {
        print('Vendor not found');
        return;
      }

      setState(() {
        _currentBalance = vendorDoc.get('Balance') ?? 0;
      });
    } catch (e) {
      print('Error fetching current balance: $e');
    }
  }

  // Generate a random 8-digit alphanumeric code after fetching balance
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
        toolbarHeight: 70,
        title: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Cashout',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF212121),
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
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
            Text(
              'Balance: PHP $_currentBalance',
              style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 18, color: Colors.blue),
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
                } else if (_currentBalance <= 0) {
                  return 'Insufficient balance';
                } else if (int.tryParse(value) == null ||
                    int.parse(value) > _currentBalance) {
                  return 'Amount exceeds balance';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_amountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please enter an amount'),
                  ));
                  return;
                }
                int cashOutAmount = int.parse(_amountController.text);
                if (cashOutAmount > _currentBalance) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Amount exceeds balance'),
                  ));
                  return;
                }
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
                int cashOutAmount = int.parse(_confirmedAmount);
                int updatedBalance =
                    await _deductAmountFromBalance(cashOutAmount);
                if (updatedBalance > 0) {
                  await _storeCashOutTransaction(cashOutAmount);
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
        backgroundColor:
            Color(0xFF0671E0), // Background color set to 0xFF0671E0
        content: Text(
          'Amount deducted: PHP $amount.00',
          style: TextStyle(
              color: Colors.white, // Font color set to white
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold // Font family set to Inter
              ),
        ),
      ));

      return updatedBalance;
    } catch (e) {
      print('Error deducting amount: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor:
            Color(0xFF0671E0), // Background color set to 0xFF0671E0
        content: Text(
          'Error deducting amount. Please try again.',
          style: TextStyle(
              color: Colors.white, // Font color set to white
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold // Font family set to Inter
              ),
        ),
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

      // Fetch document that might contain UID
      DocumentSnapshot userDoc =
          await db.collection('Menu').doc(currentUserId).get();

      if (!userDoc.exists) {
        print('Document not found for user');
        return;
      }

      // Check if UID exists in the document
      String? UID = userDoc.get('UID');

      if (UID == null) {
        print('UID not found for user');
        return; // Early return if UID is not found
      }

      Map<String, dynamic> transactionData = {
        'type': 'cashout',
        'totalPrice': amount,
        'date': FieldValue.serverTimestamp(),
        'currentUid': currentUserId,
        'transactionId': transactionId,
        'rfid': UID, // Include UID in transaction data
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
