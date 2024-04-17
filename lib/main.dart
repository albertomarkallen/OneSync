import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/addproduct_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/addProduct': (context) => AddProductScreen(),
        // Other routes...
      },
      theme: ThemeData(
          // Add your theme customizations here
          ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('OneSync'),
        ),
        bottomNavigationBar: Navigation(),
      ),
    );
  }
}
