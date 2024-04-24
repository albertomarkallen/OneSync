import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CashOutScreen extends StatefulWidget {
  @override
  _CashOutScreenState createState() => _CashOutScreenState();
}

class _CashOutScreenState extends State<CashOutScreen> {
  TextEditingController _amountController = TextEditingController();
  bool _showConfirmation = false;
  String _confirmedAmount = '';

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
                // Implement cashout logic here
                print('Cash Out confirmed: $_confirmedAmount');
                // Call a method to deduct the amount from the balance
                int updatedBalance =
                    await _deductAmountFromBalance(int.parse(_confirmedAmount));
                // Close the confirmation widget
                setState(() {
                  _showConfirmation = false;
                });
                // Pass the updated balance back to the home screen
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

      return updatedBalance; // Return the updated balance
    } catch (e) {
      print('Error deducting amount: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error deducting amount. Please try again.'),
      ));
      return 0; // Return 0 if there's an error
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
