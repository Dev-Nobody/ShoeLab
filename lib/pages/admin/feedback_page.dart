// FeedbackPage.dart
import 'package:flutter/material.dart';
import 'package:fyp/components/my_list_tile.dart';
import 'package:fyp/pages/admin/admin_chat_room.dart';
import 'package:fyp/read%20data/get_user_name.dart';
import 'package:fyp/services/chat_service.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final ChatService _chatService = ChatService();
  List<Map<String, String>> users = [];

  // Fetch customer and vendor data using ChatService
  Future<void> fetchUsers() async {
    final fetchedUsers = await _chatService.getCustomerAndVendorDataExcludingBlocked();
    setState(() {
      users = fetchedUsers;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Fetch users when the page is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FeedBack Page'),
        backgroundColor: Colors.grey.shade800,
      ),
      body: users.isEmpty
          ? Center(child: Text('No customers or vendors found.'))
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              tileColor: Colors.grey.shade200,
              title: GetUserName(documentId: user['uid']!),
              subtitle: Text(user['email']!),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminChatRoom(
                      receiverUserEmail: user['email']!,
                      receiverUserId: user['uid']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
