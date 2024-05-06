import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/Profile/profile_screen.dart';

class EditRFIDScreen extends StatelessWidget {
  final TextEditingController rfidController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user

    return Scaffold(
      appBar: AppBar(
        title: Text('Update RFID'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RFID',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: rfidController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Enter RFID',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromRGBO(65, 150, 240, 100)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromRGBO(171, 190, 209, 25)),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (user != null) {
                  FirebaseFirestore.instance
                      .collection('Menu')
                      .doc(user.uid)
                      .set({
                    'UID': rfidController.text
                        .trim() // Ensure RFID is not saved with extra whitespace
                  }).then((value) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                            SnackBar(content: Text('RFID successfully saved')))
                        .closed
                        .then((reason) {
                      // Navigate to ProfileScreen and remove all previous routes
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()),
                        (Route<dynamic> route) =>
                            false, // Remove all routes below
                      );
                    });
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save RFID: $error')));
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No user logged in')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0671E0),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 44.0,
                child: Center(
                  child: Text(
                    'Save RFID',
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
