import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/utils.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List<Reference> uploadedFiles = [];
  File? _uploadedImageFile;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Make sure to handle the async operations properly and manage state changes.
  Future<void> _addProduct(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        String userID = FirebaseAuth.instance.currentUser!.uid;
        String productName = _nameController.text;
        String docID = productName.toString();
        // Define the path to the user's product subcollection
        var userProductsRef = FirebaseFirestore.instance
            .collection('Menu') // Main collection
            .doc(userID) // Document for each user
            .collection('vendorProducts') // Subcollection for user's products
            .doc(docID);

        // Add a new product to the user's subcollection
        await userProductsRef.set({
          'name': productName,
          'category': _categoryController.text,
          'stock': int.parse(_stockController.text),
          'price': int.parse(_priceController.text),
          'imageUrl': '',
        }).then((documentReference) async {
          if (_uploadedImageFile != null) {
            bool fileUploaded = await uploadFileForUser(_uploadedImageFile!);
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

  // Add Product Screen
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: 195,
                height: 48,
                child: _uploadImage(), // Using the custom FAB for image upload
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16.0),
              _buildNumberFormField(_stockController, 'Stock'),
              const SizedBox(height: 16.0),
              _buildNumberFormField(_priceController, 'Price'),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _addProduct(context),
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Navigation(),
    );
  }

  Widget _uploadImage() {
    return Column(
      children: [
        if (_uploadedImageFile != null)
          Image.file(_uploadedImageFile!, fit: BoxFit.cover),
        Container(
          width: 200,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: ShapeDecoration(
            color: const Color(0xFF0671E0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: InkWell(
            onTap: () async {
              File? selectedImage = await getImageFromGallery(context);
              if (selectedImage != null) {
                setState(() {
                  _uploadedImageFile = selectedImage;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No image selected')));
              }
            },
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Upload Image',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

// Helper method to build a number form field
  Widget _buildNumberFormField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: (value) =>
          value!.isEmpty ? 'Please enter a $label value' : null,
    );
  }
}
