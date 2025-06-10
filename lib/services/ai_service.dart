import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static final _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  static Future<String> getResponse(String userMessage) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "You are a friendly, talkative AI assistant."},
          {"role": "user", "content": userMessage}
        ],
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      return "Sorry, I couldn't reach my brain right now.";
    }
  }
}