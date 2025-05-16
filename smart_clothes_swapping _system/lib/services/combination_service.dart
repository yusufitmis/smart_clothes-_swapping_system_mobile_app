import 'dart:convert';
import 'package:http/http.dart' as http;

class CombinationService {
  final String _baseUrl = 'http://10.0.2.2:3000'; // Backend URL

  // Kombin oluşturma fonksiyonu
  Future<void> createCombination(
      String name, String description, List<int> clothingIds) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/combinations/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': description,
          'clothing_ids': clothingIds,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Kombin oluşturma hatası: ${response.body}');
      }

      // Başarı durumu
      print('Kombin başarıyla oluşturuldu: ${response.body}');
    } catch (e) {
      // Hata durumunda yönetilebilir hatalar
      throw Exception('Hata oluştu: $e');
    }
  }
}