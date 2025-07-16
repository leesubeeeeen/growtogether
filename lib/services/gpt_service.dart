///OpenAI GPT 호출 함수
import 'package:http/http.dart' as http;
import 'dart:convert';

class GPTService {
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<String> getChatResponse(String userInput, String systemPrompt) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": userInput}
          ],
          "temperature": 0.7,
          "max_tokens": 400
        }),
      );

      if (response.statusCode == 200) {
        // ✅ 한글 깨짐 방지용 디코딩
        final decodedBody = utf8.decode(response.bodyBytes);
        final json = jsonDecode(decodedBody);
        return json['choices'][0]['message']['content'];
      } else {
        print('에러 응답: ${response.body}');
        throw Exception('GPT 응답 실패');
      }
    } catch (e) {
      print('에러 발생: $e');
      return 'GPT 응답에 실패했어요 😢';
    }
  }
}
