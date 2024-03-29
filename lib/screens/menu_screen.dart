import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart'; // Import your navigation widget
import 'package:flutter_routing/flutter_routing.dart';
import 'package:onesync/screens/addproduct_screen.dart';

class MenuItem {
  final String name;
  final double price;
  final int stock;
  final String imagePath;

  MenuItem(
      {required this.name,
      required this.price,
      required this.stock,
      this.imagePath = 'assets/images/placeholder.png'});
}

class MenuScreen extends StatefulWidget {
  MenuScreen({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final List<MenuItem> _menuItems = [
    MenuItem(name: 'Pizza', price: 10.99, stock: 8),
    MenuItem(name: 'Burger', price: 8.99, stock: 12),
    MenuItem(name: 'Salad', price: 6.99, stock: 17),
    MenuItem(name: 'Pasta', price: 12.99, stock: 13),
    MenuItem(name: 'Sandwich', price: 7.99, stock: 4),
    // Add more items as needed
  ];

  // For search functionality
  List<MenuItem> _displayedMenuItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _displayedMenuItems = _menuItems; // Initially display all items
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter items based on search query
  void _filterMenuItems(String query) {
    setState(() {
      _displayedMenuItems = _menuItems
          .where(
              (item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Function for handling product addition
  void _handleAddProduct() {
    Navigator.of(context).pushNamed('/addProduct');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Show or toggle search bar
            },
          ),
          // ADD PRODUCT BUTTON
          IconButton(
            onPressed: _handleAddProduct,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMenuItems,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Labels
          SizedBox(
            height: 35, // Adjust height as needed
            child: Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  TextButton(onPressed: null, child: Text('All')),
                  TextButton(onPressed: null, child: Text('Label 1')),
                  TextButton(onPressed: null, child: Text('Label 2')),
                  TextButton(onPressed: null, child: Text('Label 3')),
                ],
              ),
            ),
          ),
          // GridView for menu items
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Change this for desired grid layout
                // ... other grid configuration ...
              ),
              itemCount: _displayedMenuItems.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Add Product Button
                  return Card(
                    elevation: 2.0,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: _handleAddProduct,
                        child: const Text('Add Product'),
                      ),
                    ),
                  );
                } else {
                  final int itemIndex = index - 1;
                  return Card(
                    elevation: 2.0,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          // Image Placeholder (80%)
                          Expanded(
                            flex: 8, // 80% of the card's height
                            child: Container(
                              width: double.infinity, // Occupy full width
                              color: Colors.grey[200],
                              child: Icon(
                                  Icons.image), // Replace with image loading
                            ),
                          ),
                          // Text Details (20%)
                          Expanded(
                            flex: 3, // 20% of the card's height
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_displayedMenuItems[itemIndex].name,
                                    style: TextStyle(fontSize: 12.0)),
                                SizedBox(height: 4.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        '${_displayedMenuItems[itemIndex].stock} left',
                                        style: TextStyle(fontSize: 10.0)),
                                    Text(
                                        '\₱${_displayedMenuItems[itemIndex].price.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 12.0)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Navigation(), // Your bottom navigation widget
    );
  }
}
