import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyp/components/Drawers/drawer.dart';
import 'package:fyp/components/Drawers/vendor_drawer.dart';
import 'package:fyp/components/square_tile.dart';
import 'package:fyp/pages/user_profile.dart';
import 'package:fyp/pages/vendor/add_product.dart';
import 'package:fyp/pages/vendor/product_page.dart';
import 'package:fyp/pages/vendor/vendor_feedback.dart';
import 'package:fyp/pages/vendor/vendor_order_page.dart';
import 'package:fyp/pages/vendor/vendor_profile.dart';
import 'package:fyp/read%20data/get_user_name.dart';
import 'package:lottie/lottie.dart';

class VendorDashboard extends StatefulWidget {
  VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
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
        builder: (context) =>  VendorProfile(), // Corrected route
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
        builder: (context) =>  ProductPage(), // Corrected route
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
        builder: (context) =>  VendorOrderPage(), // Corrected route
      ),
    );
  }

  void goToChat() {
    //pop menu drawer
    Navigator.pop(context);

    //go to settings page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  VendorFeedback(), // Corrected route
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
        iconTheme: IconThemeData(color:  Colors.lightGreenAccent.shade100),
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
      drawer: VendorDrawer(
        onProfileTap: goToProfile,
        onProductTap: goToProduct,
        onOrderTap: goToOrder,
        onChatTap: goToChat,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Lottie.asset('lib/animations/vendor.json')),

          SizedBox(height: 30,),
          Text(
            'Welcome :${user.email}',
            style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),
          ),


        ],
      ),
    );
  }
}
