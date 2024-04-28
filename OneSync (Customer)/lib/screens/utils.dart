import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

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

      await FirebaseAuth.instance.signInWithCredential(credential);
      print('User signed in with Google');
    } else {
      print('Google sign in aborted by user');
    }
  } catch (e) {
    print('Error signing in with Google: $e');
  }
}

Future<void> signOutUser() async {
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
