import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/clothing.dart';
import '../blocs/combination_bloc.dart';

class CreateCombinationPage extends StatefulWidget {
  final List<Clothing> selectedClothing;

  CreateCombinationPage({required this.selectedClothing});

  @override
  _CreateCombinationPageState createState() => _CreateCombinationPageState();
}

class _CreateCombinationPageState extends State<CreateCombinationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kombin Oluştur', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal, // Matching the other pages' app bar color
        elevation: 0, // Optional: Removes shadow for a clean look
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Kombin Adı',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Kombin Açıklaması',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity, // Makes the button full width
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty &&
                        _descriptionController.text.isNotEmpty) {
                      // Kombin oluşturma işlemi
                      BlocProvider.of<CombinationBloc>(context).add(
                        CreateCombination(
                          _nameController.text,
                          _descriptionController.text,
                          widget.selectedClothing
                              .map((clothing) => clothing.id)
                              .toList(),
                        ),
                      );
                      // After creating the combination, pop and reset selection in ClothingListPage
                      Navigator.pop(context, true); // Pass true to indicate success
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lütfen kombin adı ve açıklaması girin.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Set button color to match AppBar
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Kombin Oluştur',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
