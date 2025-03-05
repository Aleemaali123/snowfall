import 'package:chtapp/bottom_bar/profile_page.dart';
import 'package:flutter/material.dart';

import '../screens/show_request.dart';
import '../screens/request.dart';
import 'Homepage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int _currentIndex = 0;

  final List<Widget> pages = [
    StatusTabScreen(),
    UserRequestPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFEF4), // ✅ Light greenish blue color

      body: IndexedStack(
        index: _currentIndex,
        children:
        pages
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
          onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
              label: 'Home'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.request_page_sharp),
                label: 'Request'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile'
            ),
          ]
      ),
    );
  }
}
