import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> signInUserAnon() async {
  try {
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
    print('User signed in: ${userCredential.user!.uid}');
  } catch (e) {
    print('Error signing in: $e');
  }
}

Future<File?> getImageFromGallery(BuildContext context) async {
  try {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path); // Convert XFile to File
    }
  } catch (e) {
    print('Error getting image: $e');
    return null;
  }
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
    return true;
  } catch (e) {
    print('Error uploading file: $e');
    return false;
  }
}
