import 'package:cloud_firestore/cloud_firestore.dart';

class ShoeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch shoes for a specific vendor
  Stream<List<QueryDocumentSnapshot>> fetchShoes(String? userEmail) {
    return _firestore
        .collection('shoes')
        .where('vendorUsername', isEqualTo: userEmail)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  // Delete a shoe by its document ID
  Future<void> deleteShoe(String shoeId) async {
    try {
      await _firestore.collection('shoes').doc(shoeId).delete();
    } catch (e) {
      throw Exception('Failed to delete shoe: $e');
    }
  }
}
