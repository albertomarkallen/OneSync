import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesync/firebase_options.dart';
import 'package:onesync/screens/(Auth)/login.dart';
import 'package:onesync/screens/Dashboard/dashboard_screen.dart';

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
        '/Login': (context) => LoginScreen(),
      },
      theme: ThemeData(
          // Add your theme customizations here
          ),
      home: DashboardScreen(), // Use AuthenticationWrapper as the first screen
    );
  }
}
