import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:only_job/views/constants/constants.dart';
import 'package:only_job/views/home/profileJS.dart';

import '../../chatFeature/mainChatPage.dart';

class HomePageJS extends StatefulWidget {
  @override
  _HomePageJSState createState() => _HomePageJSState();
}

class _HomePageJSState extends State<HomePageJS> {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    ProfileScreen(),
    ChatPage(),
    AddPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        color: backgroundblack,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: GNav(
            gap: 8,
            iconSize: 24,
            padding: EdgeInsets.all(16),
            duration: Duration(milliseconds: 300),
            tabBackgroundColor: Colors.grey.shade800,
            color: backgroundwhite,
            activeColor: backgroundwhite,
            tabs: [
              GButton(
                icon: Icons.person,
                text: 'Profile',
              ),
              GButton(
                icon: Icons.chat,
                text: 'Chat',
              ),
              GButton(
                icon: Icons.add,
                text: 'Add',
              ),
            ],
            selectedIndex: _currentIndex,
            onTabChange: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}

// Checking the navigation
class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MainChatPage();

  }
}

class AddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Add Page'),
    );
  }
}
