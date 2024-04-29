import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesync/screens/(Auth)/cardSignup.dart';
import 'package:onesync/screens/(Auth)/login.dart';

Future<void> signUpWithGoogle(BuildContext context) async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    print(
        "Google User: $googleUser"); // Debug: Check if user object is received

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      print(
          "Firebase User: $user"); // Debug: Check if Firebase user object is received

      if (user != null) {
        String UserID = user.uid;
        await FirebaseFirestore.instance
            .collection("Student-Users")
            .doc(UserID)
            .set({'Name': user.displayName}, SetOptions(merge: true));

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => CardSignUp()),
        );
      } else {
        debugPrint('Failed to sign in. User is null.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to sign in, please try again.'),
        ));
      }
    } else {
      print('Google sign in aborted by user');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sign in aborted by user.'),
      ));
    }
  } catch (e) {
    print('Error signing in with Google: $e');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error signing in, please try again.'),
    ));
  }
}

Future<void> signInWithGoogle() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        print('User signed in with Google UID: ${user.uid}');
      } else {
        print('Failed to sign in. User is null.');
      }
    } else {
      print('Google sign in aborted by user');
    }
  } catch (e) {
    print('Error signing in with Google: $e');
  }
}

Future<void> signInWithEmailAndPassword(
    String email, String password, void Function(User?) completion) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = userCredential.user;

    // Pass the user to the completion callback
    completion(user);
  } catch (e) {
    print('Error signing in: $e');

    // Check for specific error messages
    if (e is FirebaseAuthException) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        // Handle invalid email or password error
        print('Invalid email or password');
        completion(null);
      } else {
        // Handle other errors
        print('Unexpected error: $e');
        completion(null);
      }
    } else {
      // Handle unexpected errors
      print('Unexpected error: $e');
      completion(null);
    }
  }
}

Future<bool> hasInputtedRFID(String uid) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Student-Users')
        .doc(uid)
        .get();

    // Check if RFID field is empty or null
    return (snapshot.exists &&
        snapshot.data() != null &&
        snapshot.data()!['rfid'] != null &&
        snapshot.data()!['rfid'] != '');
  } catch (e) {
    print('Error checking RFID input: $e');
    return false; // Return false if error occurs
  }
}

Future<void> storeUIDInFirestore(String uid) async {
  try {
    // Reference to Firestore collection
    CollectionReference studentUsers =
        FirebaseFirestore.instance.collection('Student-Users');

    // Check if the user document already exists
    DocumentSnapshot<Map<String, dynamic>> snapshot = await studentUsers
        .doc(uid)
        .get() as DocumentSnapshot<Map<String, dynamic>>;

    if (!snapshot.exists || snapshot.data() == null) {
      // If the document doesn't exist, create it with initial values
      await studentUsers.doc(uid).set({
        'uid': uid,
        'rfid': '', // Initialize "rfid" as empty string
        'Balance': 0,
      });
      print('New user document created in Firestore');
    } else {
      // If the document exists, retain existing RFID value
      String existingRfid = snapshot.data()!['rfid'] ??
          ''; // Get existing RFID value, or default to empty string
      await studentUsers.doc(uid).update({
        'uid': uid,
        'rfid': existingRfid, // Retain existing RFID value
      });
      print('Existing user document updated in Firestore');
    }

    print('UID stored in Firestore');
  } catch (e) {
    print('Error storing UID in Firestore: $e');
  }
}

Future<void> signOutUser(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    // Clear navigation history and prevent going back to logged-in state
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false, // Prevent going back to previous screen
    );
  } catch (e) {
    print('Error signing out: $e');
  }
}

Future<File?> getImageFromGallery(BuildContext context) async {
  try {
    final ImagePicker picker = ImagePicker();
    // Pick an image
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path); // Convert XFile to File
    }
  } catch (e) {
    print('Error getting image: $e');
  }
  return null;
}

Future<bool> uploadFileForUser(File file) async {
  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final storageRef = FirebaseStorage.instance.ref();
    final fileName = file.path.split('/').last;
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final uploadRef =
        storageRef.child('$userId/uploads/products/$timestamp-$fileName');
    await uploadRef.putFile(file);
    return await uploadRef.getDownloadURL().then((value) {
      print('File uploaded to: $value');
      return true;
    });
  } catch (e) {
    print('Error uploading file: $e');
    return false;
  }
}

Future<List<Reference>?> getUserUploadedFiles() async {
  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final storageRef = FirebaseStorage.instance.ref();
    final list = await storageRef.child('$userId/uploads/products').list();
    return list.items;
  } catch (e) {
    print('Error getting user uploaded files: $e');
    return null;
  }
}
