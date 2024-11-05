import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp/components/Drawers/admin_drawer.dart';
import 'package:fyp/components/Drawers/drawer.dart';
import 'package:fyp/pages/admin/admin_profile.dart';
import 'package:fyp/pages/admin/category_management.dart';
import 'package:fyp/pages/admin/order_page.dart';
import 'package:fyp/pages/admin/setting_page.dart';
import 'package:fyp/pages/admin/feedback_page.dart';
import 'package:fyp/pages/admin/manage_users.dart';
import 'package:fyp/pages/admin/manage_vendor.dart';
import 'package:fyp/pages/admin/product_management.dart';
import 'package:fyp/pages/customer/chat_Page.dart';
import 'package:fyp/pages/user_profile.dart';
import 'package:fyp/read%20data/get_user_name.dart';

class AdminDashboard extends StatefulWidget {
  AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  //sign User Out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void goToProfile() {
    //pop menu drawer
    Navigator.pop(context);

    //go to settings page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  AdminProfile(), // Corrected route
      ),
    );
  }

  void goToUser() {
    //pop menu drawer
    Navigator.pop(context);

    //go to settings page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  ManageUsers(), // Corrected route
      ),
    );
  }

  void goToVendor() {
    //pop menu drawer
    Navigator.pop(context);

    //go to settings page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  ManageVendor(), // Corrected route
      ),
    );
  }

  void goToCategory() {
    //pop menu drawer
    Navigator.pop(context);

    //go to settings page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  CategoryPage(), // Corrected route
      ),
    );
  }

  void goToProduct() {
    //pop menu drawer
    Navigator.pop(context);

    //go to settings page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  ProductManagement(), // Corrected route
      ),
    );
  }
  
  void goToFeedback() {
    //pop menu drawer
    Navigator.pop(context);

    //go to settings page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  FeedbackPage(), // Corrected route
      ),
    );
  }

  void goToOrder() {
    //pop menu drawer
    Navigator.pop(context);

    //go to settings page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  OrderPage(), // Corrected route
      ),
    );
  }

  void  goToSettings() {
    //pop menu drawer
    Navigator.pop(context);

    //go to settings page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  SettingPage(), // Corrected route
      ),
    );
  }

  
  final user = FirebaseAuth.instance.currentUser!;

  //document IDs
  List<String> docIDs = [];

  //get docIds
  Future getDocId() async {
    docIDs.clear();
    await FirebaseFirestore.instance.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach(
            (document) {
          // print(document.reference);
          docIDs.add(document.reference.id);
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      //home
      appBar: AppBar(
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
      ),
      drawer: AdminDrawer(
        onProfileTap: goToProfile,
        onUserTap: goToUser,
        onVendorTap: goToVendor,
        onCategoryTap: goToCategory,
        onProductTap: goToProduct,
        onFeedbackTap:goToFeedback,
        onOrderTap:goToOrder,
          onSettings:goToSettings,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Welcome :${user.email}  to admin pannel',
              style: TextStyle(color: Colors.white),
            ),
          ),

        ],
      ),
    );
  }
}
