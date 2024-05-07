import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onesync/models/models.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/Order/cart_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<MenuItem> items = [];
  List<MenuItem> displayedItems = [];
  Set<String> categories = {'All'}; // Include 'All' for displaying all items
  String selectedCategory = 'All'; // Current selected category
  final TextEditingController _searchController = TextEditingController();
  Map<String, int> cart = {};
  bool isLoading = true;
  String _selectedLabel = 'All'; // Selected label for filter category

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _searchController.addListener(() {
      _filterItems(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchItems() async {
    try {
      String userID = FirebaseAuth.instance.currentUser!.uid;
      var snapshot = await FirebaseFirestore.instance
          .collection('Menu')
          .doc(userID)
          .collection('vendorProducts')
          .get();

      if (snapshot.docs.isNotEmpty) {
        List<MenuItem> fetchedItems = [];
        Set<String> fetchedCategories = {'All'}; // Include 'All' initially

        snapshot.docs.forEach((doc) {
          try {
            MenuItem item = MenuItem.fromSnapshot(doc);
            fetchedItems.add(item);
            fetchedCategories.add(item.category); // Add category from each item
          } catch (e) {
            print('Error processing an item from snapshot: $e');
          }
        });

        setState(() {
          items = fetchedItems;
          displayedItems = fetchedItems;
          categories = fetchedCategories; // Update categories with fetched ones
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No items found')),
          );
        });
      }
    } catch (e, stackTrace) {
      print('Error fetching items: $e');
      print('Stack Trace: $stackTrace');
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching items: $e')),
        );
      });
    }
  }

  void _filterItems(String query) {
    setState(() {
      String lowerCaseQuery = query.toLowerCase();
      displayedItems = items.where((item) {
        return (selectedCategory == 'All' ||
                item.category.toLowerCase() == selectedCategory) &&
            (item.name.toLowerCase().contains(lowerCaseQuery) ||
                item.category.toLowerCase().contains(lowerCaseQuery));
      }).toList();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      if (category.toLowerCase() == 'all') {
        selectedCategory = 'All';
        _selectedLabel = 'All'; // Reset selected label to 'All'
        displayedItems = items;
      } else {
        selectedCategory = category.toLowerCase();
        _selectedLabel = category; // Update selected label
        _filterItems(_searchController.text);
      }
    });
  }

  void _addToCart(MenuItem item) {
    if (item.stock > 0) {
      setState(() {
        cart[item.name] = (cart[item.name] ?? 0) + 1;
        item.stock--;
        _updateTotalInFirebase(); // Update total when an item is added.
      });
    }
  }

  void _removeFromCart(MenuItem item) {
    if (cart[item.name]! > 0) {
      setState(() {
        cart[item.name] = cart[item.name]! - 1;
        if (cart[item.name] == 0) {
          cart.remove(item.name);
        }
        item.stock++;
        _updateTotalInFirebase(); // Update total when an item is removed.
      });
    }
  }

  int _calculateTotal() {
    int total = 0;
    if (cart.isNotEmpty) {
      total = cart.entries
          .map((entry) =>
              items.firstWhere((item) => item.name == entry.key).price *
              entry.value)
          .reduce((value, element) => value + element);
    }

    // Update the "Total" value in Realtime Database
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child('RFID').update({'Total': total});

    return total;
  }

  void _updateTotalInFirebase() {
    int total =
        _calculateTotal(); // This method calculates the total price based on the cart.

    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child('RFID').update({'Total': total}).then((_) {
      print("Total updated to: $total");
    }).catchError((error) {
      print("Failed to update total: $error");
    });
  }

  Widget _buildFilterCategory() {
    var labels = ['All', 'Main Dishes', 'Snacks', 'Beverages'];

    return Container(
      margin: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
      child: SizedBox(
        height: 35,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: labels.map((label) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _selectedLabelCategory(label),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _selectedLabelCategory(String label) {
    bool isSelected =
        _selectedLabel == label || (label == 'All' && _selectedLabel == 'All');

    return TextButton(
      onPressed: () => _onCategorySelected(label),
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.blue,
        backgroundColor: isSelected ? Colors.blue : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: isSelected ? null : BorderSide(color: Colors.blue),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 40.0,
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8.0),
            hintText: 'Search',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF717171)),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF717171)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF717171)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: GridView.builder(
          padding: const EdgeInsets.all(12.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 1.1,
          ),
          itemCount: displayedItems.length,
          itemBuilder: (context, index) {
            return _menuList(
                context, displayedItems[index], _addToCart, _removeFromCart);
          },
        ),
      ),
    );
  }

  Widget _menuList(BuildContext context, MenuItem item,
      Function(MenuItem) addToCart, Function(MenuItem) removeFromCart) {
    int cartQuantity = cart[item.name] ?? 0;
    bool isInStock = item.stock > 0;

    return InkWell(
      onTap: isInStock ? () {} : null,
      child: Container(
        width: 110,
        height: 30,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isInStock ? Colors.white : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8), // Set rounded corners here
          border: Border.all(
            color: cartQuantity > 0
                ? Colors.blue
                : Color(
                    0xFFEEF5FC), // Change border color based on cartQuantity
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(item.imageUrl),
                      fit: BoxFit.cover,
                      colorFilter: isInStock
                          ? null
                          : ColorFilter.mode(Colors.grey, BlendMode.saturation),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2.61),
                        child: Text(
                          item.name,
                          style: TextStyle(
                            color: Color(0xFF212121),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${item.stock} left',
                              style: TextStyle(
                                color:
                                    isInStock ? Color(0xFF717171) : Colors.grey,
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '₱ ${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color:
                                    isInStock ? Color(0xFF0663C7) : Colors.grey,
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(
                    6.0), // Consistent padding around the GestureDetector
                child: GestureDetector(
                  onTap: isInStock ? () => addToCart(item) : null,
                  child: Container(
                    width:
                        25, // Specify width to keep the circle size consistent
                    height:
                        25, // Specify height to keep the circle size consistent
                    decoration: BoxDecoration(
                      color: isInStock
                          ? Color(0xFF32C997)
                          : Colors.grey.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    alignment:
                        Alignment.center, // Ensure the icon/text is centered
                    child: cartQuantity > 0
                        ? Text(
                            cartQuantity.toString(),
                            style: TextStyle(color: Colors.white),
                          )
                        : Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: cartQuantity > 0 ? () => removeFromCart(item) : null,
                child: Container(
                  width: 25, // Match the size with the add button
                  height: 25, // Match the size with the add button
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cartQuantity > 0 ? Color(0xFFFF594F) : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center, // Ensure the icon is centered
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalDisplay() {
    int totalItems = cart.values
        .fold(0, (previousValue, quantity) => previousValue + quantity);
    String itemText = totalItems == 1
        ? 'Item'
        : 'Items'; // Correctly use singular or plural form

    return totalItems > 0
        ? Container(
            color: Color(0xFF0671E0),
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$totalItems $itemText', // Use the variable for singular/plural form
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Total: ₱${NumberFormat('#,##0').format(_calculateTotal())}',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartScreen(
                              cart: cart,
                              items: items
                                  .map((item) => {
                                        'name': item.name,
                                        'price': item.price,
                                        'stock': item.stock,
                                        'imageUrl': item.imageUrl,
                                        'category': item.category
                                      })
                                  .toList(),
                              onUpdateCart: (Map<String, int> updatedCart) {
                                setState(() {
                                  cart = updatedCart;
                                });
                              }),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue[800],
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'View Order',
                          style: TextStyle(color: Colors.blue[800]),
                        ),
                        Icon(
                          Icons.arrow_right_alt,
                          color: Colors.blue[800],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Make an Order',
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 28,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: <Widget>[
          if (cart.isNotEmpty) // Check if the cart is not empty
            Container(
              width: 70,
              height: 32,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFFEEF5FC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    cart.clear();
                    items.forEach((item) =>
                        item.stock = 10); // Reset stock for demonstration
                    _updateTotalInFirebase(); // Update total when the cart is cleared.
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFF0671E0),
                  padding: const EdgeInsets.all(
                      0), // Remove padding as container has its own
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterCategory(),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildMenuGrid(),
        ],
      ),
      bottomNavigationBar: const Navigation(),
      bottomSheet: _buildTotalDisplay(),
    );
  }
}
