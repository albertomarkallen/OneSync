import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesync/firebase_options.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/add_product_screen.dart';
import 'package:onesync/screens/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await signInUserAnon();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/addProduct': (context) => const AddProductScreen(),
        // Other routes...
      },
      theme: ThemeData(
          // Add your theme customizations here
          ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('OneSync'),
        ),
        bottomNavigationBar: const Navigation(),
      ),
    );
  }
}
