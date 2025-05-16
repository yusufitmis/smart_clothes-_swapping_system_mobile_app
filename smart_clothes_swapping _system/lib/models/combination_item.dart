class CombinationItem {
  final int id;
  final String category;
  final String color;
  final String size;
  final String brand;
  final String photoPath;

  CombinationItem({
    required this.id,
    required this.category,
    required this.color,
    required this.size,
    required this.brand,
    required this.photoPath,
  });

  factory CombinationItem.fromJson(Map<String, dynamic> json) {
    String photoUrl = 'http://10.0.2.2:3000/uploads/${json['photo_path']}';
    return CombinationItem(
      id: json['combination_item_id'] ?? 0,
      category: json['category'] ?? 'Unknown',
      color: json['color'] ?? 'Unknown',
      size: json['size'] ?? 'Unknown',
      brand: json['brand'] ?? 'Unknown',
      photoPath: photoUrl,
    );
  }
}
