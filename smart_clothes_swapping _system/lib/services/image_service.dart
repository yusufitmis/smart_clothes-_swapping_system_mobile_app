import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/image_model.dart';

class ImageService {
  Future<ImageModel> uploadImageWithDetails({
    required String url,
    required String brand,
    required String size,
    required String category,
    required int userId,
  }) async {
    final uri = Uri.parse('http://10.0.2.2:3000/clothing/upload-image');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'image_url': url,
      'brand': brand,
      'size': size,
      'category': category,
      'user_id': userId,
    });

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return ImageModel(
        id: responseData['id'], // Backend'den gelen 'id' değerini alıyoruz
        path: responseData['image_url'],
        brand: brand,
        size: size,
        category: category,
        color: responseData['color'], // Backend'den alınan renk verisi
      );
    } else {
      throw Exception('Resim yükleme hatası: ${response.body}');
    }
  }

  final String baseUrl = 'http://10.0.2.2:3000/clothing';

  Future<void> updateClothing({
    required int id,
    required String brand,
    required String size,
    required String category,
  }) async {
    final uri = Uri.parse('$baseUrl/$id');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'brand': brand,
      'size': size,
      'category': category,
    });

    final response = await http.put(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      print("Error: ${response.statusCode}");
      print("Body: ${response.body}");
      throw Exception('Güncelleme hatası: ${response.body}');
    }
  }

  Future<void> deleteClothing(int id) async {
    final uri = Uri.parse('$baseUrl/$id');
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Silme hatası: ${response.body}');
    }
  }
}
