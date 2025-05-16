import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/combination.dart';
import '../models/combination_item.dart';
import '../utils/color_utils.dart';
import 'clothing.dart';
import 'update_combination_page.dart';

class CombineListPage extends StatefulWidget {
  @override
  _CombineListPageState createState() => _CombineListPageState();
}

class _CombineListPageState extends State<CombineListPage> {
  List<Combination> combinations = [];
  Map<int, List<CombinationItem>> combinationItems = {};

  @override
  void initState() {
    super.initState();
    _fetchCombinations();
  }

  Future<void> _fetchCombinations() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/combinations/list'));
      if (response.statusCode == 200) {
        setState(() {
          combinations = (json.decode(response.body)['combinations'] as List)
              .map((data) => Combination.fromJson(data))
              .toList();
        });
      } else {
        throw Exception('Kombinler alınamadı');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kombinler alınırken hata oluştu: $e')),
      );
    }
  }

  Future<void> _fetchCombinationItems(int combinationId) async {
    if (combinationItems.containsKey(combinationId)) {
      setState(() {
        combinationItems.remove(combinationId); // If already loaded, remove it.
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/combinations/$combinationId/items'));
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);

        if (responseJson['items'] != null && responseJson['items'] is List) {
          setState(() {
            combinationItems[combinationId] = (responseJson['items'] as List)
                .map((data) => CombinationItem.fromJson(data))
                .toList();
          });
        } else {
          throw Exception('Kombin öğeleri bulunamadı');
        }
      } else {
        throw Exception('Kombin öğeleri alınamadı');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kombin öğeleri alınırken hata oluştu: $e')),
      );
    }
  }

  Future<void> _deleteCombination(int combinationId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/combinations/$combinationId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          combinations.removeWhere((combination) => combination.id == combinationId);
          combinationItems.remove(combinationId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kombin başarıyla silindi!')),
        );
      } else {
        throw Exception('Kombin silinirken hata oluştu');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kombin silinirken hata oluştu: $e')),
      );
    }
  }

  Future<void> _deleteCombinationItem(int combinationId, int itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/combinations/$combinationId/items/$itemId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          combinationItems[combinationId]?.removeWhere((item) => item.id == itemId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kombin öğesi başarıyla silindi!')),
        );
      } else {
        throw Exception('Kombin öğesi silinirken hata oluştu');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kombin öğesi silinirken hata oluştu: $e')),
      );
    }
  }

  void _navigateToUpdateCombinationPage(Combination combination) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateCombinationPage(
          combination: combination,
          combinationItems: combinationItems[combination.id] ?? [],
        ),
      ),
    );

    if (result == true) {
      _fetchCombinations(); // Güncelleme sonrası kombinleri yeniden yükle
    }
  }

  void _navigateToClothingPage(int combinationId) async {
    final selectedClothing = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClothingPage(),
      ),
    );

    if (selectedClothing != null && selectedClothing is List<int>) {
      _addClothingToCombination(combinationId, selectedClothing);
    }
  }

  Future<void> _addClothingToCombination(int combinationId, List<int> clothingIds) async {
    final url = Uri.parse('http://10.0.2.2:3000/combinations/$combinationId/items');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'clothing_ids': clothingIds,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kıyafetler başarıyla eklendi!')),
        );

        // **Yeniden veri çek ve UI güncelle**
        await _fetchCombinationItems(combinationId);

        // **State'i zorla güncelle**
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kıyafetler eklenirken hata oluştu: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kıyafetler eklenirken hata oluştu: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kombinlerim", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: combinations.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: combinations.length,
        itemBuilder: (context, index) {
          final combination = combinations[index];

          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: ExpansionTile(
              backgroundColor: Colors.teal.withOpacity(0.1),
              title: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.teal),
                  SizedBox(width: 10),
                  Text(
                    combination.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.teal[800],
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                combination.description,
                style: TextStyle(color: Colors.teal[600], fontStyle: FontStyle.italic),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.teal),
                    onPressed: () {
                      _navigateToUpdateCombinationPage(combination);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteCombination(combination.id);
                    },
                  ),
                ],
              ),
              onExpansionChanged: (isExpanded) {
                if (isExpanded) {
                  _fetchCombinationItems(combination.id);
                } else {
                  setState(() {
                    combinationItems.remove(combination.id); // Close and remove items
                  });
                }
              },
              children: [
                if (combinationItems[combination.id] != null)
                  ...combinationItems[combination.id]!.map((item) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: Image.network(
                          item.photoPath,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text('${item.brand} - ${item.category}', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Renk: ${getColorNameFromRgb(item.color)}, Beden: ${item.size}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteCombinationItem(combination.id, item.id);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                if (combinationItems[combination.id] == null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("", style: TextStyle(color: Colors.red)),
                  ),
                // + Butonu
                ListTile(
                  leading: Icon(Icons.add, color: Colors.teal),
                  title: Text('Kıyafet Ekle'),
                  onTap: () {
                    _navigateToClothingPage(combination.id); // Kıyafet ekleme sayfasına yönlendir
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}