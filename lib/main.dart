import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesync/authenticationWrapper.dart';
import 'package:onesync/firebase_options.dart';
import 'package:onesync/screens/add_product_screen.dart';
import 'package:onesync/screens/login.dart';
import 'package:onesync/screens/sales_data_table.dart';
import 'package:onesync/screens/inventory_tracker_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/addProduct': (context) => AddProductScreen(),
        '/Login': (context) => LoginScreen(),
        '/SalesDataTable': (context) => SalesDataTable(),
        '/InventoryTracker': (context) => InventoryTrackerScreen(),
      },
      theme: ThemeData(
          // Add your theme customizations here
          ),
      home:
          AuthenticationWrapper(), // Use AuthenticationWrapper as the first screen
    );
  }
}
