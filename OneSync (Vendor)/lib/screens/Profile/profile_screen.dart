import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/Profile/edit_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String vendorName = '';
  String uid = '';
  int balance = 0;
  bool _isLoading = false;
  String email = '';

  @override
  void initState() {
    super.initState();
    _fetchVendorData();
  }

  Future<void> _fetchVendorData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String currentUserId = await getCurrentUserId();
      final vendorDoc = await FirebaseFirestore.instance
          .collection('Menu')
          .doc(currentUserId)
          .get();

      var user = FirebaseAuth.instance.currentUser;
      String userEmail = user?.email ?? "No email";

      if (vendorDoc.exists) {
        setState(() {
          vendorName = vendorDoc.data()?['Vendor Name'] ?? '';
          uid = vendorDoc.data()?['UID'] ?? '';
          balance = vendorDoc.data()?['Balance'] ?? 0;
          email = userEmail;
        });
      } else {
        print('Vendor profile not found');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not logged in');
    }
  }

  void _handleChangeStoreProfile(BuildContext context) {
    Navigator.of(context).pushNamed('/editProfile');
  }

  void _handleChangePassword(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditPasswordScreen()),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/Login',
        (route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
              color: Color(0xFF212121),
              fontSize: 28,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              height: 0.05),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _handleChangeStoreProfile(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(238, 245, 252, 0.925),
                        border: Border.all(
                            color: const Color.fromRGBO(158, 158, 158, 1)),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      vendorName,
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: [
                          ListTile(
                            leading: Icon(Icons.card_membership_outlined),
                            title: Text(uid),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          ListTile(
                            leading: Icon(Icons.email),
                            title: Text(email),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          ListTile(
                            leading: Icon(Icons.lock),
                            title: Text('Password'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () => _handleChangePassword(context),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _signOut(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0671E0),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 44.0,
                        child: Center(
                          child: Text(
                            'Logout',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
