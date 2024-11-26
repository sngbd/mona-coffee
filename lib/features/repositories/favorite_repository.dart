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

  Future<DocumentReference<Map<String, dynamic>>> _getUserRef() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');
    
    // Get reference to user document
    final userRef = _firestore.collection('users').doc(userId);
    
    // Check if user document exists, if not create it
    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      await userRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    return userRef;
  }

  Future<CollectionReference<Map<String, dynamic>>> _getFavoritesRef() async {
    final userRef = await _getUserRef();
    return userRef.collection('favorites');
  }

  Future<void> addToFavorites(String name, String type, String image) async {
    final favoritesRef = await _getFavoritesRef();
    
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
    final favoritesRef = await _getFavoritesRef();
    await favoritesRef.doc(documentId).delete();
  }

  Future<bool> isFavorite(String name, String type) async {
    final favoritesRef = await _getFavoritesRef();
    
    final querySnapshot = await favoritesRef
        .where('name', isEqualTo: name)
        .where('type', isEqualTo: type)
        .get();
        
    return querySnapshot.docs.isNotEmpty;
  }

  Stream<List<FavoriteCoffee>> getFavorites() async* {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');
    
    // Ensure user document exists
    final userRef = _firestore.collection('users').doc(userId);
    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      await userRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // Get favorites stream
    yield* userRef
        .collection('favorites')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FavoriteCoffee.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<String?> getFavoriteId(String name, String type) async {
    final favoritesRef = await _getFavoritesRef();
    
    final querySnapshot = await favoritesRef
        .where('name', isEqualTo: name)
        .where('type', isEqualTo: type)
        .get();
        
    return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.id : null;
  }
}