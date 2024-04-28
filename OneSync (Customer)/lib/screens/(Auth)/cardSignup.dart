import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onesync/screens/(Auth)/registered_screen.dart';

class CardSignUp extends StatefulWidget {
  const CardSignUp({Key? key}) : super(key: key);

  @override
  _CardSignUpState createState() => _CardSignUpState();
}

class _CardSignUpState extends State<CardSignUp> {
  final TextEditingController _referenceNumberController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: SvgPicture.asset(
                'assets/OneSync_Logo.svg', // Path to your SVG file
                height: 44, // Set your desired height
                width: 44, // Set your desired width
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Card',
                style: TextStyle(
                  color: Color(0xFF212121),
                  fontSize: 32,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter your reference number printed on your OneSync card.',
                style: TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              buildPasswordInputField("Reference Number",
                  "Enter Reference Number", _referenceNumberController),
              const SizedBox(height: 20),
              Container(
                width: 345,
                height: 44,
                decoration: ShapeDecoration(
                  color: Color(
                      0xFF0671E0), // You need to wrap color in a BoxDecoration to apply it to a container
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: ElevatedButton(
                  onPressed: _saveReferenceNumberToDatabase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.transparent, // Make button color transparent
                    shadowColor: Colors.transparent, // No shadow
                    padding: EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12), // Internal padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: Text(
                    "Continue",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white, // Ensure text color is white
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      height:
                          1.25, // Adjusted line height for better visual appearance
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

  Widget buildPasswordInputField(
      String label, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF212121),
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 345,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: Color(0x3FABBED1)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: false, // Change to true if you need to obscure text
            style: const TextStyle(
              color: Color(0xFF88939E),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF88939E),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.zero, // Remove default padding
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  void _saveReferenceNumberToDatabase() {
    String referenceNumber = _referenceNumberController.text;
    if (referenceNumber.isNotEmpty) {
      String userID = FirebaseAuth.instance.currentUser!.uid;
      FirebaseFirestore.instance.collection("Student-Users").doc(userID).set({
        'UID': referenceNumber,
      }, SetOptions(merge: true)) // Use merge to avoid overwriting other fields
          .then((value) {
        print("Reference Number Added");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    RegisteredScreen())); // Replace 'NextPage' with your actual next page widget
      }).catchError((error) => print("Failed to add reference number: $error"));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a reference number.")),
      );
    }
  }

  @override
  void dispose() {
    _referenceNumberController.dispose();
    super.dispose();
  }
}
