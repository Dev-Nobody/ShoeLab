import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavouriteService {
  final _userEmail = FirebaseAuth.instance.currentUser?.email;

  Future<void> toggleFavourite(String shoeId, Map<String, dynamic> shoeData) async {
    if (_userEmail == null) return;

    final userFavorites = FirebaseFirestore.instance
        .collection('users')
        .doc(_userEmail)
        .collection('favourites');

    final existingFavourite = await userFavorites
        .where('shoeId', isEqualTo: shoeId)
        .get();

    if (existingFavourite.docs.isNotEmpty) {
      // If the shoe is already in favorites, remove it
      await userFavorites.doc(existingFavourite.docs.first.id).delete();
    } else {
      // Add shoe to favorites
      await userFavorites.add({
        'shoeId': shoeId,
        ...shoeData,
        'addedAt': Timestamp.now(),
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchFavourites() async {
    if (_userEmail == null) return [];

    final userFavorites = FirebaseFirestore.instance
        .collection('users')
        .doc(_userEmail)
        .collection('favourites');

    final querySnapshot = await userFavorites.get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<bool> isFavourite(String shoeId) async {
    if (_userEmail == null) return false;

    final userFavorites = FirebaseFirestore.instance
        .collection('users')
        .doc(_userEmail)
        .collection('favourites');

    final existingFavourite = await userFavorites
        .where('shoeId', isEqualTo: shoeId)
        .get();

    return existingFavourite.docs.isNotEmpty;
  }
}
