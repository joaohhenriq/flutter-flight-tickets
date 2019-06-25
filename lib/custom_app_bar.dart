import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final List<BottomNavigationBarItem> bottomBarItems = [];
  final bottomNavBarItemStyle =
      TextStyle(fontStyle: FontStyle.normal, color: Colors.black);

  CustomAppBar() {
    bottomBarItems.add(BottomNavigationBarItem(
      icon: Icon(
          Icons.home,
          color: Colors.black,
        ),
        title: Text(
          "Explore",
          style: bottomNavBarItemStyle,
        )));
    bottomBarItems.add(BottomNavigationBarItem(
        icon: Icon(
          Icons.favorite,
          color: Colors.black,
        ),
        title: Text(
          "Matchlist",
          style: bottomNavBarItemStyle,
        )));
    bottomBarItems.add(BottomNavigationBarItem(
        icon: Icon(
          Icons.local_offer,
          color: Colors.black,
        ),
        title: Text(
          "Deals",
          style: bottomNavBarItemStyle,
        )));
    bottomBarItems.add(BottomNavigationBarItem(
        icon: Icon(
          Icons.notifications,
          color: Colors.black,
        ),
        title: Text(
          "Notifications",
          style: bottomNavBarItemStyle,
        )));
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: bottomBarItems,
      type: BottomNavigationBarType.fixed,
    );
  }
}
