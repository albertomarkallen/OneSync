import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesync/screens/(Auth)/cardSignup.dart';

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

Future<User?> signInWithEmailPassword(String email, String password) async {
  try {
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  } catch (e) {
    print('Error signing in: $e');
    return null;
  }
}

Future<void> signUpWithEmailPassword(
    BuildContext context, String email, String password) async {
  try {
    final UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User? user = userCredential.user;
    if (user != null) {
      // Store user data in Firestore
      await FirebaseFirestore.instance
          .collection("Student-Users")
          .doc(user.uid)
          .set({'Email': user.email}, SetOptions(merge: true));

      // Navigate or perform other actions after successful signup
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => CardSignUp()),
      );
    } else {
      debugPrint('Failed to create account. User is null.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to create account, please try again.'),
      ));
    }
  } catch (e) {
    print('Error creating account with email and password: $e');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error signing up, please try again.'),
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

Future<void> signOutUser(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
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
