import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:url_ile_kiyafet_yukleme/pages/chat_page.dart';
import 'package:url_ile_kiyafet_yukleme/pages/contacts_page.dart';
import 'package:url_ile_kiyafet_yukleme/pages/inbox_page.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  final int? viewedUserId; // Profile of another user to view

  const ProfileScreen({required this.userId, this.viewedUserId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profilePicturePath;
  String? _username;
  int? _userIdToDisplay;
  int _followerCount = 0; // Takipçi sayısını tutmak için
  final TextEditingController _postController = TextEditingController();
  List<Map<String, dynamic>> _posts = [];
  bool isFollowing = false; // Takip edilip edilmediğini kontrol etmek için
  List<Map<String, dynamic>> _messages = []; // Gelen mesajlar
  int _notificationCount = 0; // Bildirim sayısı


  // Profil bilgilerini al
  Future<void> fetchUserProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/user-profile?userId=$userId'),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _profilePicturePath = data['user']['profile_pic_path'];
            _username = data['user']['username'];
          });
        }
      } else {
        print('Error: Unable to fetch user profile');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }



  // Kullanıcının takipçi sayısını al
  Future<void> fetchFollowerCount(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/followers-count?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _followerCount = data['followers_count'] ?? 0;
        });
      } else {
        throw Exception('Error fetching follower count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching follower count: $e');
    }
  }

  // Kullanıcının gönderilerini al
  Future<void> fetchPosts(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/posts?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _posts = List<Map<String, dynamic>>.from(data).map((post) {
            if (post['image_path'] != null &&
                !post['image_path'].startsWith('http')) {
              post['image_path'] = 'http://10.0.2.2:3000/${post['image_path']}';
            }
            return post;
          }).toList();
        });
      } else {
        throw Exception('Error fetching posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching posts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gönderiler alınamadı.')),
      );
    }
  }

  // Takip etme işlemi
  Future<void> followUser() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/follow'),
        body: json.encode({
          'follower_id': widget.userId,
          'followed_id': widget.viewedUserId ?? widget.userId,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          isFollowing = true; // Takip edildi olarak işaretle
        });
        fetchFollowerCount(widget.viewedUserId ?? widget.userId); // Takipçi sayısını güncelle
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Takip edilmeye başlandı.')),
        );
      } else {
        final responseBody = json.decode(response.body);
        throw Exception('Takip etme işlemi başarısız: ${responseBody['message']}');
      }
    } catch (e) {
      print('Error following user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  Future<void> unfollowUser() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/unfollow'),
        body: json.encode({
          'follower_id': widget.userId,
          'followed_id': widget.viewedUserId ?? widget.userId,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          isFollowing = false; // Takipten çıkıldı olarak işaretle
        });
        fetchFollowerCount(widget.viewedUserId ?? widget.userId); // Takipçi sayısını güncelle
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Takipten çıkıldı.')),
        );
      } else {
        throw Exception('Takipten çıkma işlemi başarısız');
      }
    } catch (e) {
      print('Error unfollowing user: $e');
    }
  }


  Future<void> checkIfFollowing() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:3000/check-follow?follower_id=${widget.userId}&followed_id=${widget.viewedUserId ?? widget.userId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          isFollowing = data['isFollowing']; // Takip durumu güncelleniyor
        });
      } else {
        throw Exception('Takip durumu alınamadı');
      }
    } catch (e) {
      print('Error checking follow status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Takip durumu alınamadı: $e')),
      );
    }
  }


  // Profil fotoğrafını güncelle
  Future<void> updateProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:3000/update-profile-picture'),
    );
    request.fields['userId'] = widget.userId.toString();
    request.files.add(await http.MultipartFile.fromPath('profilePicture', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      setState(() {
        _profilePicturePath = jsonResponse['imagePath']; // Güncellenen fotoğraf URL'i
      });

      // Profil bilgilerini yeniden çek
      fetchUserProfile(widget.userId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil fotoğrafı güncellendi.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil fotoğrafı güncellenemedi.')),
      );
    }
  }

  // Gönderi oluştur
  Future<void> createPost() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hiç resim seçilmedi.')),
      );
      return;
    }

    final file = File(pickedFile.path);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:3000/create-post'),
    );
    request.fields['user_id'] = widget.userId.toString(); // Doğru userId'yi geçirin
    request.fields['content'] = _postController.text.trim();
    request.files.add(await http.MultipartFile.fromPath('image', file.path));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gönderi başarıyla oluşturuldu.')),
        );
        fetchPosts(widget.userId); // Yeni gönderiyi listeye ekle
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gönderi oluşturulamadı.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

  Future<void> fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/inbox?userId=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _messages = List<Map<String, dynamic>>.from(data['messages']);
            _notificationCount = _messages.length; // Bildirim sayısını güncelle
          });
        }
      } else {
        throw Exception('Mesajlar alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('Mesajlar alınırken hata oluştu: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    final userIdToFetch = widget.viewedUserId ?? widget.userId;
    fetchUserProfile(userIdToFetch);
    fetchPosts(userIdToFetch);
    fetchFollowerCount(userIdToFetch);
    checkIfFollowing();
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnProfile = widget.userId == (widget.viewedUserId ?? widget.userId);
    print('MainScreen userId: ${widget.userId}');
    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnProfile ? "Profiliniz" : "Profil: $_username",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: updateProfilePicture,
            ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactsScreen(userId: widget.userId),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.inbox),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InboxScreen(userId: widget.userId),
                ),
              );
            },
          ),
          if (!isOwnProfile)
            IconButton(
              icon: Icon(Icons.message),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      senderId: widget.userId,
                      receiverId: widget.viewedUserId ?? widget.userId,
                    ),
                  ),
                );
              },
            ),
          if (!isOwnProfile)
            IconButton(
              icon: Icon(isFollowing ? Icons.remove_circle : Icons.add_circle),
              onPressed: isFollowing ? unfollowUser : followUser,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    _profilePicturePath != null
                        ? CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        _profilePicturePath!.replaceAll('localhost', '10.0.2.2'),
                      ),
                    )
                        : CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person),
                    ),
                    SizedBox(height: 8),
                    Text('Takipçi Sayısı: $_followerCount'),
                  ],
                ),
              ),
              SizedBox(height: 16),

              Center(
                child: Text(
                  _username ?? "Yükleniyor...",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 32),
              if (isOwnProfile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Neler düşünüyorsunuz?"),
                    TextField(
                      controller: _postController,
                      decoration: InputDecoration(hintText: "Gönderinizi yazın..."),
                      maxLines: 3,
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: createPost,
                      child: Text('Paylaş'),
                    ),
                  ],
                ),
              SizedBox(height: 32),
              Text("Gönderiler:"),
              _posts.isEmpty
                  ? Text('Gönderi bulunmamaktadır.')
                  : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (post['image_path'] != null)
                          Image.network(post['image_path']),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Paylaşan: $_username'),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(post['content'] ?? 'Açıklama yok'),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Paylaşıldığı Tarih: ${post['created_at']}'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
