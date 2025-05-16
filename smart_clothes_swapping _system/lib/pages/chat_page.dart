import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'inbox_page.dart';

class ChatScreen extends StatefulWidget {
  final int senderId;
  final int receiverId;

  ChatScreen({required this.senderId, required this.receiverId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> _chatMessages = [];

  Future<void> fetchChatMessages() async {
    final response = await http.get(
      Uri.parse(
        'http://10.0.2.2:3000/chat?senderId=${widget.senderId}&receiverId=${widget.receiverId}',
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        _chatMessages = json.decode(response.body)['messages'];
      });
    }
  }

  Future<void> sendMessage(String messageText) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/send-message'),
        body: json.encode({
          'sender_id': widget.senderId,
          'receiver_id': widget.receiverId,
          'message_text': messageText,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Mesaj başarıyla gönderildi, InboxScreen'i güncelle
        Navigator.pop(context); // ChatScreen'den çık
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InboxScreen(userId: widget.senderId),
          ),
        );
      } else {
        throw Exception('Mesaj gönderilemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Mesaj gönderilirken hata oluştu: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchChatMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mesajlaşma')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final chat = _chatMessages[index];
                final senderUsername = chat['senderUsername'];

                return ListTile(
                  title: Text(senderUsername),
                  subtitle: Text(chat['message_text'] ?? "Mesaj yok"),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:
                    InputDecoration(hintText: 'Mesajınızı yazın...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (_messageController.text.isNotEmpty) {
                      await sendMessage(_messageController.text);
                      _messageController.clear(); // Mesaj kutusunu temizle
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}