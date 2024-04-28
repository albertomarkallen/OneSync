import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesync/screens/Dashboard/dashboard_screen.dart';

class InputRfidScreen extends StatefulWidget {
  @override
  _InputRfidScreenState createState() => _InputRfidScreenState();
}

class _InputRfidScreenState extends State<InputRfidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rfidController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input RFID'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _rfidController,
                decoration: InputDecoration(
                  labelText: 'RFID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter RFID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    storeRFIDInFirestore(_rfidController.text);
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void storeRFIDInFirestore(String rfid) async {
    try {
      // Get current user's UID
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        // Reference to the current user's document in Firestore
        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('Student-Users').doc(uid);

        // Update RFID and Balance fields in the document
        await userDocRef.set(
            {
              'rfid': rfid,
              'balance': 0, // Set initial balance to 0
            },
            SetOptions(
                merge:
                    true)); // Use merge option to update only specified fields

        // Navigate back to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        // User not found, handle the case accordingly
        print('Error: Current user not found');
      }
    } catch (e) {
      print('Error storing RFID in Firestore: $e');
    }
  }
}
