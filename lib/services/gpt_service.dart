///OpenAI GPT 호출 함수
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GptService {
  Future<String> getAnswer(String prompt) async {
    // 여기에 실제 GPT API 호출 코드 작성
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "user", "content": prompt}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['choices'][0]['message']['content'];
    } else {
      return '문제가 발생했어요 😥';
    }
  }
}
