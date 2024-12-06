class MenuOption {
  final String type;
  final String size;

  MenuOption({
    required this.type,
    required this.size,
  });

  factory MenuOption.fromFirestore(String docId, Map<String, dynamic> data) {
    return MenuOption(
      type: data['type'] ?? '',
      size: data['size'] ?? '',
    );
  }
}
