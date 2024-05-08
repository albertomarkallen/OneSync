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
  TextEditingController _codeController =
      TextEditingController(); // Controller for the 6-digit code
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
        title: Text('Cash In', style: TextStyle(fontFamily: 'Inter')),
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
            TextFormField(
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
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: "Enter 6-Digit Code",
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool isCodeValid = await _verifyCode(_codeController.text);
                if (!isCodeValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid Code Entered',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontSize: 16)),
                      backgroundColor: Colors.blue,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  return;
                }
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
                    fontFamily: 'Inter' // Setting font family
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
                    await _addAmountFromBalance(int.parse(_confirmedAmount));
                if (updatedBalance > 0) {
                  await _storeCashOutTransaction(int.parse(_confirmedAmount));
                  await _updateCodeAfterCashIn(); // Update the 6-digit code after successful transaction
                  Navigator.pop(
                      context, updatedBalance); // Return the updated balance
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Transaction successful, balance updated',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontSize: 16)),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              child: Icon(Icons.check),
            )
          : null,
    );
  }

  Future<bool> _verifyCode(String enteredCode) async {
    try {
      var codeDoc = await FirebaseFirestore.instance
          .collection('Cash-In')
          .doc('6 Digit Code')
          .get();
      String storedCode = codeDoc.data()?['Code'] as String;
      return storedCode == enteredCode;
    } catch (e) {
      print('Error verifying code: $e');
      return false;
    }
  }

  Future<void> _updateCodeAfterCashIn() async {
    String newCode =
        Random.secure().nextInt(1000000).toString().padLeft(6, '0');
    await FirebaseFirestore.instance
        .collection('Cash-In')
        .doc('6 Digit Code')
        .update({
      'Code': newCode,
    });
    print('New 6-digit code generated and stored: $newCode');
  }

  Future<int> _addAmountFromBalance(int amount) async {
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
      print('Amount added: $amount, Updated balance: $updatedBalance');
      return updatedBalance;
    } catch (e) {
      print('Error adding amount: $e');
      return 0;
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

  Future<void> _storeCashOutTransaction(int amount) async {
    try {
      String currentUserId = await getCurrentUserId();
      String rfid = await _fetchRfid(currentUserId);

      FirebaseFirestore db = FirebaseFirestore.instance;

      String transactionId =
          _generateRandomTransactionId(); // Generate transaction ID

      Map<String, dynamic> transactionData = {
        'type': 'Cash In',
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
}


// import 'dart:math'; // Import to generate random codes

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class CashInScreen extends StatefulWidget {
//   @override
//   _CashInScreenState createState() => _CashInScreenState();
// }

// class _CashInScreenState extends State<CashInScreen> {
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _codeController =
//       TextEditingController(); // Controller for the 6-digit code
//   bool _showConfirmation = false;
//   bool _isCodeVisible = false;
//   bool _isbuttonPressed = false;
//   String _confirmedAmount = '';

//   // Generate a random 8-digit alphanumeric code
//   String _generateRandomTransactionId() {
//     const String chars =
//         'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
//     Random rnd = Random.secure();
//     return String.fromCharCodes(Iterable.generate(
//         8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text('Cash In', style: TextStyle(fontFamily: 'Inter')),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Enter Cash In Amount',
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 20),
//             TextFormField(
//               controller: _amountController,
//               decoration: InputDecoration(
//                 labelText: "Amount",
//                 labelStyle: TextStyle(
//                   fontFamily: 'Inter',
//                   fontWeight: FontWeight.w400,
//                   color: Color(0xFF4D4D4D),
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(color: Color(0xFFABBED1)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(color: Colors.blue),
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide(color: Colors.red),
//                 ),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 20),
//             if (_isCodeVisible)
//               TextFormField(
//                 controller: _codeController,
//                 decoration: InputDecoration(
//                   labelText: "Enter 6-Digit Code",
//                   border: OutlineInputBorder(),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.blue),
//                   ),
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) {
//                   setState(() {
//                     _confirmedAmount = value;
//                     _showConfirmation = value.isNotEmpty;
//                     print('Code entered: $value'); // Debug output
//                     print(
//                         'Is code valid for submission? $_showConfirmation'); // Debug output
//                   });
//                 },
//               ),
//             SizedBox(height: 20),
//             if (!_isCodeVisible)
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _isCodeVisible =
//                         true; // This will also hide the 'Send Code' button
//                   });
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF0671E0), // Background color
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8), // Rounded corners
//                   ),
//                 ),
//                 child: Text(
//                   'Send Code',
//                   style: TextStyle(
//                       color: Colors.white, // Text color
//                       fontFamily: 'Inter' // Setting font family
//                       ),
//                 ),
//               ),
//             SizedBox(height: 20),
//             if (_isCodeVisible &&
//                 _showConfirmation) // Only shown if conditions are met
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     int updatedBalance = await _addAmountFromBalance(
//                         int.parse(_confirmedAmount));
//                     if (updatedBalance > 0) {
//                       await _storeCashOutTransaction(
//                           int.parse(_confirmedAmount));
//                       await _updateCodeAfterCashIn(); // Update the 6-digit code after successful transaction
//                       Navigator.pop(context,
//                           updatedBalance); // Return the updated balance
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                               'Transaction successful, balance updated',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontFamily: 'Inter',
//                                   fontSize: 16)),
//                           backgroundColor: Colors.green,
//                           behavior: SnackBarBehavior.floating,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                         ),
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('Transaction failed, please try again',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontFamily: 'Inter',
//                                   fontSize: 16)),
//                           backgroundColor: Colors.red,
//                           behavior: SnackBarBehavior.floating,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                         ),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF0671E0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(
//                     'Confirm',
//                     style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
//                   ),
//                 ),
//               )
//           ],
//         ),
//       ),
//     );
//   }

//   Future<bool> _verifyCode(String enteredCode) async {
//     try {
//       var codeDoc = await FirebaseFirestore.instance
//           .collection('Cash-In')
//           .doc('6 Digit Code')
//           .get();
//       String storedCode = codeDoc.data()?['Code'] as String;
//       return storedCode == enteredCode;
//     } catch (e) {
//       print('Error verifying code: $e');
//       return false;
//     }
//   }

//   Future<void> _updateCodeAfterCashIn() async {
//     String newCode =
//         Random.secure().nextInt(1000000).toString().padLeft(6, '0');
//     await FirebaseFirestore.instance
//         .collection('Cash-In')
//         .doc('6 Digit Code')
//         .update({
//       'Code': newCode,
//     });
//     print('New 6-digit code generated and stored: $newCode');
//   }

//   Future<int> _addAmountFromBalance(int amount) async {
//     try {
//       String currentUserId = await getCurrentUserId();
//       final vendorDoc = await FirebaseFirestore.instance
//           .collection('Student-Users')
//           .doc(currentUserId)
//           .get();
//       if (!vendorDoc.exists) {
//         print('Vendor not found');
//         return 0;
//       }
//       int currentBalance = vendorDoc.get('Balance') ?? 0;
//       int updatedBalance = currentBalance + amount;
//       FirebaseFirestore db = FirebaseFirestore.instance;
//       await db.collection('Student-Users').doc(currentUserId).update({
//         'Balance': updatedBalance,
//       });
//       print('Amount deducted: $amount, Updated balance: $updatedBalance');
//       return updatedBalance;
//     } catch (e) {
//       print('Error adding amount: $e');
//       return 0;
//     }
//   }

//   Future<String> getCurrentUserId() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       return user.uid;
//     } else {
//       throw Exception('User not logged in');
//     }
//   }

//   Future<String> _fetchRfid(String userId) async {
//     try {
//       final rfidSnapshot = await FirebaseFirestore.instance
//           .collection('Student-Users')
//           .doc(userId)
//           .get();
//       if (rfidSnapshot.exists && rfidSnapshot.data() != null) {
//         return rfidSnapshot.data()!['rfid'] ?? '';
//       } else {
//         throw Exception('RFID not found for user');
//       }
//     } catch (e) {
//       throw Exception('Error fetching RFID: $e');
//     }
//   }

//   Future<void> _storeCashOutTransaction(int amount) async {
//     try {
//       String currentUserId = await getCurrentUserId();
//       String rfid = await _fetchRfid(currentUserId);

//       FirebaseFirestore db = FirebaseFirestore.instance;

//       String transactionId =
//           _generateRandomTransactionId(); // Generate transaction ID

//       Map<String, dynamic> transactionData = {
//         'type': 'Cash In',
//         'totalPrice': amount,
//         'date': FieldValue.serverTimestamp(),
//         'currentUid': currentUserId,
//         'transactionId': transactionId,
//         'rfid': rfid
//       };

//       await db
//           .collection('Transactions')
//           .doc(transactionId)
//           .set(transactionData);

//       print('Cashout transaction stored in Firestore with ID: $transactionId');
//     } catch (e) {
//       print('Error storing cashout transaction: $e');
//     }
//   }
// }