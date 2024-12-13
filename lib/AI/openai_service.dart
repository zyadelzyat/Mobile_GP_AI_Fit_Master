import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey = "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";

  Future<String> getChatGPTResponse(String prompt) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");
    final headers = {
      "Authorization": "Bearer $apiKey",
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "model": "gpt-3.5-turbo", // Use GPT-3.5 Turbo
      "messages": [
        {"role": "user", "content": prompt}
      ],
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else if (response.statusCode == 401) {
      throw Exception("Invalid API Key: ${response.body}");
    } else {
      throw Exception("Failed to load response: ${response.statusCode} - ${response.body}");
    }
  }
}
