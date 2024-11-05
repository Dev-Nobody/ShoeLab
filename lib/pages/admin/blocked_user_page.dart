import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/pages/admin/admin_chat_room.dart';
import 'package:fyp/read%20data/get_user_name.dart';
import 'package:fyp/services/chat_service.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

    void _unblockUser(BuildContext context, String userId) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unlock User'),
          content: const Text('Are you sure you want to Unlock this User?'),
          actions: [
            // block button
            TextButton(
              onPressed: () {
                ChatService().unBlockUser(userId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User Unblocked")));
              },
              child: const Text('Unblocked'),),

            //cancel button
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),

          ],
        ),
      );
    }


    // Get the current user's email
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Blocked Users'),
          backgroundColor: Colors.grey.shade800,
        ),
        body: Center(child: Text('No authenticated user found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Blocked Users'),
        backgroundColor: Colors.grey.shade800,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getBlockedUsersStream(currentUser.email!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No blocked users found.'));
          } else {
            final blockedUsers = snapshot.data!;

            return ListView.builder(
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                final user = blockedUsers[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    tileColor: Colors.grey.shade200,
                    title: GetUserName(documentId: user['uid']), // Assuming UID is part of the user data
                    subtitle: Text(user['email'] ?? 'No Email'), // Display the email
                    onTap: () {
                      _unblockUser(context, user['uid']);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  // Get Blocked Users Stream
  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      // Get list of blocked user IDs
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

      final userDocs = await Future.wait(
        blockedUserIds.map((id) => FirebaseFirestore.instance.collection('users').doc(id).get()),
      );

      // Return a list of user data
      return userDocs.map((doc) => {
        'uid': doc.id,
        'email': doc.data()?['email'], // Assuming email is stored in this field
      }).toList();
    });
  }
}
