import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/Dashboard/cashIn_screen.dart';
import 'package:onesync/screens/Dashboard/history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1;
  int balance = 0; // Initialize balance variable
  bool _isLoading = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget buildBalanceDisplay() {
    return Container(
      width: 343,
      height: 123,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage('assets/Balance_Card.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 210,
            top: -87,
            child: Opacity(
              opacity: 0.30,
              child: Container(
                width: 269,
                height: 269,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 1, color: Color(0xFF0671E0)),
                ),
              ),
            ),
          ),
          Positioned(
            left: 28,
            top: 23,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 187.50,
                  child: Text(
                    'Your Balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 0.09,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading) const CircularProgressIndicator(),
                if (!_isLoading)
                  Text(
                    'PHP $balance',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 0.8,
                    ),
                  ),
                SizedBox(height: 16), // Added space for the button
                TextButton(
                  onPressed: () async {
                    // Await the result from the navigation
                    final updatedBalance = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CashInScreen(),
                      ),
                    );

                    // Check if the returned result is a valid balance and update if necessary
                    if (updatedBalance != null) {
                      setState(() {
                        balance = updatedBalance;
                      });
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cash In',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds a decorative circle container
  Widget buildDecorativeCircle(
      double left, double top, double size, Color color) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(width: 1, color: Color(0xFF0671E0)),
        ),
      ),
    );
  }

  // Combines various shapes and designs
  Widget buildCombinedShapesContainer() {
    return Center(
      child: SizedBox(
        width: 343,
        height: 123,
        child: Stack(
          children: [
            buildBalanceDisplay(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'OneSync POS',
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 28,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            height: 0.05,
          ),
        ),
      ),
      body: Column(
        children: [
          buildCombinedShapesContainer(),
          const SizedBox(height: 14),
          Expanded(
            // Use the TransactionHistoryScreen widget here
            child: HistoryScreen(),
          ),
        ],
      ),
      bottomNavigationBar: Navigation(),
    );
  }

  @override
  void initState() {
    super.initState();
    loadBalance(); // Fetch balance when the widget is initialized
  }

  Future<void> loadBalance() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      // Get the current user's UID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Fetch balance from Firestore
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Student-Users')
          .doc(uid)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        setState(() {
          balance = snapshot.data()!['Balance'] ?? 0; // Update balance
        });
      }
    } catch (e) {
      print('Error loading balance: $e');
      // Handle error gracefully (display an error message to the user)
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false
      });
    }
  }
}
