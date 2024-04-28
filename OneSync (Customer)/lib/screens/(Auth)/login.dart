import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:onesync/screens/(Auth)/signUp.dart';
import 'package:onesync/screens/utils.dart'; // Ensure that signInWithEmailAndPassword is defined here or imported correctly
import 'package:onesync/screens/Dashboard/dashboard_screen.dart'; // Import your dashboard screen

class LoginScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add this line

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const SizedBox(height: 10),
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
    return TextFormField(
      // Changed to TextFormField
      controller: controller,
      obscureText: isPassword,
      validator: (value) {
        // Add validator
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget buildButton(String label, BuildContext context) {
    return Container(
      width: 344,
      height: 44,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
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
      child: Text(
        "Don't have an account? Sign up",
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
