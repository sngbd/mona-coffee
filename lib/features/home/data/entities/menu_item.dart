class MenuItem {
  final String name;
  final String category;
  final String description;
  final String hotImage;
  final String iceImage;
  final int largePrice;
  final int mediumPrice;
  final int smallPrice;
  final double rating;
  final int ratingCount;

  MenuItem({
    required this.name,
    required this.category,
    required this.description,
    required this.hotImage,
    required this.iceImage,
    required this.largePrice,
    required this.mediumPrice,
    required this.smallPrice,
    required this.rating,
    required this.ratingCount,
  });

  factory MenuItem.fromFirestore(String docId, Map<String, dynamic> data) {
    return MenuItem(
      name: docId,
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      hotImage: data['hotImage'] ?? '',
      iceImage: data['iceImage'] ?? '',
      largePrice: data['largePrice'] ?? 0,
      mediumPrice: data['mediumPrice'] ?? 0,
      smallPrice: data['smallPrice'] ?? 0,
      rating: (data['rating'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
    );
  }

  // Change the type getter to return a non-null String
  String get type =>
      "${iceImage.isNotEmpty ? 'Ice' : ''}${iceImage.isNotEmpty && hotImage.isNotEmpty ? '/' : ''}${hotImage.isNotEmpty ? 'Hot' : ''}";

  // Change totalRatings to return the ratingCount
  int get totalRatings => ratingCount;
}
