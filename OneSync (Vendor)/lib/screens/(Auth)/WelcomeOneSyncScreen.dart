import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onesync/screens/(Auth)/login.dart';

class WelcomeOneSyncScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/OneSync_Main.svg',
                width: 88.0,
                height: 88.0,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 345,
                child: Text(
                  'Welcome to OneSync!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF212121),
                    fontSize: 36,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    height: 1.2, // Adjusted for better readability
                    letterSpacing: -0.36,
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 345,
                child: Text(
                  'One tap service.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4D4D4D),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 0.08,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Example
