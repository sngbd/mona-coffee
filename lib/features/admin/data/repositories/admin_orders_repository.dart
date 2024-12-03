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

  Future<void> updateOrderStatus(
      String orderId, String userId, String status) async {
    final batch = _firestore.batch();
    final transactionDoc = _firestore.collection('transactions').doc(orderId);
    final userTransactionDoc = _firestore
        .collection('users')
        .doc(userId)
        .collection('user-transactions')
        .doc(orderId);

    try {
      final transactionData = await transactionDoc.get();
      if (transactionData.exists) {
        batch.update(transactionDoc, {'status': status});
        batch.update(userTransactionDoc, {'status': status});
        await batch.commit();
      } else {
        throw Exception('Order document not found.');
      }
    } on FirebaseException catch (e) {
      if (e.code == 'cloud_firestore/not-found') {
        throw Exception(
            'The order you\'re trying to update has been deleted or is no longer available.');
      } else {
        rethrow;
      }
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<void> updateSeatNumber(
      String orderId, String userId, String seatNumber) async {
    final batch = _firestore.batch();
    final transactionDoc = _firestore.collection('transactions').doc(orderId);
    final userTransactionDoc = _firestore
        .collection('users')
        .doc(userId)
        .collection('user-transactions')
        .doc(orderId);

    try {
      final transactionData = await transactionDoc.get();
      if (transactionData.exists) {
        batch.update(transactionDoc, {'seatNumber': seatNumber});
        batch.update(userTransactionDoc, {'seatNumber': seatNumber});
        await batch.commit();
      } else {
        throw Exception('Order document not found.');
      }
    } on FirebaseException catch (e) {
      if (e.code == 'cloud_firestore/not-found') {
        throw Exception(
            'The order you\'re trying to update has been deleted or is no longer available.');
      } else {
        rethrow;
      }
    } catch (e) {
      throw Exception('Failed to update seat number: $e');
    }
  }
}
