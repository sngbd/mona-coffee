import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mona_coffee/models/favorite_coffee.dart';

class FavoriteRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FavoriteRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _getFavoritesRef() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(userId).collection('favorites');
  }

  Future<void> addToFavorites(String name, String type, String image) async {
    final favoritesRef = _getFavoritesRef();

    final querySnapshot = await favoritesRef
        .where('name', isEqualTo: name)
        .where('type', isEqualTo: type)
        .get();

    if (querySnapshot.docs.isEmpty) {
      await favoritesRef.add({
        'name': name,
        'type': type,
        'image': image,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> removeFromFavorites(String documentId) async {
    await _getFavoritesRef().doc(documentId).delete();
  }

  Future<bool> isFavorite(String name, String type) async {
    final querySnapshot = await _getFavoritesRef()
        .where('name', isEqualTo: name)
        .where('type', isEqualTo: type)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Stream<List<FavoriteCoffee>> getFavorites() {
    return _getFavoritesRef()
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FavoriteCoffee.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<String?> getFavoriteId(String name, String type) async {
    final querySnapshot = await _getFavoritesRef()
        .where('name', isEqualTo: name)
        .where('type', isEqualTo: type)
        .get();

    return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.id : null;
  }
}
