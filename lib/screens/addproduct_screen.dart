import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesync/navigation.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    // Form Validation (Implement as needed)
    if (_formKey.currentState!.validate()) {
      try {
        // Add product to Firestore with name as document ID
        await FirebaseFirestore.instance
            .collection('Menu')
            .doc(_nameController.text.trim())
            .set({
          'name': _nameController.text.trim(),
          'category': _categoryController.text.trim(),
          'stock': int.parse(_stockController.text.trim()),
          'price': int.parse(_priceController.text.trim()),
        });

        Navigator.pop(context); // Navigate back after successful addition
      } catch (e) {
        // Handle addition errors
        print('Error adding product: $e');
      }
    }
  }

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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a product name' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(hintText: 'Enter Category'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a category' : null,
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration:
                          const InputDecoration(hintText: 'Enter Stock'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a stock value' : null,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration:
                          const InputDecoration(hintText: 'Enter Price'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a price value' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: _addProduct,
                  child: const Text('Add Product'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
