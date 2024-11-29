import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemRepo {
  final String compositeKey;
  final String name;
  final String type;
  final String size;
  final double price;
  final int quantity;
  final String imageUrl;
  final FieldValue timestamp;

  CartItemRepo({
    required this.compositeKey,
    required this.name,
    required this.type,
    required this.size,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'compositeKey': compositeKey,
      'name': name,
      'type': type,
      'size': size,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };
  }

  factory CartItemRepo.fromMap(Map<String, dynamic> map) {
    return CartItemRepo(
      compositeKey: map['compositeKey'],
      name: map['name'],
      type: map['type'],
      size: map['size'],
      price: map['price'],
      quantity: map['quantity'],
      imageUrl: map['imageUrl'],
      timestamp: map['timestamp'],
    );
  }
}
