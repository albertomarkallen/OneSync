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
  final _formKey = GlobalKey<FormState>();
  String _nameError = '';
  String _priceError = '';
  String _stockError = '';
  String _categoryError = '';

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
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Product name cannot be empty. Please enter a valid product name.')));
      return;
    }

    String userId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      DocumentReference docRef = db
          .collection('Menu')
          .doc(userId)
          .collection('vendorProducts')
          .doc(widget.product.MenuItemId);

      DocumentSnapshot docSnap = await docRef.get();
      if (!docSnap.exists) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No product found to update."),
          backgroundColor: Colors.red,
        ));
        return; // Exit if no document found
      }

      await docRef.update({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
        'category': _selectedCategory,
        'imageUrl': widget.product.imageUrl
      });

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Product details updated successfully!"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to update product details: ${e.toString()}"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _saveProduct(BuildContext context) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String productName = _nameController.text.trim();

    if (productName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Product name cannot be empty. Please enter a valid product name.')),
      );
      return;
    }

    // Use a default image URL if none is provided
    String imageUrl = widget.product.imageUrl.isNotEmpty
        ? widget.product.imageUrl
        : 'https://via.placeholder.com/150';

    try {
      // Use the MenuItemId to identify the document to update
      await FirebaseFirestore.instance
          .collection('Menu')
          .doc(userId)
          .collection('vendorProducts')
          .doc(widget.product.MenuItemId)
          .update({
        'name': _nameController.text,
        'stock': int.parse(_stockController.text),
        'price': double.parse(_priceController.text),
        'imageUrl': imageUrl,
        'category': _selectedCategory,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );

      // Navigate to the MenuScreen only after successful save
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
      body: Form(
        // Wrap your body with a Form widget
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.product.imageUrl
                  .isNotEmpty) // Check if imageUrl is not empty
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.network(
                      widget.product.imageUrl,
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
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.product.imageUrl = "";
                        });
                        // Optionally, delete the image from storage here
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              if (widget.product.imageUrl.isEmpty)
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
                        File? selectedImage =
                            await getImageFromGallery(context);
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
                              SnackBar(
                                  content: Text('Error handling image: $e')),
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
              SingleChildScrollView(
                child: Column(
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
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        // Regular border
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _nameError.isEmpty
                                ? Color(0xFF4D4D4D)
                                : Colors
                                    .red, // Grey when no error, red when error
                          ),
                        ),
                        // Border shown only when the TextFormField is focused
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _nameError.isEmpty
                                ? Colors.blue
                                : Colors
                                    .red, // Blue when no error, red when error
                          ),
                        ),
                        // Border shown when an error exists
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .red), // Always red when there's an error
                        ),
                        // Border to use when the field is being interacted with and there's an error
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .red), // Red when focused and error exists
                        ),
                        errorText: _nameError.isEmpty ? null : _nameError,
                      ),
                      style: TextStyle(
                        color: Color(0xFF4D4D4D),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                      onChanged: (value) {
                        _validateProduct();
                      },
                    ),
                  ],
                ),
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
                        fillColor: Color(0xFF4D4D4D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _categoryError.isEmpty
                                ? Color(0xFF4D4D4D)
                                : Colors
                                    .red, // Change border color based on error
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _categoryError.isEmpty
                                ? Colors.blue
                                : Colors
                                    .red, // Change focused border color based on error
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: TextStyle(
                        color: Color(0xFF4D4D4D),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                      dropdownColor: Colors.white,
                      iconSize: 24,
                      isExpanded: true,
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
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      // Regular border
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _priceError.isEmpty
                              ? Colors.grey
                              : Colors
                                  .red, // Grey when no error, red when error
                        ),
                      ),
                      // Border shown only when the TextFormField is focused
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _priceError.isEmpty
                              ? Colors.blue
                              : Colors
                                  .red, // Blue when no error, red when error
                        ),
                      ),
                      // Border shown when an error exists
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Colors.red), // Always red when there's an error
                      ),
                      // Border to use when the field is being interacted with and there's an error
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .red), // Red when focused and error exists
                      ),
                      errorText: _priceError.isEmpty ? null : _priceError,
                    ),
                    style: TextStyle(
                      color: Color(0xFF4D4D4D),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                        decimal: true), // Support decimal numbers
                    onChanged: (value) {
                      _validateProduct(); // Call validation on change
                    },
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
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _stockController,
                    decoration: InputDecoration(
                      // Regular border
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _stockError.isEmpty
                              ? Color(0x3FABBED1)
                              : Colors.red,
                        ),
                      ),
                      // Border shown only when the TextFormField is focused
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _stockError.isEmpty
                              ? Colors.blue
                              : Colors
                                  .red, // Blue when no error, red when error
                        ),
                      ),
                      // Border shown when an error exists
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Colors.red), // Always red when there's an error
                      ),
                      // Border to use when the field is being interacted with and there's an error
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .red), // Red when focused and error exists
                      ),
                      errorText: _stockError.isEmpty ? null : _stockError,
                    ),
                    style: TextStyle(
                      color: Color(0xFF4D4D4D),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    keyboardType: TextInputType.number, // Ensure numeric input
                    onChanged: (value) {
                      _validateProduct(); // Call validation on change
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _validateProduct(); // Trigger validation for all inputs

                // Check if all inputs are valid
                if (_formKey.currentState!.validate() &&
                    _nameError.isEmpty &&
                    _stockError.isEmpty &&
                    _priceError.isEmpty &&
                    _categoryError.isEmpty) {
                  _saveProduct(context).then((_) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const MenuScreen()),
                    );
                  }).catchError((error) {
                    // Handle errors during the save operation
                    print("Failed to save product: $error");
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Failed to save product: $error")));
                  });
                } else {
                  // Handle form validation errors
                  if (_nameError.isNotEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(_nameError)));
                  }
                  if (_stockError.isNotEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(_stockError)));
                  }
                  if (_priceError.isNotEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(_priceError)));
                  }
                  if (_categoryError.isNotEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(_categoryError)));
                  }
                  if (_nameError.isEmpty &&
                      _stockError.isEmpty &&
                      _priceError.isEmpty &&
                      _categoryError.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text("Please correct the errors before saving.")));
                  }
                }
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

  void _validateProduct() {
    setState(() {
      // Validate product name
      _nameError = _nameController.text.trim().isEmpty
          ? 'Product name cannot be empty.'
          : '';

      // Validate stock
      int? stockValue = int.tryParse(_stockController.text.trim());
      if (stockValue == null) {
        _stockError = 'Stock Must be a Number.';
      } else if (stockValue < 0) {
        _stockError = 'Stock Cannot be Negative.';
      } else {
        _stockError = '';
      }

      // Validate price
      double? priceValue = double.tryParse(_priceController.text.trim());
      if (priceValue == null) {
        _priceError = 'Price must be a number.';
      } else if (priceValue < 0) {
        _priceError = 'Price cannot be negative.';
      } else {
        _priceError = '';
      }
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Delete Product',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${widget.product.name}?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFF0671E0),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              minimumSize: Size(100, 40),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _deleteProduct();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFFD9544D),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              minimumSize: Size(100, 40),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
