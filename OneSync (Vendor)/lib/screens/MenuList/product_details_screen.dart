import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:onesync/screens/MenuList/menu_screen.dart';
import 'package:onesync/screens/utils.dart';

import '../../models/models.dart';

class ProductDetailsScreen extends StatefulWidget {
  final MenuItem product;

  ProductDetailsScreen({required this.product});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String _selectedCategory = 'Main Dishes';
  List<String> categoriesList = [
    'Main Dishes',
    'Snacks',
    'Beverages',
  ];
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController =
        TextEditingController(text: widget.product.price.toStringAsFixed(2));
    _stockController =
        TextEditingController(text: widget.product.stock.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _saveProductDetails() async {
    String productName = widget.product.name;
    String userID = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      var querySnapshot = await db
          .collection('Menu')
          .doc(userID)
          .collection('vendorProducts')
          .where('name', isEqualTo: productName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var productDoc = querySnapshot.docs.first;
        await productDoc.reference.update({
          'name': _nameController.text,
          'price': double.parse(_priceController.text),
          'stock': int.parse(_stockController.text),
          'category': _selectedCategory,
        });

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Product details updated successfully!"),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No product found to update."),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to update product details: ${e.toString()}"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _saveProduct(BuildContext context) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String productName = _nameController.text;

      if (widget.product.imageUrl.isEmpty) {
        throw Exception("No image URL found. Please upload an image first.");
      }

      await FirebaseFirestore.instance
          .collection('Menu')
          .doc(userId)
          .collection('vendorProducts')
          .doc(productName) // Using product name as the document ID
          .set({
        'name': productName,
        'stock': int.parse(_stockController.text),
        'price': double.parse(_priceController.text),
        'imageUrl': widget.product.imageUrl,
        'category': _selectedCategory, // Include the category
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );

      // Navigate to the MenuScreen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MenuScreen()));
    } catch (e) {
      print('Error adding product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
      );
    }
  }

  Future<void> _deleteProduct() async {
    String productName = widget.product.name;
    String userID = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      var querySnapshot = await db
          .collection('Menu')
          .doc(userID)
          .collection('vendorProducts')
          .where('name', isEqualTo: productName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Product deleted successfully!"),
          backgroundColor: Colors.green,
        ));

        // Navigate to the MenuScreen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MenuScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No product found to delete."),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to delete product: ${e.toString()}"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Details',
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            height: 0.07,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          GestureDetector(
            onTap: () => _showDeleteConfirmationDialog(context),
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFD9544D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  'assets/Trash_Icon.svg',
                  color: Colors.white,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.product.imageUrl != null &&
                widget.product.imageUrl!.isNotEmpty)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.network(
                    widget.product.imageUrl!,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.3,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, size: 48),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        widget.product.imageUrl = ""; // Clear the image URL
                      });
                      // Optionally, delete the image from storage here
                    },
                  ),
                ],
              ),
            if (widget.product.imageUrl == null ||
                widget.product.imageUrl!.isEmpty)
              Center(
                child: Container(
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
                        try {
                          String? uploadedFilePath =
                              await uploadFileForUser(selectedImage);
                          if (uploadedFilePath == null) {
                            throw Exception("File upload failed.");
                          }

                          String imageUrl = await FirebaseStorage.instance
                              .ref(uploadedFilePath)
                              .getDownloadURL();
                          if (imageUrl.isEmpty) {
                            throw Exception("Failed to get image URL");
                          }

                          setState(() {
                            widget.product.imageUrl =
                                imageUrl; // Update the image URL in your product model
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error handling image: $e')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No image selected')),
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
              ),
            const SizedBox(height: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Name',
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
                  height: 45,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  alignment: Alignment
                      .center, // Center the content inside the Container
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Color(0x3FABBED1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: InputBorder.none, // Remove the default border
                    ),
                    style: TextStyle(
                      color: Color(0xFF4D4D4D),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Food Category',
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
                  height: 45,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Color(0x3FABBED1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                    items: categoriesList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide
                            .none, // Ensures no visible border around the dropdown
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10), // Adjusted padding
                    ),
                    style: TextStyle(
                      color: Color(0xFF4D4D4D),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                    dropdownColor: Colors.white,
                    iconSize: 24,
                    isExpanded:
                        true, // Ensures the dropdown fills the width of its parent container
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Price',
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
                  height: 45,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  alignment: Alignment
                      .center, // Center the content inside the Container
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Color(0x3FABBED1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      border: InputBorder.none, // Remove the default border
                    ),
                    style: TextStyle(
                      color: Color(0xFF4D4D4D),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock',
                  style: TextStyle(
                    color: Color(0xFF212121),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    height: 0.12,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: 345,
                  height: 45,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  alignment: Alignment
                      .center, // Center the content inside the Container
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Color(0x3FABBED1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: TextFormField(
                    controller: _stockController,
                    decoration: InputDecoration(
                      border: InputBorder.none, // Remove the default border
                    ),
                    style: TextStyle(
                      color: Color(0xFF4D4D4D),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _saveProduct(context).then((_) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MenuScreen()),
                  );
                }).catchError((error) {
                  // Handle any errors here if needed
                  print("Failed to save product: $error");
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0671E0),
                textStyle: TextStyle(fontFamily: 'Inter', fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD9544D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.white, // Set text color to white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product', style: TextStyle(fontFamily: 'Inter')),
        content:
            Text('Are you sure you want to delete ${widget.product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(fontFamily: 'Inter')),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteProduct();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFD9544D)),
            child: Text('Delete',
                style: TextStyle(fontFamily: 'Inter', color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
