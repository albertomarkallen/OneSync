import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';

class SuccessUpdatedEmailScreen extends StatelessWidget {
  void _handleBackToLogin(BuildContext context) {
    Navigator.of(context).pushNamed('/backToLogin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/110x78'),
            ),
            SizedBox(height: 20),
            Text(
              'Email Address Updated!',
              textAlign: TextAlign.center, // Center text within its container
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your email address has been changed successfully.',
              textAlign: TextAlign.center, // Center text within its container
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 120),
            ElevatedButton(
              onPressed: () => _handleBackToLogin(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0671E0),
              ),
              child: Container(
                width: double.infinity, // Take up entire available width
                height: 44.0,
                child: Center(
                  child: Text(
                    'Back to Profile',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
