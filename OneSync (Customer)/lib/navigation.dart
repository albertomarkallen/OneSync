import 'package:flutter/material.dart';
import 'package:onesync/screens/Dashboard/dashboard_screen.dart';
import 'package:onesync/screens/Dashboard/transaction_history_screen.dart';
import 'package:onesync/screens/Profile/profile_screen.dart';

class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        if (index == 0) {
          return const HistoryScreen();
        } else if (index == 1) {
          return const DashboardScreen();
        } else if (index == 2) {
          return const ProfileScreen();
        }
        return const DashboardScreen();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color.fromARGB(255, 133, 133, 133),
      onTap: _onItemTapped,
    );
  }
}
