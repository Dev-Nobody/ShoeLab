import 'package:flutter/material.dart';
import 'package:fyp/pages/admin/admin_chat_room.dart';
import 'package:fyp/pages/customer/chat_Page.dart';

class VendorFeedback extends StatefulWidget {
  const VendorFeedback({super.key});

  @override
  State<VendorFeedback> createState() => _VendorFeedbackState();
}

class _VendorFeedbackState extends State<VendorFeedback> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AdminChatRoom(receiverUserEmail: 'customer@gmail.com', receiverUserId: 'customer@gmail.com'),));
            },
              child: ListTile(
            title: Text('Admin'),
          )),
        ],
      ),
    );
  }
}
