import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/components/Orders_buttons.dart';
import 'package:fyp/components/my_list_tile.dart';
import 'package:fyp/pages/customer/customer_order_page.dart';
import 'package:fyp/pages/customer/customer_setting_page.dart';
import 'package:fyp/pages/customer/home_page.dart';
import 'package:fyp/pages/customer/my_reviews.dart';
import 'package:fyp/pages/customer/try.dart';
import 'package:list_wheel_scroll_view_nls/list_wheel_scroll_view_nls.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  String? _username;
  String? _profileImageUrl;

  // Function to fetch user details from Firestore
  Future<void> fetchUserData() async {
    try {
      // Fetch the document for the current user
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.email)
          .get();

      if (userDoc.exists) {
        // Update the UI with the user data
        setState(() {
          _username = userDoc.data()?['username'] ?? 'User';
          _profileImageUrl = userDoc.data()?['profileImage'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void goToShip() {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  CustomerOrderPage(initialTabIndex: 2), // Corrected route
      ),
    );
  }
  void goToReceive() {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  CustomerOrderPage(initialTabIndex: 3,), // Corrected route
      ),
    );
  }
  void goToReview() {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  CustomerOrderPage(initialTabIndex: 4,), // Corrected route
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch the user data when the page is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreenAccent.shade100,
        elevation: 0,
        // Profile Image
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: CircleAvatar(
            radius: 50,
            backgroundImage: _profileImageUrl != null
                ? NetworkImage(_profileImageUrl!)
                : AssetImage('lib/images/user.jpg') as ImageProvider,
          ),
        ),

        // Name
        title: Text(
          '${_username ?? 'Loading...'}',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ) ,

        actions: [IconButton(onPressed: () {  Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerSettingPage(),
          ),
        );}, icon: Icon(Icons.settings))],
      ),
      backgroundColor: Colors.grey.shade900,
      body:  Column(

        children: [

          const SizedBox(height: 40,),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Orders',style: TextStyle(color: Colors.white),),
              GestureDetector(
                onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  CustomerOrderPage(initialTabIndex: 0,), // Corrected route
                    ),
                  );
                },
                  child: const Text('View All Orders >',style: TextStyle(color: Colors.white),)),

            ],
          ),

          const SizedBox(height: 20,),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                OrdersButtons(icon: Icons.payment, text: 'To Ship', onTap: goToShip),
                OrdersButtons(icon: Icons.payment, text: 'To Receive', onTap: goToReceive),
                OrdersButtons(icon: Icons.payment, text: 'To Review', onTap: goToReview),
                OrdersButtons(icon: Icons.payment, text: 'Return & Cancellations', onTap: goToShip),
              ],
            ),
          ),

          const SizedBox(height: 20,),

          //my reviews
          MyListTile(icon: Icons.reviews, text: 'My Review', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyReviewsPage(),));
          },),

          //try
          MyListTile(icon: Icons.ac_unit, text: 'sd', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Try(),));
          },),

          Container(
            height: 250,
            child: ListWheelScrollViewX(scrollDirection:Axis.horizontal,itemExtent: 200, children: [Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Container(
                    height: 400,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(52),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Name
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0, top: 30),
                              child: Text(
                               'name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            // Background logo (Category name in uppercase)
                            Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15),
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                'name'.toString().toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 80,
                                  color: Colors.grey.shade200,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Category Image
                Positioned(
                  top: 80,
                  right: 0,
                  child: Image.network(
                    'image',
                    height: 280,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            )]),
          ),

        ],
      ),
    );
  }
}
