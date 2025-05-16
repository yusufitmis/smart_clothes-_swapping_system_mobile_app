import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // http paketini içe aktarın
import 'dart:convert'; // json.decode için gerekli
import '../models/clothing.dart';

class FavoritePage extends StatefulWidget {
  final List<int> favoriteClothingIds;
  final List<Clothing> clothingList;
  final Function(int) onAddToFavorites;
  final Function(int) onRemoveFromFavorites;
  final int userId;

  const FavoritePage({
    required this.favoriteClothingIds,
    required this.clothingList,
    required this.onAddToFavorites,
    required this.onRemoveFromFavorites,
    required this.userId
  });

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Clothing> clothingList = [];
  List<int> favoriteClothingIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFavorites();
    });
  }

  Future<void> _fetchFavorites() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/favorites?user_id=${widget.userId}'));
      if (response.statusCode == 200) {
        setState(() {
          favoriteClothingIds = (json.decode(response.body) as List)
              .map((data) => data['clothing_id'] as int)
              .toList();
        });
        _fetchClothing();
      } else {
        throw Exception('Favoriler çekilemedi');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Favoriler alınırken bir hata oluştu: $e'),
      ));
    }
  }

  Future<void> _fetchClothing() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/clothing?user_id=${widget.userId}'),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          clothingList = (json.decode(response.body) as List)
              .map((data) => Clothing.fromJson(data))
              .toList();
          for (var clothing in clothingList) {
            clothing.isFavorite = favoriteClothingIds.contains(clothing.id);
          }
        });
      } else {
        throw Exception('Kıyafetleri çekme hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('Hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Kıyafetler alınırken bir hata oluştu: $e'),
      ));
    }
  }

  Future<void> _addToFavorites(int clothingId) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/favorites/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.userId, // widget.userId kullanılıyor
          'clothing_id': clothingId,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          favoriteClothingIds.add(clothingId);
          final clothing = clothingList.firstWhere((item) => item.id == clothingId);
          clothing.isFavorite = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Kıyafet favorilere eklendi!'),
        ));
      } else {
        throw Exception('Favoriye ekleme hatası: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Favoriye eklerken bir hata oluştu: $e'),
      ));
    }
  }

  Future<void> _removeFromFavorites(int clothingId) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/favorites/remove'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': widget.userId, 'clothing_id': clothingId}),
      );
      if (response.statusCode == 200) {
        setState(() {
          favoriteClothingIds.remove(clothingId);
          final clothing = clothingList.firstWhere((item) => item.id == clothingId);
          clothing.isFavorite = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Kıyafet favorilerden çıkarıldı!'),
        ));
      } else {
        throw Exception('Favorilerden çıkarma hatası');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Favorilerden çıkarırken bir hata oluştu: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Favori kıyafetleri filtrele
    final favoriteClothingList = clothingList.where((clothing) =>
        favoriteClothingIds.contains(clothing.id)).toList();
    print('MainScreen userId: ${widget.userId}');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Favori Kıyafetler",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: favoriteClothingList.isEmpty
          ? Center(
        child: Text(
          'Henüz favori kıyafetiniz yok!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: favoriteClothingList.length,
        itemBuilder: (context, index) {
          final clothing = favoriteClothingList[index];
          return GestureDetector(
            onTap: () {
              // İstenirse kıyafetin detay sayfasına yönlendirme yapılabilir
            },
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              color: Colors.white,
              child: ListTile(
                contentPadding: EdgeInsets.all(10),
                leading: clothing.photoPath.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    clothing.photoPath,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(
                  Icons.error,
                  size: 60,
                  color: Colors.grey,
                ),
                title: Text(
                  '${clothing.brand} - ${clothing.category}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  'Renk: ${clothing.color}, Beden: ${clothing.size}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                trailing: IconButton(
                  icon: Icon(
                    clothing.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: clothing.isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    if (clothing.isFavorite) {
                      _removeFromFavorites(clothing.id);
                    } else {
                      _addToFavorites(clothing.id);
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}