import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';

class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order'),
      ),
      body: Center(
        child: Text(
          'Order Screen',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
      bottomNavigationBar: Navigation(), // Add Navigation widget here
    );
  }
}
