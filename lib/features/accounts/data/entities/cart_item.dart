import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String compositeKey;
  final String name;
  final String type;
  final String size;
  final double price;
  final int quantity;
  final String imageUrl;
  final Timestamp timestamp;

  CartItem({
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

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
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
