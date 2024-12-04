import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

        final userDoc = await _firestore.collection('users').doc(userId).get();
        final fcmToken = userDoc.data()?['fcmToken'];

        if (fcmToken != null) {
          await _sendNotification(fcmToken, orderId, status);
        }
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

  Future<void> _sendNotification(
      String fcmToken, String orderId, String status) async {
    final Uri fcmUrl = Uri.parse(
        'https://mona-notification-70908a918a0e.herokuapp.com/send-notification');

    final Map<String, String> notifPayload = {
      'token': fcmToken,
      'title': 'Order Status Updated',
      'body': 'Your order $orderId status has been updated to $status.',
    };

    final http.Response response = await http.post(
      fcmUrl,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(notifPayload),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send notification: ${response.body}');
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
