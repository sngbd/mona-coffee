import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersRepository {
  final FirebaseFirestore _firestore;

  AdminOrdersRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<QuerySnapshot> getOrders() {
    return _firestore
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
