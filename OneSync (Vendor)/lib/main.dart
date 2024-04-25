import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesync/firebase_options.dart';
import 'package:onesync/screens/(Auth)/authenticationWrapper.dart';
import 'package:onesync/screens/(Auth)/login.dart';
import 'package:onesync/screens/Forecast/sales_data_table.dart';
import 'package:onesync/screens/Home/cashout_screen.dart';
import 'package:onesync/screens/MenuList/add_product_screen.dart';
import 'package:onesync/screens/Home/inventory_tracker_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/addProduct': (context) => const AddProductScreen(),
        '/Login': (context) => LoginScreen(),
        '/SalesDataTable': (context) => const SalesDataTable(),
        '/InventoryTracker': (context) => InventoryTrackerScreen(),
        '/Cashout': (context) => CashOutScreen(),
      },
      theme: ThemeData(
          // Add your theme customizations here
          ),
      home:
          AuthenticationWrapper(), // Use AuthenticationWrapper as the first screen
    );
  }
}
