import 'dart:convert';
import 'package:http/http.dart' as http;

class BackgroundRemovalService {
  final String apiKey = 'HRK61HWEK2VawH4vRhVchhHf';  // Remove.bg API anahtarınız

  Future<String> removeBackground(String imageUrl) async {
    final response = await http.post(
      Uri.parse('https://api.remove.bg/v1.0/removebg'),
      headers: {
        'X-Api-Key': apiKey,
      },
      body: json.encode({
        'image_url': imageUrl,
        'size': 'auto',  // Yüksek çözünürlük veya otomatik seçenek
      }),
    );

    if (response.statusCode == 200) {
      // Başarılı işlem
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['data']['result_url'];  // Arka planı silinmiş resmin URL'si
    } else {
      throw Exception('Arka plan silme hatası: ${response.body}');
    }
  }
}
