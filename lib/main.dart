import 'package:flutter/material.dart';
import 'sales_data_table.dart'; // Import your table widget

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales Data',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SalesDataTable(), // Set your table as the home screen
    );
  }
}
