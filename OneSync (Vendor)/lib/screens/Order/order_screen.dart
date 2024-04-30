import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      print('User ID: $userID');
      var snapshot = await FirebaseFirestore.instance
          .collection('Menu')
          .doc(userID)
          .collection('vendorProducts')
          .get();

      if (snapshot.docs.isNotEmpty) {
        List<MenuItem> fetchedItems = [];
        snapshot.docs.forEach((doc) {
          MenuItem item = MenuItem.snapshot(doc);
          fetchedItems.add(item);
          categories.add(item.category); // Add category to the set
        });

        setState(() {
          items = fetchedItems;
          displayedItems = fetchedItems;
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
      });
    }
  }

  void _removeFromCart(MenuItem item) {
    if (cart[item.name]! > 0) {
      setState(() {
        cart[item.name] = (cart[item.name] ?? 0) - 1;
        if (cart[item.name] == 0) {
          cart.remove(item.name);
        }
        item.stock++;
      });
    }
  }

  int _calculateTotal() {
    return cart.entries
        .map((entry) =>
            items.firstWhere((item) => item.name == entry.key).price *
            entry.value)
        .reduce((value, element) => value + element);
  }

  Widget _buildFilterCategory() {
    return Container(
      margin: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
      child: SizedBox(
        height: 35,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _selectedLabelCategory(category),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _selectedLabelCategory(String label) {
    return TextButton(
      onPressed: () => _onCategorySelected(label),
      style: TextButton.styleFrom(
        foregroundColor: _selectedLabel == label ? Colors.white : Colors.blue,
        backgroundColor: _selectedLabel == label ? Colors.blue : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: _selectedLabel == label ? null : BorderSide(color: Colors.blue),
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
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF717171)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF717171)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0), // Add bottom padding here
        child: GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 6.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.88,
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
    int cartQuantity = cart[item.name] ?? 0; // Get the current quantity in cart

    bool isInStock = item.stock > 0;

    return InkWell(
      onTap: isInStock ? () {} : null, // Disable onTap if out of stock
      child: Container(
        width: 110,
        height: 115,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: isInStock
              ? Colors.white
              : Colors.grey.shade300, // Gray out if no stock
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 0.26,
              color: Color(0x514D4D4D),
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                child: IconButton(
                  icon: cartQuantity > 0
                      ? Text(cartQuantity.toString(),
                          style: TextStyle(color: Colors.blue))
                      : Icon(Icons.add,
                          color: isInStock
                              ? Colors.blue
                              : Colors.grey), // Change color if no stock
                  onPressed: isInStock
                      ? () {
                          if (cartQuantity > 0) {
                            addToCart(item);
                          } else {
                            addToCart(item);
                          }
                        }
                      : null, // Disable button if no stock
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: isInStock
                          ? () => removeFromCart(item)
                          : null, // Disable button if no stock
                      color: isInStock
                          ? Colors.red
                          : Colors.grey, // Change color if no stock
                    ),
                  ],
                ),
                Container(
                  width: 110,
                  height: 80,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(item.imageUrl),
                      fit: BoxFit.fill,
                      colorFilter: isInStock
                          ? null
                          : ColorFilter.mode(
                              Colors.grey,
                              BlendMode
                                  .saturation), // Apply gray scale if no stock
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
                            fontSize: 10,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8), // Aligns with the name above
                            child: Text(
                              '${item.stock} left',
                              style: TextStyle(
                                color: isInStock
                                    ? Color(0xFF717171)
                                    : Colors.grey, // Change color if no stock
                                fontSize: 9,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '₱ ${item.price.toStringAsFixed(2)}', // Format price to two decimal places
                              style: TextStyle(
                                color: isInStock
                                    ? Color(0xFF0663C7)
                                    : Colors.grey, // Change color if no stock
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalDisplay() {
    int totalItems = cart.values
        .fold(0, (previousValue, quantity) => previousValue + quantity);
    return totalItems > 0
        ? Container(
            color: Colors.blue[700], // Use a deep blue color for the background
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
                        '$totalItems Items',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Total: ₱${_calculateTotal()}',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue[800],
                      backgroundColor: Colors.white, // Button color
                      elevation: 0, // Removes shadow for a flat design
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            5), // Adjust the radius as needed
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'View Order',
                          style:
                              TextStyle(color: Colors.blue[800]), // Text color
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
        title: const Text('Order',
            style: TextStyle(
                color: Color(0xFF212121),
                fontSize: 28,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                height: 0.05)),
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
