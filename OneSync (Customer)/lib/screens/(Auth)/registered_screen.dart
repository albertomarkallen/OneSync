import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:onesync/screens/Dashboard/dashboard_screen.dart';

class RegisteredScreen extends StatelessWidget {
  const RegisteredScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: SvgPicture.asset(
                'assets/Success_Reference_Logo.svg', // Replace 'your_svg_file.svg' with your actual SVG file path
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Registered',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF0671E0),
                fontSize: 32,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                height: 1.2, // Adjusted for better visual appearance
                letterSpacing: -0.32,
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: 335,
              child: Text(
                'You may now access your card details.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF717171),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.25, // Adjusted for better visual appearance
                ),
              ),
            ),
            SizedBox(height: 32),
            buildContinueAppButton(context),
          ],
        ),
      ),
    );
  }

  Widget buildContinueAppButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      },
      child: Container(
        width: 345,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFF0671E0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Continue to App',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              height: 1.0, // Adjusted for better visual appearance
            ),
          ),
        ),
      ),
    );
  }
}
