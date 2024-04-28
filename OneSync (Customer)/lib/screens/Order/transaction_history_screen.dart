import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedIndex = 0; // Assuming 'Dashboard' is the second item

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction History',
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        centerTitle: true, // This will center the title
        backgroundColor:
            Colors.white, // Optional: sets the background color of the AppBar
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Transaction History Body',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
