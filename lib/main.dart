import 'package:flutter/material.dart';
import 'package:onesync/firebase_options.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/addproduct_screen.dart';
// ignore: unused_import
import 'package:onesync/screens/productdetails_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
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
