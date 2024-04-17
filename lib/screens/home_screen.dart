import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesync/navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ... (existing code for fetching product data)

  // Additional variables for dashboard metrics (仮想的ダッシュボード指標 - Kashitsu no dashubōdo shihyō)
  int totalInventory = 0;
  double totalSales = 0.0;
  String bestSellingProduct = '';

  // ... (existing code to fetch product data)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OneSync'),
      ),
      body: SingleChildScrollView(
        // Make content scrollable
        child: Column(
          children: [
            // Dashboard Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                // Wrap widgets for responsive layout
                spacing: 16.0, // Spacing between dashboard cards
                runSpacing: 16.0, // Spacing between rows of cards
                children: [
                  DashboardCard(
                    title: 'Inventory Tracker',
                    value: totalInventory
                        .toString(), // Assuming you have logic to calculate total inventory
                  ),
                  DashboardCard(
                    title: 'Sales Forecast',
                    value: totalSales.toStringAsFixed(
                        2), // Assuming you have logic to calculate total sales
                  ),
                  DashboardCard(
                    title: 'Best Selling',
                    value:
                        bestSellingProduct, // Assuming you have logic to identify best-selling product
                  ),
                  // Add more dashboard cards as needed
                ],
              ),
            ),

            // Product Listing Section (if applicable)
            // ... (Your existing code to display product list/categories)
          ],
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8.0),
          Text(value, style: const TextStyle(fontSize: 18.0)),
        ],
      ),
    );
  }
}
