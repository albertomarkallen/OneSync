import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Variables to store product data
  String? productName;
  String? category;
  double? price;
  int? stock;
  String? selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Section
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.photo_camera, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Product Details Section
            TextField(
              decoration: const InputDecoration(hintText: 'Enter Product Name'),
              onChanged: (value) => setState(() => productName = value),
            ),
            const SizedBox(height: 16.0),

            TextField(
              decoration: const InputDecoration(hintText: 'Enter Category'),
              onChanged: (value) => setState(() => category = value),
            ),
            const SizedBox(height: 16.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(hintText: 'Enter Stock'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        setState(() => stock = int.tryParse(value)),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(hintText: 'Enter Price'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        setState(() => price = double.tryParse(value)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            const Text('Status'),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: const [
                DropdownMenuItem<String>(
                    value: 'Available', child: Text('Available')),
                DropdownMenuItem<String>(
                    value: 'Unavailable', child: Text('Unavailable')),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  selectedStatus = newValue;
                });
              },
            ),
            const SizedBox(height: 16.0),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Note: No image logic is implemented here
                  print(
                      'Saving Product: Name: $productName, Category: $category, Price: $price, Stock: $stock, Status: $selectedStatus');
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
