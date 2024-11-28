import 'package:mona_coffee/features/home/data/entities/menu_item.dart';

class FavoriteCoffee {
  final String name;
  final String type;
  final String image;
  final String size;
  final String id;
  final MenuItem item;

  FavoriteCoffee({
    required this.name,
    required this.type,
    required this.image,
    required this.size,
    required this.id,
    required this.item,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'image': image,
      'item': item,
    };
  }

  factory FavoriteCoffee.fromMap(Map<String, dynamic> map, String id) {
    return FavoriteCoffee(
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      image: map['image'] ?? '',
      size: map['size'] ?? '',
      item: map['item'] ?? '',
      id: id,
    );
  }
}
