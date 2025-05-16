class ImageModel {
  final int id; // Benzersiz ID
  final String path;
  final String brand;
  final String size;
  final String category;
  final String color; // Yeni eklenen color alanı

  ImageModel({
    required this.id, // ID parametresi
    required this.path,
    required this.brand,
    required this.size,
    required this.category,
    required this.color, // Bu alana color parametresi eklendi
  });

  // `copyWith` metodunu da ID'yi dikkate alacak şekilde güncelleyebilirsiniz
  ImageModel copyWith({
    int? id,
    String? path,
    String? brand,
    String? size,
    String? category,
    String? color,
  }) {
    return ImageModel(
      id: id ?? this.id, // ID değeri de kopyalanacak
      path: path ?? this.path,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      category: category ?? this.category,
      color: color ?? this.color,
    );
  }
}
