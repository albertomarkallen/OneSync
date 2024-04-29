import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart'; // Ensure this package is added if using SVG images
import 'package:onesync/screens/Dashboard/dashboard_screen.dart';

class InputRfidScreen extends StatefulWidget {
  const InputRfidScreen({Key? key}) : super(key: key);

  @override
  _InputRfidScreenState createState() => _InputRfidScreenState();
}

class _InputRfidScreenState extends State<InputRfidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rfidController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Input RFID', style: TextStyle(color: Color(0xFF212121))),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SvgPicture.asset(
              'assets/OneSync_Logo.svg', // Path to your SVG file
              height: 44, // Set your desired height
              width: 44, // Set your desired width
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: TextStyle(
                    fontFamily: 'Inter', // Adjusted to use the Inter font
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4D4D4D),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFABBED1)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: TextStyle(
                    fontFamily: 'Inter', // Adjusted to use the Inter font
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4D4D4D),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFABBED1)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _rfidController,
                decoration: InputDecoration(
                  labelText: 'Enter your reference number',
                  labelStyle: TextStyle(
                    fontFamily: 'Inter', // Adjusted to use the Inter font
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4D4D4D),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFABBED1)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter RFID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: Color(0xFF0671E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      storeRFIDInFirestore(
                        _rfidController.text,
                        _firstNameController.text,
                        _lastNameController.text,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // Button color
                    shadowColor: Colors.transparent, // No shadow
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void storeRFIDInFirestore(
      String rfid, String firstName, String lastName) async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('Student-Users').doc(uid);
        await userDocRef.set({
          'rfid': rfid,
          'firstName': firstName,
          'lastName': lastName,
        }, SetOptions(merge: true));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        print('Error: Current user not found');
      }
    } catch (e) {
      print('Error storing RFID in Firestore: $e');
    }
  }
}
