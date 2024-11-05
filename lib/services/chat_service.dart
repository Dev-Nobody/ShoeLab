import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fyp/model/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;


  // Upload image and return the URL
  Future<String> uploadImage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child('chat_images/$fileName');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Fetch the current user information from Firestore
  Future<Map<String, String>> _getCurrentUserInfo() async {
    // Get the current user's UID from Firebase Auth
    final String currentUserId = _firebaseAuth.currentUser!.email!;

    try {
      // Fetch the user document from Firestore
      DocumentSnapshot userDoc =
          await _fireStore.collection('users').doc(currentUserId).get();

      if (userDoc.exists) {
        // Extract the email and any other necessary information
        String currentUserEmail = userDoc.get('email');
        return {
          'currentUserId': currentUserId,
          'currentUserEmail': currentUserEmail,
        };
      } else {
        throw Exception("User document not found in Firestore.");
      }
    } catch (e) {
      print("Error fetching user info: $e");
      return {
        'currentUserId': currentUserId,
        'currentUserEmail': '', // Fallback if email retrieval fails
      };
    }
  }

  //Get all users Stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _fireStore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .where(
              (doc) => doc.data()['email'] != _firebaseAuth.currentUser!.email)
          .map((doc) => doc.data())
          .toList();
    });
  }

  // Get All Users Stream Except Blocked Users
  Stream<List<Map<String, dynamic>>> getUsersStreamExcludingBlocked() {
    final currentUser = _firebaseAuth.currentUser;

    return _fireStore
        .collection('users')
        .doc(currentUser!.email!)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      //get blocked user ids
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

      //get all users
      final userSnapshot = await _fireStore.collection('users').get();

      // return as stream list
      return userSnapshot.docs
          .where((doc) =>
              doc.data()['email'] != currentUser.email &&
              !blockedUserIds.contains(doc.id))
          .map((doc) => doc.data())
          .toList();
    });
  }

  // Fetch the receiver information from Firestore
  Future<Map<String, String>> _getReceiverInfo(String receiverId) async {
    try {
      // Fetch the receiver's document from Firestore
      DocumentSnapshot receiverDoc =
          await _fireStore.collection('users').doc(receiverId).get();

      if (receiverDoc.exists) {
        // Extract the receiver's email and any other necessary information
        String receiverEmail = receiverDoc.get('email');
        return {
          'receiverId': receiverId,
          'receiverEmail': receiverEmail,
        };
      } else {
        throw Exception("Receiver document not found in Firestore.");
      }
    } catch (e) {
      print("Error fetching receiver info: $e");
      return {
        'receiverId': receiverId,
        'receiverEmail': '', // Fallback if email retrieval fails
      };
    }
  }

  // Send Message
  Future<void> sendMessage(String receiverId, String message, {String? imageUrl}) async {
    final Map<String, String> userInfo = await _getCurrentUserInfo();
    final String currentUserId = userInfo['currentUserId']!;
    final Timestamp timestamp = Timestamp.now();

    // Construct message data
    Map<String, dynamic> messageData = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'timestamp': timestamp,
      'imageUrl': imageUrl ?? '', // Image URL if sending an image
      'message': imageUrl == null ? message : '', // Only send text if no image
    };

    // Construct chat room ID
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // Add message to Firestore
    await _fireStore.collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageData);
  }

  // Get Messages
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Mock function to fetch users who have communicated with the vendor
  Future<List<Map<String, String>>> getUsersWhoChattedWithVendor(String vendorEmail) async {
    // Fetch the list of chat users from the database (filter by vendorEmail)
    // Example structure: [{'uid': 'user123', 'email': 'user@example.com'}]

    // Mock data: replace this with actual fetching logic from Firestore or other databases
    List<Map<String, String>> chatUsers = [
      {'uid': 'user1', 'email': 'customer1@example.com'},
      {'uid': 'user2', 'email': 'customer2@example.com'},
      // Add actual data where this vendor has chatted with customers
    ];

    return chatUsers;
  }

  // Report User
  Future<void> reportUser(String messageId, String userId) async {
    final currentUser = _firebaseAuth.currentUser;
    final report = {
      'reportedBy': currentUser!.email!,
      'messageId': messageId,
      'messageOwnerId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _fireStore.collection('Reports').add(report);
  }

  // Block User
  Future<void> blockUser(String userId) async {
    final currentUser = _firebaseAuth.currentUser;
    await _fireStore
        .collection('users')
        .doc(currentUser!.email!)
        .collection('BlockedUsers')
        .doc(userId)
        .set({});
    notifyListeners();
  }

  // UnBlock User
  Future<void> unBlockUser(String blockedUserId) async {
    final currentUser = _firebaseAuth.currentUser;
    await _fireStore
        .collection('users')
        .doc(currentUser!.email!)
        .collection('BlockedUsers')
        .doc(blockedUserId)
        .delete();
  }

  // Get Blocked Users Stream
  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String userId) {
    return _fireStore
        .collection('users')
        .doc(userId)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      //get list of blocked user ids
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

      final userDocs = await Future.wait(
        blockedUserIds
            .map((id) => _fireStore.collection('users').doc(id).get()),
      );

      //return a list
      return userDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  // Fetch customer and vendor documents from Firestore excluding blocked users
  Future<List<Map<String, String>>> getCustomerAndVendorDataExcludingBlocked() async {
    List<Map<String, String>> users = [];
    try {
      // Get the current user's email
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        print('No authenticated user found.');
        return users;
      }

      // Fetch the list of blocked user IDs for the current user
      final blockedUsersSnapshot = await _fireStore
          .collection('users')
          .doc(currentUser.email!)
          .collection('BlockedUsers')
          .get();

      // Get the list of blocked user IDs
      final blockedUserIds =
      blockedUsersSnapshot.docs.map((doc) => doc.id).toList();

      // Fetch users with the roles 'Customer' or 'Vendor', excluding blocked users
      final userSnapshot = await _fireStore
          .collection('users')
          .where('role', whereIn: ['Customer', 'Vendor'])
          .get();

      // Filter out blocked users
      for (var document in userSnapshot.docs) {
        if (!blockedUserIds.contains(document.id)) {
          // Add the UID and email to the list if not blocked
          users.add({
            'uid': document.id, // UID is the document ID
            'email': document['email'], // Assuming email is stored in this field
          });
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    return users;
  }

}
