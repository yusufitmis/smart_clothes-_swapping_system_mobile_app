import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_ile_kiyafet_yukleme/pages/chat_page.dart';

class InboxScreen extends StatefulWidget {
  final int userId;

  const InboxScreen({required this.userId});

  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<Map<String, dynamic>> _messages = [];
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    fetchMessages();
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
            _notificationCount = _messages.length;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gelen Kutusu ($_notificationCount)'),
      ),
      body: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return ListTile(
            title: Text(message['senderUsername']),
            subtitle: Text(message['lastMessage']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    senderId: widget.userId,
                    receiverId: message['sender_id'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}