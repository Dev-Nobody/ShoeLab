import 'package:flutter/material.dart';
import 'package:fyp/services/chat_service.dart';

class ChatBubble extends StatelessWidget {
  final String? message;
  final String? imageUrl;
  final bool isCurrentUser;
  final String messageId;
  final String userId;

  const ChatBubble({
    super.key,
    required this.message,
    required this.imageUrl,
    required this.isCurrentUser,
    required this.userId,
    required this.messageId,
  });

  //show options
  void _showOptions(BuildContext context, String messageId, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
            child: Wrap(
          children: [
            //report message
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                _reportMessage(context, messageId, userId);
              },
            ),

            //block user
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                _blockUser(context, userId);
              },
            ),

            //cancel button
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: ()=>Navigator.pop(context),
            ),
          ],
        ));
      },
    );
  }

  //report message
  void _reportMessage(BuildContext context, String messageId, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Message'),
        content: const Text('Are you sure you want to report this message?'),
        actions: [
          //cancel button
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('cancel')),

          // Report button
          TextButton(
              onPressed: () {
                ChatService().reportUser(messageId, userId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Message Reported")));
              },
              child: const Text('Report'),)
        ],
      ),
    );
  }

  //block user
  void _blockUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure you want to Block this User?'),
        actions: [
          //cancel button
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('cancel')),

          // block button
          TextButton(
            onPressed: () {
              ChatService().blockUser(userId);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User Blocked")));
            },
            child: const Text('Blocked'),)
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          //show options
          _showOptions(context, messageId, userId);
        }
      },
      child: Container(
        padding: imageUrl != null && imageUrl!.isNotEmpty
            ? const EdgeInsets.all(4) // Less padding for images
            : const EdgeInsets.all(16), // Default padding for text messages
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isCurrentUser ? Colors.green : Colors.grey.shade800,
        ),
        child:imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(imageUrl!,width: 150,height: 200,fit: BoxFit.cover,)  // Display image if imageUrl is present
            : Text(
          message ?? '',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
