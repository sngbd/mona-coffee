import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mona_coffee/features/accounts/data/entities/cart_item.dart';

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
    required String timeToCome,
    required String notes,
    required String orderType,
    required List<CartItem> cartItems,
    required double amount,
    required String transferProofPath,
    String? bankName,
    String? walletName,
  }) async {

    final user = _auth.currentUser;
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
      'paymentMethod': bankName != null
          ? 'E-Banking'
          : walletName != null
              ? 'E-Wallet'
              : 'QRIS',
      'bankName': bankName,
      'ewalletName': walletName,
      'transferProof': transferProofBase64,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    };

    await _firestore.collection('transactions').add(transactionData);
  }

}
