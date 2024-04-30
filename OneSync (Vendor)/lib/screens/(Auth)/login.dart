import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesync/screens/(Auth)/SignUpScreen.dart';
import 'package:onesync/screens/utils.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
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
              buildInputField('Email Address', _emailController),
              const SizedBox(height: 20),
              buildInputField('Password', _passwordController,
                  isPassword: true),
              const SizedBox(height: 20),
              forgotPassword(),
              const SizedBox(height: 30),
              buildLoginButton(context),
              const SizedBox(height: 20),
              signWithGoogle(context),
              const SizedBox(height: 30),
              dontHaveAnAccount(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget signWithGoogle(BuildContext context) {
    return SizedBox(
      width: 344,
      height: 86,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 18,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'or',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1, color: Color(0xFFD8DADC)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image:
                            NetworkImage("https://via.placeholder.com/24x24"),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Sign In with Google',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.800000011920929),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dontHaveAnAccount(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        );
      },
      child: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Don’t have an account? ',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 0.09,
                    ),
                  ),
                  const TextSpan(
                    text: 'Sign Up',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 0.09,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
          // Add login logic here
          final String email = _emailController.text.trim();
          final String password = _passwordController.text.trim();
          // Check if email and password are not empty
          if (email.isNotEmpty && password.isNotEmpty) {
            User? user = await signInWithEmailPassword(email, password);
            // Check if user is not null
            if (user != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor:
                      Colors.blue, // Change background color to blue
                  content: Text(
                    'Login successful!',
                    style: TextStyle(
                      color: Colors.white, // Change text color to white
                      fontFamily: 'Inter', // Change font to Inter
                    ),
                  ),
                ),
              );
              // Navigate to the next screen upon successful login
              Navigator.of(context).pushReplacementNamed('/');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor:
                      Colors.blue, // Change background color to blue
                  content: Text(
                    'Failed to log in',
                    style: TextStyle(
                      color: Colors.white, // Change text color to white
                      fontFamily: 'Inter', // Change font to Inter
                    ),
                  ),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.blue, // Change background color to blue
                content: Text(
                  'Please enter valid email and password',
                  style: TextStyle(
                    color: Colors.white, // Change text color to white
                    fontFamily: 'Inter', // Change font to Inter
                  ),
                ),
              ),
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
