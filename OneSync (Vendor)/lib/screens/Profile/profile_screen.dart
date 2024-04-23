import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String vendorName = '';
  String uid = '';
  int balance = 0;
  bool _isLoading = false;

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

      if (vendorDoc.exists) {
        setState(() {
          vendorName = vendorDoc.get('Vendor Name') ?? '';
          uid = vendorDoc.get('UID') ?? '';
          balance = vendorDoc.get('Balance') ?? 0.0;
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

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Firebase sign-out
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/Login',
        (route) => false, // Navigate to login, remove other routes
      );
    } catch (e) {
      print('Error signing out: $e');
      // Show error message or handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Vendor Name: $vendorName'),
                  Text('UID: $uid'),
                  Text('Balance: $balance'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _signOut(context);
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: const Navigation(),
    );
  }

  Future<String> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not logged in');
    }
  }
}
