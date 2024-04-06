import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Text(
          'Profile Screen',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
