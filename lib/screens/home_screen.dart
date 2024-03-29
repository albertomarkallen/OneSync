import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OneSync'),
      ),
      body: const Center(
        child: Text(
          'Welcome to OneSync',
        ),
      ),
      bottomNavigationBar: Navigation(), // Add Navigation widget here
    );
  }
}
