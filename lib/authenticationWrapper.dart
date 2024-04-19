import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesync/screens/home_screen.dart';
import 'package:onesync/screens/login.dart';

class AuthenticationWrapper extends StatefulWidget {
  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading indicator while checking authentication state
        }
        if (userSnapshot.hasData) {
          return HomeScreen(); // User is logged in, show home screen
        } else {
          return LoginScreen(); // User is not logged in, show login screen
        }
      },
    );
  }
}
