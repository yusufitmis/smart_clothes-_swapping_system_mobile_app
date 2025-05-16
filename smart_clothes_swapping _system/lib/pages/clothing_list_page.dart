import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/clothing.dart';
import '../utils/color_utils.dart';
import 'clothing_detail.dart';
import 'combination_list_page.dart';
import 'create_combination_page.dart';
import 'favorite_page.dart';
import 'image_upload_page.dart';

class ClothingListPage extends StatefulWidget {
  final int userId; // userId'yi alın
  ClothingListPage({required this.userId});
  @override
  _ClothingListPageState createState() => _ClothingListPageState();
}

class _ClothingListPageState extends State<ClothingListPage> {
  List<Clothing> clothingList = [];
  List<int> favoriteClothingIds = [];
  List<Clothing> selectedClothing = [];
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
    _fetchClothing();
  }

  Future<void> _fetchClothing() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/clothing?user_id=${widget.userId}'),
      );
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
        throw Exception('Kıyafetleri çekme hatası');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Kıyafetler alınırken bir hata oluştu: $e'),
      ));
    }
  }

  Future<void> _fetchFavorites() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/favorites?user_id=${widget.userId}'),
      );
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
        body: jsonEncode({
          'user_id': widget.userId, // widget.userId kullanılıyor
          'clothing_id': clothingId,
        }),
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

  void _navigateToUploadPage() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ImageUploadPage(userId: widget.userId)),
      );
      if (result == true) {
        await _fetchClothing(); // Yükleme işlemi başarılıysa listeyi güncelle
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kıyafet başarıyla yüklendi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToFavoritesPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritePage(
          favoriteClothingIds: favoriteClothingIds,
          clothingList: clothingList,
          onAddToFavorites: _addToFavorites,
          onRemoveFromFavorites: _removeFromFavorites,
          userId: widget.userId,
        ),
      ),
    );
  }

  void _navigateToDetailPage(Clothing clothing) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClothingDetailPage(
          clothing: clothing,
        ),
      ),
    ).then((value) {
      _fetchClothing();
    });
  }

  void _navigateToCombineListPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CombineListPage()),
    );
  }

  void _navigateToCreateCombinationPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateCombinationPage(
          selectedClothing: selectedClothing,
        ),
      ),
    ).then((value) {
      setState(() {
        isSelectionMode = false;
        selectedClothing.clear();
      });
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode) {
        selectedClothing.clear();
      }
    });
  }

  void _onClothingSelected(Clothing clothing) {
    setState(() {
      if (selectedClothing.contains(clothing)) {
        selectedClothing.remove(clothing);
      } else {
        selectedClothing.add(clothing);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kıyafetlerim",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(isSelectionMode ? Icons.close : Icons.select_all),
            onPressed: _toggleSelectionMode,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: clothingList.isEmpty
                ? Center(
                    child: Text(
                      'Kıyafet bulunamadı',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: clothingList.length,
                    itemBuilder: (context, index) {
                      final clothing = clothingList[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: ListTile(
                          leading: clothing.photoPath.isNotEmpty
                              ? Image.network(
                                  clothing.photoPath,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.image_not_supported, size: 50),
                          title: Text(
                              '${clothing.brand} - ${clothing.category}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'Renk: ${getColorNameFromRgb(clothing.color)}, Beden: ${clothing.size}'),
                          trailing: isSelectionMode
                              ? Icon(
                            selectedClothing.contains(clothing)
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: Colors.teal,
                          )
                              : IconButton(
                            icon: Icon(
                              clothing.isFavorite ? Icons.favorite : Icons.favorite_border,
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
                          onTap: () {
                            if (isSelectionMode) {
                              _onClothingSelected(clothing);
                            } else {
                              _navigateToDetailPage(clothing);
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
          if (isSelectionMode && selectedClothing.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _navigateToCreateCombinationPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  'Kombin Oluştur (${selectedClothing.length})',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
