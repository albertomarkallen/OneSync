import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _firstName = '';
  late String _lastName = '';

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    try {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('Student-Users')
            .doc(uid)
            .get();
        Map<String, dynamic>? userData = userSnapshot.data()
            as Map<String, dynamic>?; // Cast to Map<String, dynamic>?
        if (userData != null) {
          setState(() {
            _firstName = userData['firstName'];
            _lastName = userData['lastName'];
          });
        }
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  Widget buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => signOutUser(context),
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
    String storeName =
        '$_firstName $_lastName'; // Concatenate first name and last name
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 28,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            height: 0.05,
            backgroundColor: Colors.white,
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
              'OneSync POS',
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
              storeName, // Display the concatenated store name
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
            buildLogoutButton(context),
          ],
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
