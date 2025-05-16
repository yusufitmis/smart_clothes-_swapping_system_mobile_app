import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/clothing.dart'; // Clothing modelini import edin

class ClothingPage extends StatefulWidget {
  @override
  _ClothingPageState createState() => _ClothingPageState();
}

class _ClothingPageState extends State<ClothingPage> {
  List<Clothing> clothingList = [];
  List<int> selectedClothingIds = [];

  @override
  void initState() {
    super.initState();
    _fetchClothing();
  }

  Future<void> _fetchClothing() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/clothing'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          clothingList = data.map((item) => Clothing.fromJson(item)).toList();
        });
      } else {
        throw Exception('Kıyafetler alınamadı');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kıyafetler alınırken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kıyafet Seç'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, selectedClothingIds); // Seçilen kıyafet ID'lerini döndür
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: clothingList.length,
        itemBuilder: (context, index) {
          final clothing = clothingList[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: CheckboxListTile(
              title: Text('${clothing.brand} - ${clothing.category}'),
              subtitle: Text('Renk: ${clothing.color}, Beden: ${clothing.size}'),
              value: selectedClothingIds.contains(clothing.id),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedClothingIds.add(clothing.id);
                  } else {
                    selectedClothingIds.remove(clothing.id);
                  }
                });
              },
              secondary: Image.network(
                clothing.photoPath, // Kıyafetin resmi
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error); // Resim yüklenemezse hata ikonu göster
                },
              ),
            ),
          );
        },
      ),
    );
  }
}