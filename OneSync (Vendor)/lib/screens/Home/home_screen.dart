import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/Home/cashout_screen.dart';

class CondensedSalesDataTable extends StatelessWidget {
  final int totalSales;
  final int totalTransactions;

  const CondensedSalesDataTable({
    Key? key,
    required this.totalSales,
    required this.totalTransactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Data Table',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Total Sales: $totalSales',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
            ),
          ),
          Text(
            'Total Transactions: $totalTransactions',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DocumentSnapshot> _productDocs = [];
  int _balance = 0;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchBalance();
  }

  Future<void> _fetchProducts() async {
    try {
      String userID = FirebaseAuth.instance.currentUser!.uid;
      var snapshot = await FirebaseFirestore.instance
          .collection('Menu')
          .doc(userID)
          .collection('vendorProducts')
          .orderBy('stock')
          .limit(5)
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

  Future<void> _fetchBalance() async {
    try {
      String currentUserId = await getCurrentUserId();

      final vendorDoc = await FirebaseFirestore.instance
          .collection('Menu')
          .doc(currentUserId)
          .get();

      if (vendorDoc.exists) {
        setState(() {
          _balance = vendorDoc.get('Balance') ?? 0;
        });
      } else {
        print('Vendor profile not found');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  double _calculateContainerHeight() {
    const double itemHeight = 24.0;
    const double paddingHeight = 16.0 * 2;
    return (_productDocs.length * itemHeight) + paddingHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'OneSync',
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 28,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            height: 0.05,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue, // Set the background color to blue
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Balance',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color:
                                    Colors.white, // Set the text color to white
                              ),
                            ),
                            Text(
                              'PHP $_balance', // Use your balance variable here
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize:
                                    36.0, // Increased font size for balance
                                fontWeight: FontWeight.bold,
                                color:
                                    Colors.white, // Set the text color to white
                              ),
                            ),
                          ],
                        ),
                      ),
                      VerticalDivider(
                        color: Colors.white, // Divider color
                        thickness: 1,
                        indent: 10,
                        endIndent: 10,
                        width: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CashOutScreen(),
                              ),
                            ).then((updatedBalance) {
                              if (updatedBalance != null) {
                                setState(() {
                                  _balance =
                                      updatedBalance; // Update the balance in your state
                                });
                              }
                            });
                          },
                          child: Text(
                            'Cash Out',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Text color is blue
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side:
                                BorderSide(color: Colors.white), // Border color
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/InventoryTracker');
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventory Tracker',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      height: _calculateContainerHeight(),
                      child: SingleChildScrollView(
                        child: _buildProductList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/SalesDataTable');
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales Forecast',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(
                        child: Text(
                          'Sales Forecast Data',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Navigation(),
    );
  }

  Widget _buildProductList() {
    if (_productDocs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
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
                  flex: 3,
                  child: Text(
                    productName,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
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

  Future<String> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not logged in');
    }
  }
}
