import 'package:flutter/material.dart';
import 'package:onesync/screens/Dashboard/dashboard_screen.dart';
import 'package:onesync/screens/Order/history_screen.dart';
import 'package:onesync/screens/Profile/profile_screen.dart';

class Navigation extends StatefulWidget {
  final int selectedIndex;

  const Navigation({super.key, required this.selectedIndex});

  @override
  // ignore: library_private_types_in_public_api
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  late int _selectedIndex; // Changed to late initialization

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex =
        widget.selectedIndex; // Initialize _selectedIndex from widget

    // Populate the list of screens
    _screens.addAll([
      HistoryScreen(
        selectedIndex: 0,
      ),
      DashboardScreen(selectedIndex: 1), // Removed unnecessary selectedIndex
      ProfileScreen(selectedIndex: 2), // Removed unnecessary selectedIndex
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.history,
                color: _selectedIndex ==
                        0 // Changed selectedIndex to _selectedIndex
                    ? Theme.of(context).primaryColor
                    : Color(0xFF717171)),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard,
                color: _selectedIndex ==
                        1 // Changed selectedIndex to _selectedIndex
                    ? Theme.of(context).primaryColor
                    : Color(0xFF717171)),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
                color: _selectedIndex ==
                        2 // Changed selectedIndex to _selectedIndex
                    ? Theme.of(context).primaryColor
                    : Color(0xFF717171)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
