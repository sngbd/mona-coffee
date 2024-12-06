class Favorite {
  final String name;
  final String type;
  final String image;
  final String size;
  final String id;

  Favorite({
    required this.name,
    required this.type,
    required this.image,
    required this.size,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'image': image,
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map, String id) {
    return Favorite(
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      image: map['image'] ?? '',
      size: map['size'] ?? '',
      id: id,
    );
  }
}
