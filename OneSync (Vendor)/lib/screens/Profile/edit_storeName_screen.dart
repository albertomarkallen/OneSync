import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/Profile/success_update_StoreName.dart';

class EditStoreNameScreen extends StatefulWidget {
  @override
  _EditStoreNameScreenState createState() => _EditStoreNameScreenState();
}

class _EditStoreNameScreenState extends State<EditStoreNameScreen> {
  final TextEditingController newStoreNameController = TextEditingController();
  final TextEditingController confirmStoreNameController =
      TextEditingController();

  bool _isNewStoreNameValid = true;

  Future<bool> updateStoreName(String newStoreName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in.');
        return false;
      }
      String currentUserId = user.uid;

      // Update the store name in the Firestore document
      await FirebaseFirestore.instance
          .collection('Menu')
          .doc(currentUserId)
          .update({'Vendor Name': newStoreName});

      return true; // Return true if the update is successful
    } catch (e) {
      print('Error updating store name: $e');
      return false; // Return false if there is an error during the update
    }
  }

  void _handleUpdateStoreName(BuildContext context) async {
    String newStoreName = newStoreNameController.text;
    String confirmStoreName = confirmStoreNameController.text;

    bool namesMatch = newStoreName == confirmStoreName;

    setState(() {
      _isNewStoreNameValid = namesMatch;
    });

    if (!namesMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ensure both store names match.')),
      );
      return;
    }

    try {
      // Get the current user and user ID from Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user logged in.')),
        );
        return;
      }
      String currentUserId =
          user.uid; // Directly use the UID of the current user

      // Get the vendor document from Firestore
      final vendorDoc = await FirebaseFirestore.instance
          .collection('Menu')
          .doc(currentUserId)
          .get();

      if (!vendorDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No store information found.')),
        );
        return;
      }

      // Assuming a method exists to update the store name
      bool result = await updateStoreName(newStoreName);
      if (result) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SuccessUpdatedStoreName()),
        );
      } else {
        throw Exception('Failed to update store name.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update store name. Try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Store Name'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Store Name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: newStoreNameController,
              decoration: InputDecoration(
                labelText: 'Enter New Store Name',
                errorText:
                    !_isNewStoreNameValid ? 'Store names must match.' : null,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isNewStoreNameValid
                        ? Color.fromRGBO(65, 150, 240, 100)
                        : Colors.red,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isNewStoreNameValid ? Colors.grey : Colors.red,
                  ),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Confirm Store Name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: confirmStoreNameController,
              decoration: InputDecoration(
                labelText: 'Confirm Store Name',
                errorText:
                    !_isNewStoreNameValid ? 'Store names must match.' : null,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isNewStoreNameValid
                        ? Color.fromRGBO(65, 150, 240, 100)
                        : Colors.red,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isNewStoreNameValid ? Colors.grey : Colors.red,
                  ),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleUpdateStoreName(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0671E0),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 44.0,
                child: Center(
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
