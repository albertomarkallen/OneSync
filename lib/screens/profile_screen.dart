import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/utils.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _signOut(context); // Call sign-out function
          },
          child: Text('Sign Out'),
        ),
      ),
      bottomNavigationBar: const Navigation(),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await signOutUser(); // Call your signOutUser function
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/Login',
          (route) =>
              false); // Navigate to login screen and remove all other routes
    } catch (e) {
      print('Error signing out: $e');
      // Show error message or handle error as needed
    }
  }
}
