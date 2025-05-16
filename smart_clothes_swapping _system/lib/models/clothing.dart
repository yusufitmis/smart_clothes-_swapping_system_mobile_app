class Clothing {
  final int id;
  final String category;
  final String color;
  final String size;
  final String brand;
  final String photoPath;
  bool isFavorite; // Favori durumu
  

  Clothing({
    required this.id,
    required this.category,
    required this.color,
    required this.size,
    required this.brand,
    required this.photoPath,
    this.isFavorite = false, // Başlangıçta favori değil
   
  });

  factory Clothing.fromJson(Map<String, dynamic> json) {
    String photoUrl = 'http://10.0.2.2:3000/uploads/${json['photo_path']}';

    return Clothing(
      id: json['id'],
      category: json['category'],
      color: json['color'],
      size: json['size'],
      brand: json['brand'],
      photoPath: photoUrl,
      isFavorite: json['is_favorite'] ?? false, // Favori durumu veritabanından geliyorsa burada güncellenebilir
    );
  }
}
