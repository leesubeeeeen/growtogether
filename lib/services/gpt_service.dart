import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GptService {
  Future<String> getAnswerFromMessages(List<Map<String, String>> messages) async {
    final apiKey = kIsWeb
        ? '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'
        : dotenv.env['OPENAI_API_KEY'];

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": messages,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final json = jsonDecode(decoded);
      return json['choices'][0]['message']['content'];
    } else {
      print("GPT 호출 실패 ❌");
      print("Status code: ${response.statusCode}");
      print("Body: ${response.body}");
      return '문제가 발생했어요 😥';
    }
  }
}
