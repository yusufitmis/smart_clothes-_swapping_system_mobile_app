import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_ile_kiyafet_yukleme/pages/profile_page.dart';


class ContactsScreen extends StatefulWidget {
  final int userId;

  ContactsScreen({required this.userId});

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _users = [];

  Future<void> searchContacts() async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:3000/search-users?query=${_searchController.text}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _users = json.decode(response.body)['users'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kişiler alınamadı.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kişiler')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Kişi ara',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: searchContacts,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];

                return ListTile(
                  title: Text(user['username']),
                  subtitle: Text(user['fullname']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          userId: widget.userId,
                          viewedUserId: user['id'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}