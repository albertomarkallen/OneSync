import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/Profile/profile_screen.dart';

class SuccessUpdatedStoreName extends StatelessWidget {
  void _handleBackToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }

  Future<String> getImageUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    String filePath = 'profile/${user.uid}/profile_image.jpg';
    return await FirebaseStorage.instance
        .ref()
        .child(filePath)
        .getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder(
              future: getImageUrl(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey, // Placeholder while loading
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  // If an error occurs or no data is found, show the default placeholder image
                  return CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        NetworkImage('https://via.placeholder.com/110x78'),
                  );
                } else {
                  // Data is available
                  return CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(snapshot.data!),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            Text(
              'Store Name Updated!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your store name has been updated successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 120),
            ElevatedButton(
              onPressed: () => _handleBackToProfile(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0671E0),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 44.0,
                child: Center(
                  child: Text(
                    'Back to Profile',
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
