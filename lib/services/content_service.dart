import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Method to add content to Firebase Firestore
  Future<void> addContent(String title, String description, File? image) async {
    String imageUrl = '';

    // Upload image to Firebase Storage if provided
    if (image != null) {
      final storageRef = _storage.ref().child('content_images/${DateTime.now().toString()}');
      final uploadTask = await storageRef.putFile(image);
      imageUrl = await uploadTask.ref.getDownloadURL();
    }

    // Add content data to Firestore
    await _firestore.collection('content').add({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now(),
    });
  }

  // Method to fetch content from Firebase Firestore
  Future<List<Map<String, dynamic>>> fetchContent() async {
    QuerySnapshot querySnapshot = await _firestore.collection('content').orderBy('createdAt', descending: true).get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
