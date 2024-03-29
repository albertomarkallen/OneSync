import 'package:flutter/material.dart';
import 'package:onesync/screens/home_screen.dart';
import 'package:onesync/screens/menu_screen.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    // Replace with actual screens you want to navigate to
    HomeScreen(),
    Text('Menu'),
    Text('Order'),
    Text('History'),
    Text('Profile'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the selected screen
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MenuScreen()),
      );
    }
    // Implement similar navigation for other screens as needed
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
      selectedItemColor: Color.fromARGB(255, 133, 133, 133),
      onTap: _onItemTapped,
    );
  }
}
