import 'package:flutter/material.dart';
import 'package:onesync/screens/Home/home_screen.dart';
import 'package:onesync/screens/MenuList/menu_screen.dart';
import 'package:onesync/screens/Order/history_screen.dart';
import 'package:onesync/screens/Order/order_screen.dart';
import 'package:onesync/screens/Profile/profile_screen.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the selected screen without replacing the current one
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) {
        if (index == 0) {
          return const HomeScreen();
        } else if (index == 1) {
          return const MenuScreen();
        } else if (index == 2) {
          return const OrderScreen();
        } else if (index == 3) {
          return const HistoryScreen();
        } else if (index == 4) {
          return const ProfileScreen();
        }
        return const HomeScreen(); // Default to HomeScreen if index is out of bounds
      }),
      (route) =>
          false, // Predicate function that always returns false, so no routes are removed
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu, color: Color(0xFF717171)),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart, color: Color(0xFF717171)),
          label: 'Order',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history, color: Color(0xFF717171)),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: Color(0xFF717171)),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color.fromARGB(255, 133, 133, 133),
      onTap: _onItemTapped,
    );
  }
}
