import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mona_coffee/features/accounts/data/entities/cart_item.dart';
import 'package:mona_coffee/features/accounts/data/entities/cart_item_repo.dart';

class CartRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CartRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  List<CartItem> _cartItems = [];

  Future<List<CartItem>> getCartItems() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    final cartRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .orderBy('timestamp', descending: false);
    final querySnapshot = await cartRef.get();

    _cartItems =
        querySnapshot.docs.map((doc) => CartItem.fromMap(doc.data())).toList();

    return List.unmodifiable(_cartItems);
  }

  Future<void> addToCart(CartItemRepo item) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    final cartRef =
        _firestore.collection('users').doc(userId).collection('cart');
    final docRef = cartRef.doc(item.compositeKey);

    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      final updatedItem = CartItemRepo(
          compositeKey: item.compositeKey,
          name: item.name,
          type: item.type,
          size: item.size,
          price: item.price,
          quantity: item.quantity,
          imageUrl: item.imageUrl,
          timestamp: item.timestamp);
      await docRef.set(updatedItem.toMap());
    } else {
      final newItem = CartItemRepo(
          compositeKey: item.compositeKey,
          name: item.name,
          type: item.type,
          size: item.size,
          price: item.price,
          quantity: item.quantity,
          imageUrl: item.imageUrl,
          timestamp: item.timestamp);
      await docRef.set(newItem.toMap());
    }

    _cartItems = await getCartItems();
  }

  Future<void> removeFromCart(String compositeKey) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    final cartRef =
        _firestore.collection('users').doc(userId).collection('cart');
    await cartRef.doc(compositeKey).delete();

    _cartItems = await getCartItems();
  }

  Future<void> clearCart() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    final cartRef =
        _firestore.collection('users').doc(userId).collection('cart');
    final querySnapshot = await cartRef.get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }

    _cartItems = await getCartItems();
  }

  Future<int> getQuantityInCart(String name, String type, String size) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    final compositeKey = '${name}_${type}_$size';
    final cartRef =
        _firestore.collection('users').doc(userId).collection('cart');
    final docSnapshot = await cartRef.doc(compositeKey).get();

    if (!docSnapshot.exists) {
      return 0;
    }

    return docSnapshot.get('quantity');
  }

  Future<List<Map<String, dynamic>>> fetchPastOrders() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final transactionsSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('users-transactions')
        .get();

    return transactionsSnapshot.docs.map((doc) => doc.data()).toList();
  }
}
