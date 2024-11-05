import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// Create reviews
  Future<void> createReview({required String orderId, required String customerId, required int stars, required String message, String? imageUrl, // Nullable if no image is uploaded
  }) async {
    try {
      // Prepare review data
      Map<String, dynamic> reviewData = {
        'orderId': orderId,
        'customerId': customerId,
        'stars': stars,
        'message': message,
        'imageUrl': imageUrl ?? '', // If no image, store an empty string
        'timestamp': FieldValue.serverTimestamp(), // Automatically set the Firestore server time
      };

      // Add review data to Firestore (create new review document)
      await _firestore.collection('reviews').add(reviewData);

      print('Review added successfully');
    } catch (e) {
      print('Error adding review: $e');
    }
  }

  // Fetch reviews for the current user
  Future<List<Map<String, dynamic>>> fetchUserReviews() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        print('User Email: ${user.email}');

        final QuerySnapshot snapshot = await _firestore
            .collection('reviews')
            .where('customerId', isEqualTo: user.email!)
            // .orderBy('timestamp', descending: true)
            .get();

        return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      } catch (e) {
        print('Error fetching reviews: $e');
        return [];
      }
    } else {
      print('No user logged in');
      return [];
    }
  }
}