import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/combination_item.dart';
import '../models/combination.dart';
import '../utils/color_utils.dart';
import 'combination_list_page.dart';

class UpdateCombinationPage extends StatefulWidget {
  final Combination combination;
  final List<CombinationItem> combinationItems;

  UpdateCombinationPage({required this.combination, required this.combinationItems});

  @override
  _UpdateCombinationPageState createState() => _UpdateCombinationPageState();
}

class _UpdateCombinationPageState extends State<UpdateCombinationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  List<CombinationItem> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.combination.name);
    _descriptionController = TextEditingController(text: widget.combination.description);
    _selectedItems = List.from(widget.combinationItems);
  }

  Future<void> _updateCombination() async {
    final url = Uri.parse('http://10.0.2.2:3000/combinations/${widget.combination.id}');
    final headers = {'Content-Type': 'application/json'};

    // Text box'lardan alınan değerler
    final String combinationName = _nameController.text; // Kombin adı
    final String combinationDescription = _descriptionController.text; // Kombin açıklaması

    final body = jsonEncode({
      'name': combinationName, // Text box'tan alınan kombin adı
      'description': combinationDescription, // Text box'tan alınan kombin açıklaması
    });

    try {
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Kombin başarıyla güncellendi!');

        // Güncelleme başarılı olduğunda combination_list_page sayfasına yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CombineListPage(),
          ),
        );
      } else {
        print('Hata: ${response.statusCode}');
      }
    } catch (e) {
      print('İstek sırasında hata oluştu: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kombin Güncelle',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Kombin Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kombin adını girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Açıklama'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen açıklama girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text('', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedItems.length,
                  itemBuilder: (context, index) {
                    final item = _selectedItems[index];
                    return ListTile(
                      leading: Image.network(
                        item.photoPath,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text('${item.brand} - ${item.category}'),
                      subtitle: Text('Renk: ${getColorNameFromRgb(item.color)}, Beden: ${item.size}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedItems.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _updateCombination,
                child: Text('Kombini Güncelle',style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}