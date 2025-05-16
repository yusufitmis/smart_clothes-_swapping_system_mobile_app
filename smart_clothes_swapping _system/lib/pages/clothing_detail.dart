import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/clothing.dart';
import '../blocs/image_bloc.dart';

class ClothingDetailPage extends StatefulWidget {
  final Clothing clothing;

  const ClothingDetailPage({
    Key? key,
    required this.clothing,
  }) : super(key: key);

  @override
  _ClothingDetailPageState createState() => _ClothingDetailPageState();
}

class _ClothingDetailPageState extends State<ClothingDetailPage> {
  late TextEditingController brandController;
  late TextEditingController categoryController;
  late TextEditingController sizeController;

  @override
  void initState() {
    super.initState();
    brandController = TextEditingController(text: widget.clothing.brand);
    categoryController = TextEditingController(text: widget.clothing.category);
    sizeController = TextEditingController(text: widget.clothing.size);
  }

  @override
  void dispose() {
    brandController.dispose();
    categoryController.dispose();
    sizeController.dispose();
    super.dispose();
  }

  void _updateClothing(BuildContext context) {
    final bloc = context.read<ImageBloc>();
    bloc.updateClothing(
      id: widget.clothing.id,
      brand: brandController.text,
      size: sizeController.text,
      category: categoryController.text,
    );
  }

  void _deleteClothing(BuildContext context) {
    final bloc = context.read<ImageBloc>();
    bloc.deleteClothing(widget.clothing.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ürün Detayları", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal[700],
        elevation: 0,
      ),
      body: BlocListener<ImageBloc, ImageState>(
        listener: (context, state) {
          if (state.status == ImageStatus.success) {
            Navigator.pop(context, true);
          } else if (state.status == ImageStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Hata: ${state.errorMessage}')),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: widget.clothing.photoPath.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      widget.clothing.photoPath,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Icon(
                    Icons.image_not_supported,
                    size: 250,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(brandController, 'Marka'),
                SizedBox(height: 15),
                _buildTextField(categoryController, 'Kategori'),
                SizedBox(height: 15),
                _buildTextField(sizeController, 'Beden'),
                SizedBox(height: 25),
                _buildButton('Güncelle', Colors.teal, _updateClothing),
                SizedBox(height: 15),
                _buildButton('Sil', Colors.red, _deleteClothing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.teal[50],
      ),
      style: TextStyle(color: Colors.teal[800]),
    );
  }

  Widget _buildButton(String text, Color color, Function(BuildContext) onPressed) {
    return ElevatedButton(
      onPressed: () => onPressed(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 16),
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
