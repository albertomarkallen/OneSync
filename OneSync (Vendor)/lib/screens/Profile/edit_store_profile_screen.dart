import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesync/screens/utils.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _imageFile; // Variable to store the selected image file
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _storeNameController = TextEditingController();

  void _handleImageUpload(File imageFile) {
    setState(() {
      _imageFile = imageFile;
    });
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    super.dispose();
  }

  // Make sure to handle the async operations properly and manage state changes.
  Future<void> _editProfile(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        String userID = FirebaseAuth.instance.currentUser!.uid;
        String storeName = _storeNameController.text;
        String docID = storeName.toString();
        
        // Define the path to the user's product subcollection
        var userProductsRef = FirebaseFirestore.instance
            .collection('Menu') // Main collection
            .doc(userID) // Document for each user
            .collection('vendorProducts') // Subcollection for user's products
            .doc(docID);

        // Add a new product to the user's subcollection
        await userProductsRef.set({
          'name': storeName,
          'imageUrl': '',
        }).then((documentReference) async {
          if (_imageFile != null) {
            bool fileUploaded = await uploadFileForUser(_imageFile!);
            if (fileUploaded) {
              await userProductsRef
                  .update({'imageUrl': 'uploaded_image_url_here'});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product added successfully')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error uploading image')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product added successfully')),
            );
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error adding product')),
        );
      }
    }
  }

  // Edit Store Screen
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clickable Container for Image Upload
              Center(
              child: GestureDetector(
                onTap: () async {
                  // Use ImagePicker to select an image
                  final pickedImage =
                      await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    _handleImageUpload(File(pickedImage.path));
                  }
                },
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(238, 245, 252, 0.925),
                    border: Border.all(color: const Color.fromRGBO(158, 158, 158, 1)),
                    borderRadius: BorderRadius.circular(100),
                    
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : Center(child: Icon(Icons.add_a_photo)),
                ),
              ),
            ),
              SizedBox(height: 32.0),
              // Label for input field
            Text(
              'Store Name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10), // Add spacing between label and input field
              Align(
                alignment: Alignment.center,
                child:                
                TextFormField(
                  controller: _storeNameController,
                  decoration: InputDecoration(
                    labelText: 'OneSync',
                    floatingLabelBehavior: FloatingLabelBehavior.never, // Keep label in place
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color:Color.fromRGBO(65, 150, 240, 100)), // Set focused border color to blue
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromRGBO(171, 190, 209, 25)), // Set enabled border color to blue
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16), // Adjust padding
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a store name';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _editProfile(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0671E0),
                  ),
                  child: Container(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}