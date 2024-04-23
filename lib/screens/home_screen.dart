import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesync/navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variables for dashboard metrics
  int totalInventory = 0;
  double totalSales = 0.0;
  String bestSellingProduct = '';

  // Function for navigation
  void _navigateToSalesDataTable() {
    Navigator.of(context).pushNamed('/SalesDataTable');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OneSync'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dashboard Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                children: [
                  DashboardCard(
                    title: 'Inventory Tracker',
                    value: totalInventory.toString(),
                  ),
                  DashboardCard(
                    title: 'Sales Forecast',
                    value: totalSales.toStringAsFixed(2),
                  ),
                  DashboardCard(
                    title: 'Best Selling',
                    value: bestSellingProduct,
                  ),
                ],
              ),
            ),

            // Button to View Sales Data Table
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _navigateToSalesDataTable,
                child: const Text('View Sales Data Table'),
              ),
            ),

            // Example Product Listing Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Product Listing',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  // Replace this with logic to fetch products from your data source (e.g., Firestore)
                  FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('products')
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else {
                          return ListView.builder(
                              shrinkWrap:
                                  true, // Important for use inside a column
                              physics:
                                  const NeverScrollableScrollPhysics(), // Prevent scrolling of the list
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot productDoc =
                                    snapshot.data!.docs[index];
                                return ListTile(
                                  title: Text(productDoc['name']),
                                  subtitle: Text('Price: \$' +
                                      productDoc['price'].toString()),
                                );
                              });
                        }
                      }),
                ],
              ),
            ),
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
