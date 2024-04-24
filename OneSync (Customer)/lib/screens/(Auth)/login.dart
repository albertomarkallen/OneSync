import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _rfidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Log In',
                style: TextStyle(
                  color: Color(0xFF212121),
                  fontSize: 32,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter your credentials to open your account.',
                style: TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 30),
              buildInputField('RFID reference number', _rfidController),
              const SizedBox(height: 20),
              buildInputField('Password', _passwordController,
                  isPassword: true),
              const SizedBox(height: 20),
              forgotPassword(),
              const SizedBox(height: 30),
              buildLoginButton(context),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 262,
                child: SvgPicture.asset(
                  'assets/Ripple.svg',
                  fit: BoxFit
                      .cover, // or BoxFit.contain depending on your preference
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget forgotPassword() {
    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        onTap: () {
          // Add functionality for forgot password
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: Color(0xFF0663C7),
            fontSize: 14,
            fontFamily: 'Inter',
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
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: isPassword ? 'Enter your password' : 'Enter your email',
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

  Widget buildLoginButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF0671E0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        // Add login functionality here
        onPressed: () async {
          final String rfid = _rfidController.text.trim();
          final String password = _passwordController.text.trim();
          // Check if email and password are not empty
          if (rfid.isNotEmpty && password.isNotEmpty) {
            DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
                .collection('Student-Users')
                .doc(rfid)
                .get();
            // Check if user is not null
            if (documentSnapshot.exists) {
              Map<String, dynamic> userData =
                  documentSnapshot.data() as Map<String, dynamic>;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login successful!')),
              );

              Navigator.of(context).pushReplacementNamed('/');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('RFID not found')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Please enter valid email and password')),
            );
          }
        },
        child: const Text(
          'Log In',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
