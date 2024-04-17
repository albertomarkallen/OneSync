import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';

class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Test Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            const Text(
              'Fill Up the form to create an account.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),

            // Email address
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 15),

            // Password
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 15),

            // Confirm Password
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Confirm Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 30),

            // Checkbox for Terms
            Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                const Text('I accept the terms and privacy policy'),
              ],
            ),
            const SizedBox(height: 20),

            // Create Account Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Colors.white, // Temporary Hardcoding
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Create Account'),
            ),
            const SizedBox(height: 30),

            // Sign Up with Google
            Text(
              'OR Sign Up with Google',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
