import 'package:flutter/material.dart';
import 'package:url_ile_kiyafet_yukleme/pages/combination_list_page.dart';
import 'package:url_ile_kiyafet_yukleme/pages/inbox_page.dart';
import 'package:url_ile_kiyafet_yukleme/pages/profile_page.dart';
import '../models/clothing.dart';
import '../pages/clothing_list_page.dart';
import '../pages/favorite_page.dart';
import '../pages/image_upload_page.dart';
import '../screen/image_picker_widget.dart';
import '../screen/clothing_upload_screen.dart';
import '../screen/clothing_details_screen.dart';
import 'dart:io';

class MainScreen extends StatefulWidget {
  final int userId;
  const MainScreen({required this.userId});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<int> favoriteClothingIds = []; // Favori kıyafet ID'leri
  List<Clothing> clothingList = []; // Tüm kıyafetlerin listesi

  @override


  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kıyafet Yükleme Seçenekleri',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.link),
                title: Text('URL ile Yükle'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ImageUploadPage(userId: widget.userId),
                    ),
                  );
                },
              ),
              ImagePickerWidget(
                onImageSelected: (File image) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClothingUploadScreen(
                        userId: widget.userId.toString(),
                        image: image,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Sayfaları burada tanımlayın
  List<Widget> get _pages => [
        ClothingListPage(userId: widget.userId),
        Container(), // Boş container, çünkü artık bottom sheet kullanacağız
        FavoritePage(favoriteClothingIds: favoriteClothingIds, clothingList: clothingList, onAddToFavorites: _addToFavorites, onRemoveFromFavorites: _removeFromFavorites,userId: widget.userId),
        CombineListPage(),
        ProfileScreen(userId: widget.userId) // Profil sayfası
      ];

  void _onItemTapped(int index) {
    if (index == 1) {
      _showUploadOptions();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Favorilere ekleme fonksiyonu
  void _addToFavorites(int clothingId) {
    setState(() {
      if (!favoriteClothingIds.contains(clothingId)) {
        favoriteClothingIds.add(clothingId);
      }
    });
  }

  // Favorilerden çıkarma fonksiyonu
  void _removeFromFavorites(int clothingId) {
    setState(() {
      favoriteClothingIds.remove(clothingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Seçilen sayfayı göster
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Kıyafetler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_a_photo),
            label: 'Yükle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: Colors.red),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: 'Kombinler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}