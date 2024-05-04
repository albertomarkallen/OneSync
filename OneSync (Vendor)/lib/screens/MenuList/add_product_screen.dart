import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/MenuList/menu_screen.dart';
import 'package:onesync/screens/utils.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String _selectedCategory = 'Main Dishes';
  List<String> categoriesList = [
    'Main Dishes',
    'Snacks',
    'Beverages',
  ];

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

  Future<void> _addProduct(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        String userId = FirebaseAuth.instance.currentUser!.uid;
        String productName = _nameController.text;
        String docId = productName;

        String? uploadedFilePath = await uploadFileForUser(_uploadedImageFile!);
        if (uploadedFilePath == null) {
          throw Exception("File upload failed.");
        }

        String imageUrl = await FirebaseStorage.instance
            .ref(uploadedFilePath)
            .getDownloadURL();

        await FirebaseFirestore.instance
            .collection('Menu')
            .doc(userId)
            .collection('vendorProducts')
            .doc(docId)
            .set({
          'name': productName,
          'category': _selectedCategory,
          'stock': int.parse(_stockController.text),
          'price': int.parse(_priceController.text),
          'imageUrl': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MenuScreen()));
      } catch (e) {
        print('Error adding product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding product: $e')),
        );
      }
    }
  }

  // Add Product Screen
  @override
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
                child: _uploadImage(),
              ),
              const SizedBox(height: 44.0),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 30.0),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                    _categoryController.text = newValue;
                  });
                },
                items: categoriesList
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 30.0),
              _buildNumberFormField(_stockController, 'Stock'),
              const SizedBox(height: 30.0),
              _buildNumberFormField(_priceController, 'Price'),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () => _addProduct(context),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  backgroundColor: Color(0xFF0671E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(345, 44),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      'Update',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 0.08,
                      ),
                    ),
                  ],
                ),
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
          Stack(
            children: [
              Image.file(
                _uploadedImageFile!,
                width: double.maxFinite,
                height: 100, // Set the desired height
                fit: BoxFit
                    .cover, // Use BoxFit.cover or another fit mode as needed
              ),
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _uploadedImageFile = null;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        if (_uploadedImageFile ==
            null) // Show button only if no image is uploaded
          Container(
            width: 200,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: ShapeDecoration(
              color: const Color(0xFF0671E0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
                    const SnackBar(content: Text('No image selected')),
                  );
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
