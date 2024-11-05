import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/pages/admin/admin_dashboard.dart';
import 'package:fyp/pages/customer/home_page.dart';
import 'package:fyp/pages/auth/login_or_register_page.dart';
import 'package:fyp/pages/vendor/vendor_dashboard.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  //future to fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails(User user) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(user.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (authSnapshot.hasData) {
            User? user = authSnapshot.data;

            if (user == null) {
              return LoginOrRegisterPage();
            }

            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: getUserDetails(user),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}'));
                }

                if (userSnapshot.hasData) {
                  Map<String, dynamic>? userData = userSnapshot.data?.data();

                  if (userData == null) {
                    return Center(child: Text('No data available'));
                  }

                  String currentRole = userData['role'];

                  if (currentRole == 'Customer') {
                    return HomePage();
                  } else if (currentRole == 'Vendor' ) {
                    return VendorDashboard();
                  } else if (currentRole == 'Admin' ) {
                    return AdminDashboard();
                  } else {
                    return Center(child: Text('No role found'));
                  }
                } else {
                  return Center(child: Text('No data available'));
                }
              },
            );
          } else {
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
