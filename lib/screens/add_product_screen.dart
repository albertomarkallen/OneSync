import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _addProduct(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await signInUserAnon();
        final File? imageFile = await getImageFromGallery(context);
        if (imageFile != null) {
          // Add image handling code here (e.g., upload to Firebase Storage)

          await FirebaseFirestore.instance
              .collection('Menu')
              .doc(_nameController.text.trim())
              .set({
            'name': _nameController.text.trim(),
            'category': _categoryController.text.trim(),
            'stock': int.parse(_stockController.text.trim()),
            'price': int.parse(_priceController.text.trim()),
            // Add a reference to the image URL here if needed
          });

          Navigator.pop(context); // Navigate back after successful addition
        } else {
          print('No image selected');
        }
      } catch (e) {
        print('Error adding product: $e');
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
                child: FloatingActionButton(
                  onPressed: () async {
                    final File? selectedImage =
                        await getImageFromGallery(context);
                    if (selectedImage != null) {
                      print(selectedImage); // Future Implementation of Logic
                    } else {
                      print('No image selected');
                    }
                  },
                  backgroundColor: const Color(0xFF0671E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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

  Widget _uploadImage(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        File? selectedImage = await getImageFromGallery(context);
        if (selectedImage != null) {
          bool succes = await uploadFileForUser(selectedImage);
          print(succes);
        } else {
          print('No image selected');
        }
      },
      child: const Text('Upload Image'),
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
