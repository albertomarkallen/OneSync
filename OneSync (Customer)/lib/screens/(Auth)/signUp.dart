import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onesync/screens/utils.dart'; // Ensure that signUpWithGoogle is defined here or import correctly

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sign Up',
                style: TextStyle(
                  color: Color(0xFF212121),
                  fontSize: 32,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Register your OneSync card using your PLM email.',
                style: TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20), // Spacing before the button
              buildButton(context, "Sign Up With Google"),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, String label) {
    return Container(
      width: 344,
      height: 44,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFFD8DADC)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: TextButton(
        onPressed: () async {
          print('Button tapped');
          try {
            await signUpWithGoogle(
                context); // Assuming signUpWithGoogle is defined and works correctly
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to sign in: $e')),
            );
          }
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.black.withOpacity(0.8),
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/Google_Icon.svg',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 8), // Space between icon and text
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
