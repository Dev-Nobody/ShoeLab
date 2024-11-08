import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:fyp/services/cart_service.dart';

class MyBottomNavbar extends StatefulWidget {
  final void Function(int)? onTap;

  MyBottomNavbar({
    super.key,
    required this.onTap,
  });

  @override
  _MyBottomNavbarState createState() => _MyBottomNavbarState();
}

class _MyBottomNavbarState extends State<MyBottomNavbar> {
  final CartService _cartService = CartService();
  late Future<int> _cartItemCount;

  @override
  void initState() {
    super.initState();
    _cartItemCount = _cartService.getCartItemCount();
  }

  // Method to refresh the cart item count
  Future<void> _refreshCartItemCount() async {
    setState(() {
      _cartItemCount = _cartService.getCartItemCount();
    });
  }

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
        // Shopping cart icon with badge
        FutureBuilder<int>(
          future: _cartItemCount,
          builder: (context, snapshot) {
            int itemCount = snapshot.data ?? 0;
            return Stack(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: Colors.grey.shade900,
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 0,
                    top:0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        itemCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        Icon(
          Icons.account_circle,
          color: Colors.grey.shade900,
        ),
      ],
      backgroundColor: Colors.grey.shade900,
      color: Colors.lightGreenAccent.shade100,
      animationDuration: Duration(milliseconds: 300),
      onTap: (value) {
        widget.onTap!(value);
        if (value == 2) {
          // Refresh the cart count when tapping the cart icon
          _refreshCartItemCount();
        }
      },
    );
  }
}
