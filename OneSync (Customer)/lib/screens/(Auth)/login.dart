import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onesync/screens/(Auth)/signUp.dart';
import 'package:onesync/screens/Dashboard/dashboard_screen.dart'; // Import your dashboard screen
import 'package:onesync/screens/utils.dart'; // Ensure that signInWithEmailAndPassword is defined here or imported correctly

class LoginScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add this line

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: SvgPicture.asset(
                'assets/OneSync_Logo.svg',
                height: 44,
                width: 44,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            // Wrap the form with the form key
            key: _formKey,
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
                const SizedBox(height: 20),
                buildTextField("Email", emailController),
                const SizedBox(height: 10),
                buildTextField("Password", passwordController,
                    isPassword: true),
                const SizedBox(height: 20),
                buildButton("Log In", context),
                const SizedBox(height: 30),
                buildSignUpLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return SizedBox(
      width: 345,
      height: 55,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
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
            borderSide: BorderSide(color: Colors.red), // Red border for error
          ),
          errorStyle: TextStyle(
            color: Colors.red, // Set the text color of the error message to red
            fontSize: 14, // Set the font size of the error message
            fontFamily: 'Inter', // Set the font family of the error message
            fontWeight:
                FontWeight.w400, // Set the font weight of the error message
          ),
        ),
      ),
    );
  }

  Widget buildButton(String label, BuildContext context) {
    return Container(
      width: 345,
      height: 45,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Color(0xFF0671E0),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFD8DADC)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: TextButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // Validate the form
            // Call signInWithEmailAndPassword and handle redirection
            await signInWithEmailAndPassword(
              emailController.text,
              passwordController.text,
              (User? user) {
                if (user != null) {
                  // Redirect to dashboard upon successful login
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardScreen()),
                  );
                } else {
                  // Handle login failure
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid email or password.'),
                    ),
                  );
                }
              },
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

  Widget buildSignUpLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SignUpScreen(),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(
              color: Colors.black.withOpacity(0.69),
            ),
          ),
          Text(
            "Sign up",
            style: TextStyle(
              color: Colors.black.withOpacity(0.69),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
