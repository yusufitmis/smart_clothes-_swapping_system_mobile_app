import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ClothingUploadScreen extends StatefulWidget {
  final String userId;
  final File image;

  const ClothingUploadScreen({
    Key? key,
    required this.userId,
    required this.image,
  }) : super(key: key);

  @override
  _ClothingUploadScreenState createState() => _ClothingUploadScreenState();
}

class _ClothingUploadScreenState extends State<ClothingUploadScreen> {
  bool _isProcessing = false;
  bool _isBackgroundRemoved = false;
  late File _imageFile;

  // Form değişkenleri
  String _selectedCategory = 'Seçiniz';
  String _selectedColor = 'Seçiniz';
  String _selectedSize = 'Seçiniz';
  String _selectedBrand = 'Seçiniz';
  TextEditingController _otherBrandController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _imageFile = widget.image;
  }

  // Dropdown listeleri
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

  Future<void> _removeBackground() async {
    if (!mounted) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      final apiKey = 'UbhMMd9SnvWbttKCMfVqQVvU';
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.remove.bg/v1.0/removebg'),
      );
      request.headers['X-Api-Key'] = apiKey;
      request.files.add(
          await http.MultipartFile.fromPath('image_file', _imageFile.path));
      request.fields['size'] = 'auto';

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final bytes = responseData.bodyBytes;

        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/output.png';
        final outputFile = File(filePath)..writeAsBytesSync(bytes);

        if (!mounted) return;
        setState(() {
          _imageFile = outputFile;
          _isBackgroundRemoved = true;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arka plan başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Arka plan silme başarısız oldu: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _saveClothing() async {
    if (!_isBackgroundRemoved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen önce arka planı silin')),
      );
      return;
    }

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

    try {
      if (!mounted) return;
      setState(() {
        _isProcessing = true;
      });

      final url = 'http://10.0.2.2:3000/addClothing';
      print('Gönderilen veriler:');
      print('Kategori: $_selectedCategory');
      print('Renk: $_selectedColor');
      print('Beden: $_selectedSize');
      print('Marka: $brand');
      print('User ID: ${widget.userId}');
      print('Fotoğraf yolu: ${_imageFile.path}');

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Form alanlarını ekle
      request.fields['category'] = _selectedCategory;
      request.fields['color'] = _selectedColor;
      request.fields['size'] = _selectedSize;
      request.fields['brand'] = brand;
      request.fields['user_id'] = widget.userId;

      // Fotoğrafı ekle
      var photoStream = http.ByteStream(_imageFile.openRead());
      var photoLength = await _imageFile.length();
      var photoMultipartFile = http.MultipartFile(
        'photo',
        photoStream,
        photoLength,
        filename: path.basename(_imageFile.path),
      );
      request.files.add(photoMultipartFile);

      print('İstek gönderiliyor...');
      var response = await request.send();
      print('Yanıt alındı: ${response.statusCode}');

      var responseData = await response.stream.bytesToString();
      print('Backend yanıtı: $responseData');

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kıyafet başarıyla kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        print('Hata kodu: ${response.statusCode}');
        print('Hata mesajı: ${response.reasonPhrase}');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Kayıt sırasında hata: ${response.statusCode} - ${response.reasonPhrase}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Hata detayı: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bağlantı hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kıyafet Yükle'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _imageFile,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              if (!_isBackgroundRemoved)
                ElevatedButton.icon(
                  icon: Icon(Icons.remove_circle),
                  label: Text('Arka Planı Sil'),
                  onPressed: _isProcessing ? null : _removeBackground,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              if (_isProcessing) Center(child: CircularProgressIndicator()),
              SizedBox(height: 20),
              if (_isBackgroundRemoved) ...[
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
                        _otherBrandController.clear();
                      }
                    });
                  },
                  items: _brands.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                ),
                if (_selectedBrand == 'Diğer') ...[
                  SizedBox(height: 10),
                  TextField(
                    controller: _otherBrandController,
                    decoration: InputDecoration(
                      labelText: 'Marka adı girin...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveClothing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
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
            ],
          ),
        ),
      ),
    );
  }
}
