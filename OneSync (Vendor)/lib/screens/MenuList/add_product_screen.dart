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

        String? uploadedFilePath;
        if (_uploadedImageFile != null) {
          uploadedFilePath = await uploadFileForUser(_uploadedImageFile!);
        }

        String imageUrl = uploadedFilePath != null
            ? await FirebaseStorage.instance
                .ref(uploadedFilePath)
                .getDownloadURL()
            : 'https://via.placeholder.com/150';

        // Create a new document with an auto-generated ID
        DocumentReference newMenuItem = FirebaseFirestore.instance
            .collection('Menu')
            .doc(userId)
            .collection('vendorProducts')
            .doc(); // This will automatically generate a new ID

        // Use the auto-generated ID if you need it elsewhere
        String menuItemId = newMenuItem.id;

        await newMenuItem.set({
          'name': productName,
          'category': _selectedCategory,
          'stock': int.parse(_stockController.text),
          'price': int.parse(_priceController.text),
          'imageUrl': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Product added successfully',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),
          ),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MenuScreen()));
      } catch (e) {
        print('Error adding product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error adding product: $e',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),
          ),
        );
      }
    }
  }

  // Add Product Screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Product',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            height: 0.07,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Form(
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
              const SizedBox(height: 80.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  Text(
                    'Product Name',
                    textAlign:
                        TextAlign.start, // Align text to the start (left)
                    style: TextStyle(
                      color: Color(0xFF212121),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: 345,
                    height: 65,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey), // Grey border
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      controller: _nameController,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter Product Name',
                        hintStyle: TextStyle(
                          color: Color(0xFF4D4D4D),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Product Name';
                        }
                        if (value.length < 3) {
                          return 'Name must be at least 3 characters long';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30.0),
              SizedBox(
                width: 345, // Adjust the width as needed
                child: DropdownButtonFormField<String>(
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
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Color(0xFF212121),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Product Category',
                    labelStyle: TextStyle(
                      color: Color(0xFF212121),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              _buildNumberFormField(_stockController, 'Product Stock'),
              const SizedBox(height: 12.0),
              _buildNumberFormField(_priceController, 'Price'),
              const SizedBox(height: 16.0),
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
                        fontFamily: 'Inter',
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
      )),
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
                        fontFamily: 'Inter',
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
    String capitalizeFirstLetter(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          capitalizeFirstLetter(label),
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        Container(
          width: 345,
          height: 65,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.start,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter ${capitalizeFirstLetter(label)}',
              hintStyle: TextStyle(
                color: Color(0xFF4D4D4D),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            validator: (value) => value!.isEmpty
                ? 'Please Enter a ${capitalizeFirstLetter(label)} value'
                : null,
          ),
        ),
      ],
    );
  }
}
