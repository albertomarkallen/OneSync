import 'package:flutter/material.dart';
import 'package:onesync/navigation.dart';
import 'package:onesync/screens/Dashboard/transaction_history.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1;

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
        color: Colors
            .white, // Base color in case the SVG fails to load or has transparency
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
              children: const [
                SizedBox(
                  width: 187.50, // Set the width of the SizedBox to 187.50
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
                SizedBox(height: 24),
                Text(
                  'PHP 12,345',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 0.8,
                  ),
                ),
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
          'Hello, Customer!',
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
            child: TransactionHistoryScreen(),
          ),
        ],
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
