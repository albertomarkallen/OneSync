import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesync/navigation.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Store product data fetched from Firestore
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItems(); // Load initial data
    _listenForChanges(); // Set up real-time updates
  }

  // Fetch menu items from Firestore
  Future<void> _fetchItems() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('Menu').get();
      items.clear();

      for (final doc in snapshot.docs) {
        items.add({
          'category': doc.get('category'),
          'name': doc.get('name'),
          'price': doc.get('price'),
          'stock': doc.get('stock'),
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      // Update loading state regardless of success or failure
      setState(() {
        isLoading = false;
      });
    }
  }

  // Listen for real-time database changes
  void _listenForChanges() {
    FirebaseFirestore.instance
        .collection('Menu')
        .snapshots()
        .listen((snapshot) {
      items.clear();
      snapshot.docs.forEach((doc) {
        items.add({
          'category': doc.get('category'),
          'name': doc.get('name'),
          'price': doc.get('price'),
          'stock': doc.get('stock'),
        });
      });
      setState(() {
        isLoading = false;
      });
    });
  }

  // Function to navigate to 'Add Product' screen
  void _handleAddProduct() {
    Navigator.of(context).pushNamed('/addProduct');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OneSync'),
        actions: [
          IconButton(
            onPressed: _handleAddProduct,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: items.length + 1, // +1 for the 'Add Product' card
              itemBuilder: (context, index) {
                if (index == 0) {
                  // First item is the "Add Product" card
                  return Card(
                    elevation: 2.0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: IconButton(
                        onPressed: _handleAddProduct,
                        iconSize: 40.0,
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  );
                } else {
                  // Display product cards as before
                  final int itemIndex = index - 1;
                  return InkWell(
                    onTap: () {
                      // Navigate to product details (To Follow yung Implementation)
                    },
                    child: Card(
                      elevation: 2.0,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(items[itemIndex]['name'],
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8.0),
                            Text('Category: ${items[itemIndex]['category']}'),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${items[itemIndex]['stock']} left',
                                  style: const TextStyle(fontSize: 12.0),
                                ),
                                Text(
                                  '\₱${items[itemIndex]['price'].toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
      bottomNavigationBar: Navigation(),
    );
  }
}
