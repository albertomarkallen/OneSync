import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesync/navigation.dart';

class InventoryTrackerScreen extends StatefulWidget {
  const InventoryTrackerScreen({Key? key}) : super(key: key);

  @override
  _InventoryTrackerScreenState createState() => _InventoryTrackerScreenState();
}

class _InventoryTrackerScreenState extends State<InventoryTrackerScreen> {
  late List<DocumentSnapshot> _productDocs = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      String userID = FirebaseAuth.instance.currentUser!.uid;
      var snapshot = await FirebaseFirestore.instance
          .collection('Menu')
          .doc(userID)
          .collection('vendorProducts')
          .orderBy('stock')
          .get();

      setState(() {
        _productDocs = snapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching products')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inventory Tracker',
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 28,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _productDocs != null
            ? _buildProductList()
            : const Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: const Navigation(),
    );
  }

  Widget _buildProductList() {
    if (_productDocs == null || _productDocs.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ListView.builder(
        itemCount: _productDocs.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final productDoc = _productDocs[index];
          final String productName = productDoc['name'];
          final int stock = productDoc['stock'];

          double stockPercentage = stock / 60;

          Color indicatorColor;
          if (stockPercentage < 0.17) {
            indicatorColor = Color(0xFFFF5A4F);
          } else if (stockPercentage >= 0.17 && stockPercentage <= 0.5) {
            indicatorColor = Color(0xFFFFC670);
          } else {
            indicatorColor = Color(0xFF4196F0);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex:
                      5, // Increased from 3 to 5 to give more space to product names
                  child: Text(
                    productName,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(
                  width:
                      150, // Adjust the width of LinearProgressIndicator as needed
                  child: LinearProgressIndicator(
                    value: stockPercentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                    minHeight: 10,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '$stock/60',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: indicatorColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
