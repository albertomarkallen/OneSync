import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesync/screens/(Auth)/login.dart';
import 'package:onesync/screens/utils.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SignUpForm(),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
            // Add sign up logic here
            final String email = _emailController.text.trim();
            final String password = _passwordController.text.trim();

            if (email.isNotEmpty && password.isNotEmpty) {
              User? user =
                  await createAccountWithEmailPassword(email, password);
              if (user != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sign up successful!')),
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to create account')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please enter valid email and password')),
              );
            }
          },
          child: const Text('Sign Up'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(const MaterialApp(
    home: SignUpScreen(),
  ));
}
