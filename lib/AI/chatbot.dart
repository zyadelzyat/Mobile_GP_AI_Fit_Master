import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(ChatBotApp());
}

class ChatBotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT Flutter Bot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatBotPage(),
    );
  }
}

class ChatBotPage extends StatefulWidget {
  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _chatMessages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final String apiKey = "your-openai-api-key"; // Replace with your API key

  Future<String> _getChatGPTResponse(String message) async {
    const apiUrl = "https://api.openai.com/v1/chat/completions";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": message},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['choices'][0]['message']['content'];
    } else {
      throw Exception("Failed to fetch response: ${response.body}");
    }
  }

  void _sendMessage() async {
    final userMessage = _messageController.text.trim();
    if (userMessage.isEmpty || _isLoading) return;

    setState(() {
      _chatMessages.add({"role": "user", "content": userMessage});
      _messageController.clear();
      _isLoading = true;
    });

    try {
      final botResponse = await _getChatGPTResponse(userMessage);
      setState(() {
        _chatMessages.add({"role": "bot", "content": botResponse});
      });
    } catch (error) {
      setState(() {
        _chatMessages.add({"role": "bot", "content": "Error: $error"});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ChatGPT Flutter Bot"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                final isUser = message['role'] == 'user';

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['content']!,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) ...[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CircularProgressIndicator(),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  child: Text("Send"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
