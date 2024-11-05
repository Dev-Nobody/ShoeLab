import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountInformation extends StatefulWidget {
  const AccountInformation({super.key});

  @override
  State<AccountInformation> createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  // Fetch user details from Firestore
  Future<void> fetchUserDetails() async {
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.email)
          .get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data(); // Store the fetched data
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserDetails(); // Fetch user details when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Information'),
        backgroundColor: Colors.grey.shade500,
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Username: ${userData!['username'] ?? 'N/A'}',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'Email: ${userData!['email'] ?? 'N/A'}',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'Phone Number: ${userData!['phoneNumber'] ?? 'N/A'}',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'Address: ${userData!['address'] ?? 'N/A'}',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey.shade900, // Set the background color
    );
  }
}
