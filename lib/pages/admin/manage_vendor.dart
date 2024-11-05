import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/read%20data/get_user_name.dart';

class ManageVendor extends StatefulWidget {
  const ManageVendor({super.key});

  @override
  State<ManageVendor> createState() => _ManageVendorState();
}

class _ManageVendorState extends State<ManageVendor> {
  List<String> docIDs = [];

  Future<void> getCustomerDocIds() async {
    docIDs.clear();
    await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Vendor')
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((document) {
        docIDs.add(document.reference.id);
      });
    });
  }

  Future<void> removeVendor(String docId) async {
    try {
      // Fetch the vendor's document from Firestore to get the email
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(docId).get();
      String userEmail = userDoc['email'];

      // Delete the vendor's document from Firestore
      await FirebaseFirestore.instance.collection('users').doc(docId).delete();

      // Find the vendor's account in Firebase Authentication and delete it
      List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(userEmail);
      if (signInMethods.isNotEmpty) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email == userEmail) {
          await user.delete();
        }
      }

      setState(() {
        docIDs.remove(docId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vendor removed successfully!')),
      );
    } catch (e) {
      print('Error removing vendor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing vendor.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Vendors'),
        backgroundColor: Colors.grey.shade800,
      ),
      body: FutureBuilder(
        future: getCustomerDocIds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (docIDs.isEmpty) {
            return Center(child: Text('No vendors found.'));
          } else {
            return ListView.builder(
              itemCount: docIDs.length,
              itemBuilder: (context, index) {
                String docId = docIDs[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    tileColor: Colors.grey.shade200,
                    title: GetUserName(documentId: docId),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        removeVendor(docId);
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
