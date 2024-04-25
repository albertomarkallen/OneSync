import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:image_picker/image_picker.dart';

Future<User?> createAccountWithMicrosoftEmail() async {
  try {
    // Construct the authorization URL
    const String authorizationBaseUrl = 'https://login.microsoftonline.com';
    const String clientId = "00bc8e6a-7d9a-4ccc-9c67-2efbab68c243";

    const String authorizationUrl =
        "$authorizationBaseUrl/common/oauth2/v2.0/authorize?client_id=$clientId&response_type=token&redirect_uri=login.microsoftonline.com&response_mode=query&scope=https://graph.microsoft.com/user.read&state=12345&nonce=678910";
    // Authenticate via a web browser
    final result = await FlutterWebAuth.authenticate(
      url: authorizationBaseUrl,
      callbackUrlScheme: 'login.microsoftonline.com',
    );

    final accessToken = Uri.parse(result).queryParameters['access_token'];

    final OAuthCredential credential =
        OAuthProvider('microsoft.com').credential(accessToken: accessToken);
    await FirebaseAuth.instance.signInWithCredential(credential);

    return FirebaseAuth.instance.currentUser;
  } catch (e) {
    print('Error creating account with Microsoft: $e');
    return null;
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
