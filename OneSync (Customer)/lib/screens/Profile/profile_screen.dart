import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/(Auth)/login.dart'; // Import your login screen
import 'package:onesync/screens/utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _signOut(BuildContext context) async {
    try {
      await signOutUser(context); // Pass the context to signOutUser
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              LoginScreen(), // Replace LoginScreen with your desired screen
        ),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Widget buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _signOut(context), // Call _signOut with context
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
          ],
        ),
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
            SizedBox(height: 20),
            buildLogoutButton(context), // Pass context to buildLogoutButton
          ],
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
