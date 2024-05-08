import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesync/firebase_options.dart';
import 'package:onesync/screens/(Auth)/authenticationWrapper.dart';
import 'package:onesync/screens/(Auth)/login.dart';

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
      debugShowCheckedModeBanner: false,
      routes: {
        '/Login': (context) => LoginScreen(),
      },
      theme: ThemeData(
          // Add your theme customizations here
          ),
      home:
          AuthenticationWrapper(), // Use AuthenticationWrapper as the first screen
    );
  }
}
