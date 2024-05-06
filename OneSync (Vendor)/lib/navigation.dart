import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
      key: ValueKey(_selectedIndex),
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 12),
            child: SvgPicture.asset(
              'assets/Dashboard_Nav.svg',
              width: 20,
              height: 20,
              color: Color(0xFF717171),
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 12),
            child: SvgPicture.asset(
              'assets/Menu_Nav.svg',
              width: 20,
              height: 20,
              color: Color(0xFF717171),
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            padding: EdgeInsets.all(10), // Padding inside the circle
            child: Icon(
              Icons.add,
              size: 20,
              color: Colors.white,
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 12),
            child: SvgPicture.asset(
              'assets/History_Nav.svg',
              width: 20,
              height: 20,
              color: Color(0xFF717171),
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(top: 12),
            child: SvgPicture.asset(
              'assets/Profile_Nav.svg',
              width: 20,
              height: 20,
              color: Color(0xFF717171),
            ),
          ),
          label: '',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Color.fromARGB(255, 133, 133, 133),
      onTap: _onItemTapped,
    );
  }
}
