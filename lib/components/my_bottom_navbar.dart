import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class MyBottomNavbar extends StatelessWidget {
  void Function(int)? onTap;

   MyBottomNavbar({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      items: [
        Icon(
          Icons.home,
          color: Colors.grey.shade900,
        ),
        Icon(
          Icons.chat,
          color: Colors.grey.shade900,
        ),
        Icon(
          Icons.shopping_cart,
          color: Colors.grey.shade900,
        ),
        Icon(
          Icons.account_circle,
          color: Colors.grey.shade900,
        ),
      ],
      backgroundColor: Colors.grey.shade900,
      color: Colors.lightGreenAccent.shade100,
      animationDuration: Duration(milliseconds: 300),
      onTap: (value) => onTap!(value),
    );
  }
}
