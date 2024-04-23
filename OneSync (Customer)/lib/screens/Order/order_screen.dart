import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  List<Map<String, dynamic>> convertItemsToMap(List<MenuItem> items) {
    return items
        .map((item) => {
              'name': item.name,
              'price': item.price,
              'stock': item.stock,
              'imageUrl': item.imageUrl,
              'category': item.category
            })
        .toList();
  }

  Map<String, int> cart = {};
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchItems();
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
        var fetchedItems =
            snapshot.docs.map((doc) => MenuItem.snapshot(doc)).toList();

        setState(() {
          items = fetchedItems;
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
    } catch (e) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching items: $e')),
        );
      });
    }
  }

  void _filterItems(String query) {
    String lowerCaseQuery = query.toLowerCase();
    setState(() {
      items = items.where((item) {
        return item.name.toLowerCase().contains(lowerCaseQuery) ||
            item.category.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    });
  }

  void _addToCart(MenuItem item) {
    setState(() {
      if (item.stock > 0) {
        cart[item.name] = (cart[item.name] ?? 0) + 1;
        item.stock--;
      }
    });
  }

  void _removeFromCart(MenuItem item) {
    setState(() {
      if (cart[item.name]! > 0) {
        cart[item.name] = (cart[item.name] ?? 0) - 1;
        if (cart[item.name] == 0) {
          cart.remove(item.name);
        }
        item.stock++;
      }
    });
  }

  int _calculateTotal() {
    int total = 0;
    cart.forEach((key, quantity) {
      final item = items.firstWhere((item) => item.name == key);
      total += item.price * quantity;
    });
    return total;
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 40.0,
        child: TextField(
          controller: _searchController,
          onChanged: _filterItems,
          decoration: InputDecoration(
            labelText: 'Search',
            suffixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuList(BuildContext context, MenuItem item,
      Function(MenuItem) addToCart, Function(MenuItem) removeFromCart) {
    int cartQuantity = cart[item.name] ?? 0; // Get the current quantity in cart

    return InkWell(
      onTap: () {}, // Add an empty onTap for the entire card
      child: Container(
        width: 110,
        height: 115,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.lightGreen, // Light green circle color
                ),
                child: IconButton(
                  icon: cartQuantity > 0
                      ? Text(cartQuantity.toString(),
                          style: TextStyle(color: Colors.white))
                      : Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    if (cartQuantity > 0) {
                      addToCart(item);
                    } else {
                      addToCart(item);
                      setState(() {
                        cart[item.name] = 1;
                      });
                    }
                  },
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
                      onPressed: () => removeFromCart(item),
                      color: Colors.red, // Set color to red
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
                          style: const TextStyle(
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
                              style: const TextStyle(
                                color: Color(0xFF717171),
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
                              style: const TextStyle(
                                color: Color(
                                    0xFF0663C7), // Consider defining this color in your theme settings
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

  Widget _buildMenuGrid() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Change cross axis count as needed
          crossAxisSpacing: 6.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.88,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _menuList(context, items[index], _addToCart, _removeFromCart);
        },
      ),
    );
  }

  Widget? _buildTotalDisplay(BuildContext context) {
    int totalItems = cart.values
        .fold(0, (previousValue, quantity) => previousValue + quantity);
    String itemsText = totalItems == 1 ? 'Item' : 'Items';

    if (totalItems > 0) {
      return Container(
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
                    '$totalItems $itemsText',
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
                          cart: cart, items: convertItemsToMap(items)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue[800],
                  backgroundColor: Colors.white, // Button color
                  elevation: 0, // Removes shadow for a flat design
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(5), // Adjust the radius as needed
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                  child: Row(
                    children: [
                      Text(
                        'View Order',
                        style: TextStyle(color: Colors.blue[800]), // Text color
                      ),
                      Icon(
                        Icons.arrow_right_alt,
                        color: Colors.blue[800],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return null; // Return null when there are no items in the cart
    }
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
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildMenuGrid(),
        ],
      ),
      bottomNavigationBar: const Navigation(),
      bottomSheet: _buildTotalDisplay(context),
    );
  }
}
