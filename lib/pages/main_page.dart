// lib/widgets/main_layout.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainPage extends StatefulWidget {
  final Widget child; // The current page content

  const MainPage({Key? key, required this.child}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Update selected index based on current route
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentRoute = Get.currentRoute;
    if (currentRoute == '/') {
      _selectedIndex = 0;
    } else if (currentRoute == '/sales_history') {
      _selectedIndex = 1;
    } else if (currentRoute == '/settings') {
      _selectedIndex = 2;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate using GetX
    switch (index) {
      case 0:
        Get.offAllNamed('/'); // Home
        break;
      case 1:
        Get.offAllNamed('/sales_history');
        break;
      case 2:
        Get.offAllNamed('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child, // This is your current page content
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
