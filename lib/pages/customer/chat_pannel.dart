import 'package:flutter/material.dart';
import 'package:fyp/pages/customer/chat_Page.dart';
import 'package:fyp/pages/customer/shoes_page.dart';
import 'package:fyp/services/chat_service.dart';
import 'package:fyp/services/content_service.dart';

class ChatPannel extends StatefulWidget {
  const ChatPannel({super.key});

  @override
  State<ChatPannel> createState() => _ChatPannelState();
}

class _ChatPannelState extends State<ChatPannel> {
  final ChatService _chatService = ChatService();
  final ContentService _contentService = ContentService();
  List<Map<String, String>> _vendors = [];
  List<Map<String, dynamic>> _contentList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVendors();
    _loadContent();
  }

  // Fetch vendors and update the state
  Future<void> _loadVendors() async {
    try {
      final vendors = await _chatService.fetchVendors();
      setState(() {
        _vendors = vendors;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading vendors: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch content and update the state
  Future<void> _loadContent() async {
    try {
      final contentList = await _contentService.fetchContent();
      setState(() {
        _contentList = contentList;
      });
    } catch (e) {
      print("Error loading content: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Column(
          children: [
            // Top section with vendor avatars
            Container(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _vendors.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // "Customer Support" icon with a fixed email and ID
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatPage(
                                receiverUserEmail: 'admin@gmail.com',
                                receiverUserId: 'admin@gmail.com',
                              ),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.support_agent,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Customer Support",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // Vendor avatars
                      final vendor = _vendors[index - 1];
                      final receiverUserEmail = vendor['email'];
                      final receiverUserId = vendor['email'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                receiverUserEmail: receiverUserEmail!,
                                receiverUserId: receiverUserId!,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: vendor['profileImage'] != null
                                    ? NetworkImage(vendor['profileImage']!)
                                    : null,
                                backgroundColor: Colors.grey[300],
                                child: vendor['profileImage'] == null
                                    ? Text(
                                  vendor['username']?.substring(0, 1) ?? '?',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                  ),
                                )
                                    : null,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                vendor['username'] ?? 'Unknown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            // Expanded section with list of content
            Expanded(
              child: _contentList.isEmpty
                  ? const Center(
                child: Text(
                  "No content available",
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : ListView.builder(
                itemCount: _contentList.length,
                itemBuilder: (context, index) {
                  final content = _contentList[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      // onTap: () {
                      //   Navigator.push(context, MaterialPageRoute(builder: (context) => ShoesPage(shoeId: shoeId),));
                      // },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              content['title'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (content['imageUrl'] != null)
                              Image.network(
                                content['imageUrl'],
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            const SizedBox(height: 8),
                            Text(
                              content['description'] ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
