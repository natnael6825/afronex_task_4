import 'package:afronex_task_4/myitems.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'catalog.dart';
import 'cart.dart';
import 'profile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int pageIndex = 0;

  List<Widget> pages = [
    CatalogScreen(),
    Cards(),
   MyItems(),
    ProfilePage(),
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: pages,
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        activeIndex: pageIndex,
        icons: [
          Icons.home,
          Icons.shopping_cart,
          Icons.badge_outlined,
          Icons.account_circle,
        ],
        inactiveColor: Colors.black.withOpacity(0.5),
        gapLocation: GapLocation.none,
        activeColor: Color.fromARGB(255, 121, 0, 169),
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 10,
        iconSize: 25,
        rightCornerRadius: 10,
        elevation: 0,
        onTap: (index) {
          setState(() {
            pageIndex = index;
          });
        },
      ),
    );
  }
}
