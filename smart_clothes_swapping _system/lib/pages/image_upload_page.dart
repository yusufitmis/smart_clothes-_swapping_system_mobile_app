import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/image_bloc.dart';
import '../events/image_event.dart';

class ImageUploadPage extends StatelessWidget {
  final int userId;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  ImageUploadPage({required this.userId});
  @override
  Widget build(BuildContext context) {
    final imageBloc = BlocProvider.of<ImageBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "URL ile Kıyafet Yükleme",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_urlController, 'Görsel URL\'si'),
              SizedBox(height: 16),
              _buildTextField(_brandController, 'Marka'),
              SizedBox(height: 16),
              _buildTextField(_sizeController, 'Boyut'),
              SizedBox(height: 16),
              _buildTextField(_categoryController, 'Kategori'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final url = _urlController.text.trim();
                  final brand = _brandController.text.trim();
                  final size = _sizeController.text.trim();
                  final category = _categoryController.text.trim();

                  if (url.isNotEmpty &&
                      brand.isNotEmpty &&
                      size.isNotEmpty &&
                      category.isNotEmpty) {
                    imageBloc.add(
                      ImageUrlSubmittedWithDetails(
                        url: url,
                        brand: brand,
                        size: size,
                        category: category,
                        userId: userId,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lütfen tüm alanları doldurun!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Buton rengi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Yükle',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              BlocConsumer<ImageBloc, ImageState>(
                listener: (context, state) {
                  if (state.status == ImageStatus.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kıyafet başarıyla yüklendi!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  // Hata durumunda hiçbir şey yapma (hata mesajı gösterme)
                },
                builder: (context, state) {
                  if (state.status == ImageStatus.loading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state.status == ImageStatus.success) {
                    if (state.images.isNotEmpty) {
                      final lastImage = state.images.last;
                      return Center(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                lastImage.path ?? '',
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Yüklenen Kıyafet Detayları:\nMarka: ${lastImage.brand ?? ''}\nBoyut: ${lastImage.size ?? ''}\nKategori: ${lastImage.category ?? ''}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(
                          'Henüz bir görsel yüklenmedi.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }
                  }
                  // Hata durumunda hiçbir şey gösterme (boş bir container döndür)
                  return Container();
                },
              ),
            ],
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
        labelStyle: TextStyle(fontSize: 16, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal, width: 1),
        ),
      ),
    );
  }
}
