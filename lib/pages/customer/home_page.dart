import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp/components/my_bottom_navbar.dart';
import 'package:fyp/pages/customer/account_page.dart';
import 'package:fyp/pages/customer/cart_page.dart';
import 'package:fyp/pages/customer/chat_Page.dart';
import 'package:fyp/pages/customer/search_page.dart';
import 'package:fyp/pages/customer/shop_page.dart';
import 'package:fyp/services/cart_service.dart';

class HomePage extends StatefulWidget {
  final int selectedIndex;

  HomePage({super.key, this.selectedIndex = 0}); // default to 0 (ShopPage)

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // sign User Out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  // Method to fetch cart items and refresh the UI
  Future<void> refreshCartItems() async {
    List<Map<String, dynamic>> updatedCartItems = await _cartService.fetchCartItems();
    setState(() {
      cartItems = updatedCartItems;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex; // Set initial selected index from parameter
    refreshCartItems(); // Initial fetch
  }

  void clearCart() {
    _cartService.clearCart();
    refreshCartItems(); // Refresh UI after clearing cart
  }

  final user = FirebaseAuth.instance.currentUser!;
  final CartService _cartService = CartService();
  List<Map<String, dynamic>> cartItems = [];

  // selected index to control the bottom navbar
  int _selectedIndex = 0;

  TextEditingController searchController = TextEditingController();

  // this method will update our selected index
  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // pages to display
  final List<Widget> _pages = [
    ShopPage(),
    const ChatPage(receiverUserEmail: 'admin@gmail.com', receiverUserId: 'admin@gmail.com'),
    const CartPage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      // home
      appBar: _selectedIndex == 0
          ? AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
            icon: Icon(
              Icons.search,
              color: Colors.lightGreenAccent.shade100,
            ),
          ),
          IconButton(
            onPressed: signUserOut,
            icon: Icon(
              Icons.logout,
              color: Colors.lightGreenAccent.shade100,
            ),
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.lightGreenAccent.shade100,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      )
          : _selectedIndex == 1
          ? AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(
              Icons.logout,
              color: Colors.lightGreenAccent.shade100,
            ),
          )
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.lightGreenAccent.shade100,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      )
          : null,

      bottomNavigationBar: MyBottomNavbar(
        onTap: (index) => navigateBottomBar(index),
      ),
      drawer: Drawer(
        backgroundColor: Colors.lightGreenAccent.shade100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                DrawerHeader(
                  child: Image.asset(
                    'lib/images/abc.png',
                    color: Colors.grey.shade900,
                    width: 300,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: Icon(Icons.home),
                    title: Text('H O M E'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: Icon(Icons.shopping_cart),
                    title: Text('C A R T'),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 25.0),
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('L O G  O U T'),
              ),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
