import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onesync/screens/(Auth)/input_rfid_screen.dart';
import 'package:onesync/screens/(Auth)/login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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
              child: Container(
                color: Colors.white, // Sets the background color for the SVG
                height: 44,
                width: 44,
                child: SvgPicture.asset(
                  'assets/OneSync_Logo.svg',
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            // To prevent overflow in smaller screens
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Color(0xFF212121),
                      fontSize: 32,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Register your OneSync card using your PLM email.',
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
                  const SizedBox(height: 10),
                  buildTextField("Confirm Password", confirmPasswordController,
                      isPassword: true),
                  const SizedBox(height: 20),
                  buildButton(context, "Sign Up"),
                  const SizedBox(height: 30),
                  buildLoginLink(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signUpWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? newUser = userCredential.user;
        if (newUser != null) {
          await initializeUserDocument(newUser.uid);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => InputRfidScreen()),
          );
        } else {
          // Handle null user
          print("User creation failed, user is null.");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing up. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> initializeUserDocument(String uid) async {
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('Student-Users').doc(uid);
    DocumentSnapshot userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      await userDocRef.set({
        'rfid': '',
        'Balance': 0,
      }, SetOptions(merge: true));
    }
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
            } else if (label == 'Email' && !value.contains('@')) {
              return 'Please enter a valid email';
            } else if (label == 'Confirm Password' &&
                value != passwordController.text) {
              return 'Passwords do not match';
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
              color:
                  Colors.red, // Set the text color of the error message to red
              fontSize: 14, // Set the font size of the error message
              fontFamily: 'Inter', // Set the font family of the error message
              fontWeight:
                  FontWeight.w400, // Set the font weight of the error message
            ),
          ),
        ));
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
          await signUpWithEmailAndPassword(
              context, emailController.text, passwordController.text);
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

  Widget buildLoginLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account? ",
            style: TextStyle(
              color: Colors.black.withOpacity(0.69),
            ),
          ),
          Text(
            "Log in",
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

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Account Created Successfully'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Dismiss the dialog
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          child: const Text('Okay'),
        ),
      ],
    ),
  );
}
