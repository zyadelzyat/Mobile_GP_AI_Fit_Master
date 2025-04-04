import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Home__Page/00_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF232323),
        brightness: Brightness.dark,
      ),
      home: const ChatPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) async {
    setState(() {
      _messages.add({"role": "user", "message": text});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await GeminiAPI.sendMessage(text);
      setState(() {
        _messages.add({"role": "bot", "message": response});
      });
    } catch (e) {
      setState(() {
        _messages.add({"role": "bot", "message": "Error: ${e.toString()}"});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      appBar: AppBar(
        backgroundColor: const Color(0xFF232323),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.yellow, // Yellow back icon
            size: 20,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Chat",
                style: TextStyle(
                  color: Colors.purple[400],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: "bot",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const WelcomeWidget()
                : ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message["message"]!,
                  isUser: message["role"] == "user",
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                color: Colors.purple,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.grey[400]!, width: 1.2),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _sendMessage(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 60),
        Icon(
          Icons.support_agent,
          size: 80,
          color: Colors.white,
        ),
        SizedBox(height: 20),
        Text(
          "Hello",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "How Can I Help You?",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 40),
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.purple : Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class GeminiAPI {
  static const String apiKey = "AIzaSyA2sxJAf5ATKUNyf31y1ZNqaIF5jYHMPfI";
  static const String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": message}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey("candidates") &&
            data["candidates"].isNotEmpty &&
            data["candidates"][0].containsKey("content") &&
            data["candidates"][0]["content"].containsKey("parts") &&
            data["candidates"][0]["content"]["parts"].isNotEmpty) {
          return data["candidates"][0]["content"]["parts"][0]["text"];
        } else {
          return "Received an empty or invalid response from Gemini API";
        }
      } else {
        throw Exception("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      return "Error connecting to Gemini: ${e.toString()}";
    }
  }
}
