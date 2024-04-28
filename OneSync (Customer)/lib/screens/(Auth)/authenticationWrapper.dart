import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesync/screens/(Auth)/login.dart';
import 'package:onesync/screens/Dashboard/dashboard_screen.dart';
import 'package:onesync/screens/(Auth)/input_rfid_screen.dart'; // Import inputRfidScreen

class AuthenticationWrapper extends StatefulWidget {
  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State {
  late User? _user;

  @override
  void initState() {
    super.initState();
    // Listen for changes in authentication state
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      // User is not logged in, show login screen
      return LoginScreen();
    } else {
      // Check if user has inputted RFID
      return FutureBuilder<DocumentSnapshot>(
        future: getUserDocument(_user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show loading indicator
          }
          if (snapshot.hasError || !(snapshot.data!.exists)) {
            // Error or user document doesn't exist, redirect to inputRfidScreen
            return InputRfidScreen();
          } else {
            // User document exists, check RFID
            var rfid = snapshot.data!['rfid'] ?? '';
            if (rfid.isEmpty) {
              // RFID is empty, redirect to inputRfidScreen
              return InputRfidScreen();
            } else {
              // RFID is not empty, redirect to dashboard
              return DashboardScreen();
            }
          }
        },
      );
    }
  }

  Future<DocumentSnapshot> getUserDocument(String uid) async {
    try {
      return await FirebaseFirestore.instance
          .collection('Student-Users')
          .doc(uid)
          .get();
    } catch (e) {
      print('Error getting user document: $e');
      throw e;
    }
  }
}
