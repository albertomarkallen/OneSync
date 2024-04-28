import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsScreen extends StatefulWidget {
  final MenuItem product;

  ProductDetailsScreen({required this.product});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
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

  // Function to save changes to Firestore using the name field as an identifier
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
        });

        Navigator.of(context).pop(); // Optionally pop the current screen
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

// Function to delete the product from Firestore using the name field as an identifier
  Future<void> _deleteProduct() async {
    String productName = widget.product.name;
    FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      await db
          .collection('Menu')
          .where('name', isEqualTo: productName)
          .limit(1)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.first.reference.delete();
        }
      });
      Navigator.of(context).pop(); // Pop the ProductDetailsScreen
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Product deleted successfully!"),
        backgroundColor: Colors.green,
      ));
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
        title: Text('Edit Product'),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: constraints.maxHeight * 0.3,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price (₱)'),
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDeleteConfirmationDialog(context),
        child: const Icon(Icons.delete),
        backgroundColor: Colors.red,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _saveProductDetails,
              child: Text('Save'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.green,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red,
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
        title: Text('Delete Product'),
        content:
            Text('Are you sure you want to delete ${widget.product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteProduct(); // Call the delete function
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
