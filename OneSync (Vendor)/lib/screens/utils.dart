import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

Future<User?> createAccountWithEmailPassword(
  String email,
  String password,
  String storeName,
) async {
  try {
    final UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    String userId = userCredential.user!.uid;

    User? user = userCredential.user;
    await user!.updateProfile(displayName: storeName);
    await FirebaseFirestore.instance.collection('Menu').doc(userId).set({
      'email': email,
      'Vendor Name': storeName,
    });
    return user;
  } catch (e) {
    print('Error creating account: $e');
    return null;
  }
}

Future<bool> changePassword(String newPassword) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.updatePassword(newPassword);
      print('Password updated successfully.');
      return true; //
    } else {
      print('No user signed in.');
      return false;
    }
  } catch (e) {
    print('Error changing password: $e');
    return false;
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

Future<String?> uploadFileForUser(File file) async {
  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception("User ID is null");

    final storageRef = FirebaseStorage.instance.ref();
    final fileName = file.path.split('/').last;
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final uploadRef =
        storageRef.child('$userId/uploads/products/$timestamp-$fileName');

    await uploadRef.putFile(file);
    return '$userId/uploads/products/$timestamp-$fileName';
  } catch (e) {
    print('Error uploading file: $e');
    return null;
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

Future<void> uploadProfileImage(XFile imageFile) async {
  if (imageFile == null) {
    print('No image selected.');
    return;
  }

  File file = File(imageFile.path);
  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception("User ID is null");

    final storageRef = FirebaseStorage.instance.ref();

    final uploadRef = storageRef.child('$userId/profile/profile_image.jpg');

    await uploadRef.putFile(file);
    print('Profile image uploaded successfully.');
  } catch (e) {
    print('Error uploading profile image: $e');
  }
}

Future<List<Reference>?> getUserUploadedProfileImage() async {
  try {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('No user logged in');
      return null;
    }

    final storageRef = FirebaseStorage.instance.ref();
    final list = await storageRef.child('$userId/profile/').list();
    return list.items;
  } catch (e) {
    print('Error getting user uploaded profile image: $e');
    return null;
  }
}
