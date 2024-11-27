import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/pages/admin/user_page.dart';
import 'package:fyp/read%20data/get_user_name.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  List<String> docIDs = [];

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

  Future<void> disableAccount(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isDisabled': true,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account disabled successfully.')),
      );
    } catch (e) {
      print('Error disabling account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to disable account.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF161822),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Manage Users', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF161822),
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
                    onTap: () {
                      // Navigate to the UserDetailsPage with the userId
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailsPage(userId: docIDs[index]),
                        ),
                      );
                    },
                    trailing: IconButton(
                      onPressed: () {
                        // Confirm before disabling
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Disable Account'),
                              content: Text(
                                  'Are you sure you want to disable this account?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    disableAccount(docIDs[index]);
                                  },
                                  child: Text('Disable'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.block,
                        color: Colors.red,
                      ),
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
