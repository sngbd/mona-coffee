import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mona_coffee/features/accounts/data/entities/cart_item.dart';
import 'package:http/http.dart' as http;

class CheckoutRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CheckoutRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<void> confirmTransaction({
    required String userName,
    required String address,
    required Timestamp? timeToCome,
    required String notes,
    required String orderType,
    required List<CartItem> cartItems,
    required double amount,
    required String transferProofPath,
    String? bankName,
    String? walletName,
    int? deliveryFee,
    double? distance,
  }) async {
    final user = _auth.currentUser;
    final userName = _auth.currentUser?.displayName;
    if (user == null) throw Exception('User not authenticated');

    final transferProofFile = File(transferProofPath);
    final bytes = await transferProofFile.readAsBytes();
    final transferProofBase64 = base64Encode(bytes);

    final transactionData = {
      'userId': user.uid,
      'userName': userName,
      'address': address,
      'timeToCome': timeToCome,
      'notes': notes,
      'orderTime': Timestamp.now(),
      'orderType': orderType,
      'items': cartItems.map((item) => item.toMap()).toList(),
      'totalAmount': amount,
      'paymentMethod': bankName != '' && bankName != null
          ? 'E-Banking'
          : (walletName != null && walletName != '' ? 'E-Wallet' : 'QRIS'),
      'bankName': bankName,
      'ewalletName': walletName,
      'deliveryFee': deliveryFee,
      'distance': distance,
      'transferProof': transferProofBase64,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    };

    if (orderType.toLowerCase() == 'dine-in') {
      transactionData['seatNumber'] = '';
    }

    final batch = _firestore.batch();
    final transactionRef = _firestore.collection('transactions').doc();
    final userTransactionRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('user-transactions')
        .doc(transactionRef.id);

    batch.set(transactionRef, transactionData);
    batch.set(userTransactionRef, transactionData);

    await batch.commit();

    final userDoc = await _firestore
        .collection('users')
        .doc('vAIocCXkuNh8GmGJttsjnO41eX82')
        .get();
    final fcmToken = userDoc.data()?['fcmToken'];

    if (fcmToken != null) {
      await _sendNotification(fcmToken, userName);
    }
  }

  Future<void> _sendNotification(String fcmToken, String? userName) async {
    userName = userName ?? '';
    final Uri fcmUrl = Uri.parse(
        'https://mona-notification-70908a918a0e.herokuapp.com/send-notification');

    final Map<String, String> notifPayload = {
      'token': fcmToken,
      'title': 'A New Order',
      'body':
          'There is a new order from ${userName == '' ? 'a customer' : 'customer $userName'}.',
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
}
