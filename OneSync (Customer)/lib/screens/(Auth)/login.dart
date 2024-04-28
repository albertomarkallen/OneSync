import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onesync/screens/(Auth)/signUp.dart';
import 'package:onesync/screens/utils.dart'; // Make sure this file correctly implements signInWithGoogle and signUpWithEmailPassword

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
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
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final String email = _emailController.text.trim();
                    final String password = _passwordController.text.trim();
                    if (email.isNotEmpty && password.isNotEmpty) {
                      try {
                        await signUpWithEmailPassword(context, email, password);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Failed to create account. Error: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please enter valid email and password')),
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Color(0xFF0671E0)),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                    elevation: MaterialStateProperty.all(
                        0), // Removing default elevation
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    minimumSize: MaterialStateProperty.all(
                        Size(345, 44)), // Setting the size
                  ),
                  child: Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                buildButton(context, "Sign In With Google"),
                const SizedBox(height: 20),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Inter',
                      color:
                          Colors.black.withOpacity(0.7), // Default text color
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: 'Sign in',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    SignUpScreen())); // This should navigate to a different screen if needed
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildButton(BuildContext context, String label) {
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
        print('Button tapped');
        await signInWithGoogle();
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.black.withOpacity(0.8),
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(
            horizontal: 12), // Adjust padding as necessary
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/Google_Icon.svg',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8), // Space between icon and text
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
