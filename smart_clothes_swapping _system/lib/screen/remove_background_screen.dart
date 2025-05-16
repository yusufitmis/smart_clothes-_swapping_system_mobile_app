import 'package:flutter/material.dart';
import 'dart:io';
import 'image_picker_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'clothing_details_screen.dart';

class RemoveBackgroundScreen extends StatefulWidget {
  final String userId;
  RemoveBackgroundScreen({required this.userId});

  @override
  _RemoveBackgroundScreenState createState() => _RemoveBackgroundScreenState();
}

class _RemoveBackgroundScreenState extends State<RemoveBackgroundScreen> {
  File? _imageFile;
  bool _isProcessing = false;

  void _onImageSelected(File image) {
    setState(() {
      _imageFile = image;
    });
  }

  Future<void> _removeBackground() async {
    if (_imageFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    final apiKey = 'UbhMMd9SnvWbttKCMfVqQVvU';
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.remove.bg/v1.0/removebg'),
    );
    request.headers['X-Api-Key'] = apiKey;
    request.files
        .add(await http.MultipartFile.fromPath('image_file', _imageFile!.path));
    request.fields['size'] = 'auto';

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final bytes = responseData.bodyBytes;

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/output.png';
      final outputFile = File(filePath)..writeAsBytesSync(bytes);

      setState(() {
        _imageFile = outputFile;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClothingDetailsScreen(
            imagePath: _imageFile!.path,
            userId: widget.userId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Arka plan silme başarısız oldu: ${response.statusCode}')),
      );
    }

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Arka Plan Silme')),
      body: Column(
        children: [
          if (_imageFile != null)
            Expanded(
              child: Image.file(_imageFile!),
            )
          else
            Expanded(
              child: Center(child: Text('Bir fotoğraf seçin veya çekin')),
            ),
          if (_isProcessing)
            CircularProgressIndicator()
          else
            Column(
              children: [
                ImagePickerWidget(onImageSelected: _onImageSelected),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.remove_circle, size: 30),
                    label: Text('Arka Planı Sil ve Kaydet'),
                    onPressed: _removeBackground,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
