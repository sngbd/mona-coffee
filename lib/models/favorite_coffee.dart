class FavoriteCoffee {
  final String name;
  final String type;
  final String image;
  final String id;

  FavoriteCoffee({
    required this.name,
    required this.type,
    required this.image,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'image': image,
    };
  }

  factory FavoriteCoffee.fromMap(Map<String, dynamic> map, String id) {
    return FavoriteCoffee(
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      image: map['image'] ?? '',
      id: id,
    );
  }
}
