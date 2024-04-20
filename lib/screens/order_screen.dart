import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/cart_screen.dart';
import 'package:onesync/models/models.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<MenuItem> items = [];
  List<Map<String, dynamic>> convertItemsToMap(List<MenuItem> items) {
  return items.map((item) => {
    'name': item.name,
    'price': item.price,
    'stock': item.stock,
    'imageUrl': item.imageUrl,
    'category': item.category
  }).toList();
}
  Map<String, int> cart = {};
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<MenuItem> displayedItems = [];

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
        var fetchedItems = snapshot.docs.map((doc) => MenuItem.snapshot(doc)).toList();

        setState(() {
          items = fetchedItems;
          displayedItems = List.from(fetchedItems);
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
      displayedItems = items.where((item) {
        return item.name.toLowerCase().contains(lowerCaseQuery);
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
      padding: const EdgeInsets.all(16.0),
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
    );
  }

  Widget _menuList(BuildContext context, MenuItem item, Function(MenuItem) addToCart, Function(MenuItem) removeFromCart) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () => addToCart(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Image.network(
                item.imageUrl, // Using the image URL from the item
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock: ${item.stock}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '₱${item.price}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (cart.containsKey(item.name) && cart[item.name]! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => removeFromCart(item),
                      icon: Icon(Icons.remove_circle_outline, color: Colors.blue[800]),
                    ),
                    Text(
                      ' ${cart[item.name]}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      onPressed: () => addToCart(item),
                      icon: Icon(Icons.add_circle_outline, color: Colors.blue[800]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget? _buildTotalDisplay(BuildContext context) {
    int totalItems = cart.values.fold(0, (previousValue, quantity) => previousValue + quantity);
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
    builder: (context) => CartScreen(cart: cart, items: convertItemsToMap(items)),
  ),
);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue[800],
                  backgroundColor: Colors.white, // Button color
                  elevation: 0, // Removes shadow for a flat design
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Adjust the radius as needed
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
        title: const Text('Order'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 0.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: displayedItems.length,
                    itemBuilder: (context, index) {
                      MenuItem item = displayedItems[index];
                      return _menuList(context, item, _addToCart, _removeFromCart);
                    },
                  ),
                ),
        ],
      ),
      bottomNavigationBar: Navigation(),
      bottomSheet: _buildTotalDisplay(context),
    );
  }
}
