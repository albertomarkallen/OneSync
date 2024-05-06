import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onesync/screens/(Auth)/WelcomeOneSyncScreen.dart';

import '../utils.dart';

class SignUpStoreScreen extends StatefulWidget {
  final String email;
  final String password;

  const SignUpStoreScreen(
      {Key? key, required this.email, required this.password})
      : super(key: key);

  @override
  _SignUpStoreScreenState createState() => _SignUpStoreScreenState();
}

class _SignUpStoreScreenState extends State<SignUpStoreScreen> {
  final TextEditingController _storenameController = TextEditingController();

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
              child: Container(
                color: Colors.white,
                height: 44,
                width: 44,
                child: SvgPicture.asset('assets/OneSync_Logo.svg'),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Your Store',
                style: TextStyle(
                  color: Color(0xFF212121),
                  fontSize: 32,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Provide your store’s name.',
                style: TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 40),
              buildInputField("Store Name", _storenameController),
              const SizedBox(height: 20),
              SizedBox(height: 20),
              buildButton(context, "Finish Signing Up")
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, String label) {
    return Container(
      width: 345,
      height: 45,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Color(0xFF0671E0),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFFD8DADC)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: TextButton(
        onPressed: () async {
          // Trim whitespace and get the store name from the controller
          final String storeName = _storenameController.text.trim();

          // Check if the store name field is empty
          if (storeName.isEmpty) {
            print("Store name is empty.");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter your store’s name')),
            );
            return;
          }

          // Attempt to create an account with email, password, and store name
          User? user = await createAccountWithEmailPassword(
            widget.email,
            widget.password,
            storeName,
          );

          if (user != null) {
            // Account creation was successful, display a success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign up successful!')),
            );
            // Navigate to the welcome screen and remove all routes behind
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => WelcomeOneSyncScreen()),
            );
          } else {
            // Account creation failed, display an error message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to create account')),
            );
          }
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.black.withOpacity(0.8),
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildInputField(String label, TextEditingController controller,
      {bool isPassword = false}) {
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
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: 'Enter ' + label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0x3FABBED1), width: 1),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
