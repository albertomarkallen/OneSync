import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart'; // Import your navigation widget
import 'package:onesync/models/models.dart';
import 'package:onesync/screens/productdetails_screen.dart';

class MenuScreen extends StatefulWidget {
  MenuScreen({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final List<MenuItem> _menuItems = [
    MenuItem(name: 'Pizza', price: 10.99, stock: 8, category: 'Main Dishes'),
    MenuItem(name: 'Burger', price: 8.99, stock: 12, category: 'Main Dishes'),
    MenuItem(name: 'Salad', price: 6.99, stock: 17, category: 'Main Dishes'),
    MenuItem(name: 'Pasta', price: 12.99, stock: 13, category: 'Main Dishes'),
    MenuItem(name: 'Sandwich', price: 7.99, stock: 4, category: 'Snacks'),
    // Add more items with 'Snacks' and 'Beverages' categories
  ];

  // For search functionality
  List<MenuItem> _displayedMenuItems = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedLabel = 'All'; // For keeping track of the active label

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

  // Filter items based on search query or category
  void _filterMenuItems(String query) {
    setState(() {
      _selectedLabel = query; // Update selected label
      _displayedMenuItems = _menuItems.where((item) {
        // Filtering logic
        if (query == 'All') return true; // Show all items
        return item.category != null &&
            item.category.toLowerCase() == query.toLowerCase();
      }).toList();
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
        title: Text(_selectedLabel), // Display current label
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show or toggle search bar
            },
          ),
          // ADD PRODUCT BUTTON
          IconButton(
            onPressed: _handleAddProduct,
            icon: const Icon(Icons.add),
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
              onChanged: (text) =>
                  _filterMenuItems(text), // Update filtering with search
              decoration: const InputDecoration(
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
                children: [
                  TextButton(
                    onPressed: () => _filterMenuItems('All'),
                    child: Text('All'),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          _selectedLabel == 'All' ? Colors.blue : Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _filterMenuItems('Main Dishes'),
                    child: Text('Main Dishes'),
                    style: TextButton.styleFrom(
                      foregroundColor: _selectedLabel == 'Main Dishes'
                          ? Colors.blue
                          : Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _filterMenuItems('Snacks'),
                    child: Text('Snacks'),
                    style: TextButton.styleFrom(
                      foregroundColor: _selectedLabel == 'Snacks'
                          ? Colors.blue
                          : Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _filterMenuItems('Beverages'),
                    child: Text('Beverages'),
                    style: TextButton.styleFrom(
                      foregroundColor: _selectedLabel == 'Beverages'
                          ? Colors.blue
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Display Products
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Change this for desired grid layout
              ),
              itemCount: _displayedMenuItems.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
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
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(
                            product: _displayedMenuItems[itemIndex],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2.0,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            // Image Placeholder (80%)
                            Expanded(
                              flex: 8, // 80% of the card's height
                              child: Container(
                                width: double.infinity, // Occupy full width
                                color: Colors.grey[200],
                                child: const Icon(Icons.image),
                              ),
                            ),
                            // Text Details (20%)
                            Expanded(
                              flex: 3, // 20% of the card's height
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_displayedMenuItems[itemIndex].name,
                                      style: const TextStyle(fontSize: 12.0)),
                                  const SizedBox(height: 4.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${_displayedMenuItems[itemIndex].stock} left',
                                        style: const TextStyle(fontSize: 10.0),
                                      ),
                                      Text(
                                        '\₱${_displayedMenuItems[itemIndex].price.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 12.0),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
