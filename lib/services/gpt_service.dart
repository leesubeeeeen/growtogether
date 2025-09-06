import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GptService {
  Future<String> getAnswerFromMessages(List<Map<String, String>> messages) async {
    // ✅ 키 로드 우선순위: dotenv > 하드코딩 (fallback)
    final apiKey = dotenv.env['OPENAI_API_KEY']?.trim() ?? '';

    print("🔑 사용 중인 API Key: $apiKey");

    if (apiKey.isEmpty) {
      print("❌ API 키를 찾을 수 없습니다.");
      return 'API 키가 설정되지 않았습니다 😥';
    }

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    try {
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

      print("📡 상태 코드: ${response.statusCode}");
      print("📩 응답 내용: ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final json = jsonDecode(decoded);
        return json['choices'][0]['message']['content'];
      } else {
        return '문제가 발생했어요 😥';
      }
    } catch (e) {
      print("네트워크 오류 ❌: $e");
      return '네트워크 오류가 발생했어요 😥';
    }
  }
}
