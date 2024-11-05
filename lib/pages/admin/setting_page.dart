import 'package:flutter/material.dart';
import 'package:fyp/components/my_list_tile.dart';
import 'package:fyp/pages/admin/admin_chat_room.dart';
import 'package:fyp/pages/admin/blocked_user_page.dart';
import 'package:fyp/services/chat_service.dart';

class SettingPage extends StatelessWidget {
  SettingPage({super.key});

  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('S E T T I N G S'),
      ),
      body: Column(
        children: [
          Container(
            child: GestureDetector(
              child: Text('BLOCKED USERS'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlockedUsersPage(),
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

// C O NTI NUE VI D EO FR OM 37.02 M IT CH KOK O THEN RETURN TO 1:24:27 Thanks
