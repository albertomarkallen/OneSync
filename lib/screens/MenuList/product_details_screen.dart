import 'package:flutter/material.dart';

import '../../models/models.dart';

class ProductDetailsScreen extends StatefulWidget {
  final MenuItem product;

  ProductDetailsScreen({required this.product});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmationDialog(context),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Center(
                child: Container(
                  height: constraints.maxHeight * 0.3,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 16.0),

              // Product Name
              Text(
                widget.product.name,
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),

              // Price
              Text(
                '\₱${widget.product.price.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 8.0),

              // Stock
              Text(
                'Stock: ${widget.product.stock}',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),

              // Description
              const Text(
                'Description:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4.0),
              const Text(
                'Add a description of the product here.',
                style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DeleteProductConfirmationDialog(
        productName: widget.product.name,
        onDeleteConfirmed: () {
          // Implement logic to delete the product
          print('Product deleted: ${widget.product.name}');
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Pop the ProductDetailsScreen
        },
      ),
    );
  }
}

// Basic Delete Confirmation Dialog
class DeleteProductConfirmationDialog extends StatelessWidget {
  final String productName;
  final VoidCallback onDeleteConfirmed;

  DeleteProductConfirmationDialog({
    required this.productName,
    required this.onDeleteConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Product'),
      content: Text('Are you sure you want to delete $productName?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onDeleteConfirmed,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('Delete'),
        ),
      ],
    );
  }
}
