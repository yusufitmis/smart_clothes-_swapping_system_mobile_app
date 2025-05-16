import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ClothingDetailsScreen extends StatefulWidget {
  final String imagePath;
  final String userId; // user_id parametresi eklendi

  ClothingDetailsScreen({required this.imagePath, required this.userId});

  @override
  _ClothingDetailsScreenState createState() => _ClothingDetailsScreenState();
}

class _ClothingDetailsScreenState extends State<ClothingDetailsScreen> {
  String _selectedCategory = 'Seçiniz'; // Default "Seçiniz" category
  String _selectedColor = 'Seçiniz'; // Default "Seçiniz" color
  String _selectedSize = 'Seçiniz'; // Default "Seçiniz" size
  String _selectedBrand = 'Seçiniz'; // Default "Seçiniz" brand
  TextEditingController _otherBrandController =
      TextEditingController(); // For "Other" brand input

  final List<String> _categories = [
    'Seçiniz',
    'T-Shirt',
    'Sweatshirt',
    'Pantolon',
    'Ceket',
    'Gömlek',
    'Şort',
    'Elbise',
    'Etek',
    'Kazak',
    'Mont',
    'Ayakkabı',
    'Çanta',
    'Aksesuar'
  ];
  final List<String> _colors = [
    'Seçiniz',
    'Kırmızı',
    'Mavi',
    'Yeşil',
    'Siyah',
    'Beyaz',
    'Sarı',
    'Turuncu'
  ];
  final List<String> _sizes = ['Seçiniz', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _brands = [
    'Seçiniz',
    'Nike',
    'Adidas',
    'Puma',
    'Levi\'s',
    'Diğer'
  ];

  Future<void> _saveClothing(BuildContext context) async {
    if (_selectedCategory == 'Seçiniz' ||
        _selectedColor == 'Seçiniz' ||
        _selectedSize == 'Seçiniz' ||
        _selectedBrand == 'Seçiniz') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    String brand = _selectedBrand == 'Diğer'
        ? _otherBrandController.text.trim()
        : _selectedBrand;

    if (brand.isEmpty && _selectedBrand == 'Diğer') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen marka bilgisini girin')),
      );
      return;
    }

    final url = 'http://10.0.2.2:3000/addClothing'; // Node.js backend API URL
    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['category'] = _selectedCategory
      ..fields['color'] = _selectedColor
      ..fields['size'] = _selectedSize
      ..fields['brand'] = brand
      ..fields['user_id'] = widget.userId; // Backend'e user_id ekliyoruz

    if (widget.imagePath.isNotEmpty) {
      // Dosyayı yükle
      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        widget.imagePath,
      ));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kıyafet başarıyla kaydedildi')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Kayıt sırasında hata: ${response.reasonPhrase}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kıyafet Detayları')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Kategori Seçin:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                items:
                    _categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Renk Seçin:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _selectedColor,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedColor = newValue!;
                  });
                },
                items: _colors.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Beden Seçin:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _selectedSize,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSize = newValue!;
                  });
                },
                items: _sizes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Marka Seçin:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _selectedBrand,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBrand = newValue!;
                    if (_selectedBrand != 'Diğer') {
                      _otherBrandController
                          .clear(); // Clear the input if not "Diğer"
                    }
                  });
                },
                items: _brands.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                ),
              ),
              if (_selectedBrand == 'Diğer') ...[
                SizedBox(height: 10),
                Text(
                  'Lütfen markayı girin:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _otherBrandController,
                  decoration: InputDecoration(
                    hintText: 'Marka adı girin...',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                ),
              ],
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _saveClothing(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Kaydet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
