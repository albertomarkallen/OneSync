import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesync/firebase_options.dart';
import 'package:onesync/screens/(Auth)/authenticationWrapper.dart';
import 'package:onesync/screens/(Auth)/login.dart';
import 'package:onesync/screens/Forecast/sales_data_table.dart';
import 'package:onesync/screens/Home/cashout_screen.dart';
import 'package:onesync/screens/Home/inventory_tracker_screen.dart';
import 'package:onesync/screens/MenuList/add_product_screen.dart';
import 'package:syncfusion_flutter_core/core.dart';

Future<void> main() async {
  SyncfusionLicense.registerLicense(
      '@32352e302e30IuvJFe4S+IYtDWgaaM7SaYhNm4EnyUEh9hCaZ2E0ax0=');
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
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF212121), // Title color
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(
            color: Color(0xFF212121),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF212121),
          unselectedItemColor:
              Colors.grey[600], // Color for the unselected items in the navbar
        ),
      ),

      home:
          AuthenticationWrapper(), // Use AuthenticationWrapper as the first screen
    );
  }
}
