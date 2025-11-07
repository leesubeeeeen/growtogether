import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// 웹/네이티브 공통: Functions 프록시(/api/openai/chat)만 사용
class GptService {
  static const String _base =
  String.fromEnvironment('API_BASE', defaultValue: '/api');

  Future<String> getAnswerFromMessages(List<Map<String, String>> messages) async {
    // 웹에서는 절대 .env 키를 사용하지 않음. (키 노출 방지)
    // 필요한 경우 네이티브 전용 경로에서만 dotenv/SDK를 쓴다.
    final payload = {
      'model': 'gpt-4o-mini',
      'messages': messages,
    };

    try {
      final resp = await http.post(
        Uri.parse('$_base/openai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        final choices = json['choices'] as List?;
        final content = choices?[0]?['message']?['content'] ?? '';
        return content.toString();
      }
      return '프록시 오류: ${resp.statusCode}\n${resp.body}';
    } catch (e) {
      return '네트워크 오류: $e';
    }
  }
}
