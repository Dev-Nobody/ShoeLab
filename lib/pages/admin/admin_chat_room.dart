import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyp/components/chat_bubble.dart';
import 'package:fyp/components/chat_textfield.dart';
import 'package:fyp/components/my_textfield.dart';
import 'package:fyp/services/chat_service.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;

class AdminChatRoom extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserId;

  const AdminChatRoom(
      {super.key,
        required this.receiverUserEmail,
        required this.receiverUserId});

  @override
  State<AdminChatRoom> createState() => _AdminChatRoomState();
}

class _AdminChatRoomState extends State<AdminChatRoom> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  //textField focus
  FocusNode myFocusNode = FocusNode();

  //send message
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserId, _messageController.text);

      _messageController.clear();
    }
    scrollDown();
  }

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(
            () {
          if (myFocusNode.hasFocus) {
            //cause a delay so that the keyboard has time to show up
            // then the amount of remaining space will be calculated
            // then scroll down
            Future.delayed(
              const Duration(milliseconds: 500),
                  () => scrollDown(),
            );
          }
        });

    //wait a bit for listview to be
    Future.delayed(
      const Duration(milliseconds: 500),() => scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  //scroll controller
  final ScrollController _scrollController = ScrollController();

  void scrollDown() {
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('chat'),
      ),
      backgroundColor: Colors.black,
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildMessageList(),
              ),
              _buildMessageInput(),
              SizedBox(height: 15,)
            ],
          ),
        ),
      ),
    );
  }


  //build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.receiverUserId, _firebaseAuth.currentUser!.email!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if data is null
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text(
                'No messages yet.',
                style: TextStyle(color: Colors.white),
              ));
        }

        // Log for debugging
        print("Snapshot data: ${snapshot.data}");

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map<Widget>((document) {
            return _buildMessageItem(document);
          }).toList(),
        );
      },
    );
  }

  //build message item
  //build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderId'] == _firebaseAuth.currentUser!.email!;
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.email!)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
          (data['senderId'] == _firebaseAuth.currentUser!.email!)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisAlignment:
          (data['senderId'] == _firebaseAuth.currentUser!.email!)
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ChatBubble(
                message: data['message'],
                imageUrl: data['imageUrl'], // Pass image URL here
                messageId: document.id,
                userId: data['senderId'],
                isCurrentUser: isCurrentUser,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //build message input
  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: ChatTextfield(
            controller: _messageController,
            obscureText: false,
            focusNode: myFocusNode,
            hintText: 'Enter a message',),
        ),
        IconButton(
          color: Colors.green,
          onPressed: sendMessage,
          icon: Icon(
            Icons.arrow_upward,
            color: Colors.grey,
          ),
        )
      ],
    );
  }
}
