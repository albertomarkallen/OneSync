import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/(Auth)/login.dart';
import 'package:onesync/screens/Profile/update_password.dart';
import 'package:onesync/screens/utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _signOut() async {
    try {
      await signOutUser(); // Utilizing the provided signOutUser function
      // Navigate to the login screen or any other screen after sign-out
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              LoginScreen(), // Replace LoginScreen with your desired screen
        ),
      );
    } catch (e) {}
  }

  Widget buildChangePassword(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the update password screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UpdatePasswordScreen(),
          ),
        );
      },
      child: Container(
        width: 345,
        height: 56,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 0.40, color: Color(0xFF88939E)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password',
              style: TextStyle(
                color: Color(0xFF212121),
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                height: 0.10,
              ),
            ),
            SizedBox(
              width: 18,
              height: 18,
              child: SvgPicture.asset(
                'assets/ChangePassword_Icon.svg',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLogoutButton() {
    return InkWell(
      onTap: _signOut, // Call the _signOut method when the button is tapped
      child: Container(
        width: 345,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: ShapeDecoration(
          color: Color(0xFF0671E0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                'Logout',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  height: 0.08,
                ),
              ),
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 28,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            height: 0.05,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Container(
              width: 160,
              height: 160,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://via.placeholder.com/160x160"),
                  fit: BoxFit.fill,
                ),
                shape: CircleBorder(),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'OneSync Store',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF212121),
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                height: 0.07,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Store Name',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF717171),
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 0.11,
              ),
            ),
            SizedBox(height: 40),
            buildChangePassword(context),
            SizedBox(height: 20),
            buildLogoutButton(),
          ],
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
