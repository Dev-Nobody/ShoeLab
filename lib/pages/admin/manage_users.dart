import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/read%20data/get_user_name.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  // List to store document IDs of customers
  List<String> docIDs = [];

  // Fetch customer documents from Firestore
  Future<void> getCustomerDocIds() async {
    docIDs.clear();
    await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Customer')
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((document) {
        docIDs.add(document.reference.id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
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
            return Center(child: Text('No customers found.'));
          } else {
            return ListView.builder(
              itemCount: docIDs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    tileColor: Colors.grey.shade200,
                    title: GetUserName(documentId: docIDs[index]),
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
