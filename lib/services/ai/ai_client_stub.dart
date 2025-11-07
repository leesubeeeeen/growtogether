import 'dart:convert';
import 'package:http/http.dart' as http;

/// 공통 기본 구현(웹에서도 동작): Firebase Functions 프록시로 호출
abstract class AiClient {
  Future<Map<String, dynamic>> chat({
    required List<Map<String, dynamic>> messages,
    String model,
    Map<String, dynamic>? extra,
  });
}

class DefaultAiClient implements AiClient {
  static const String _base =
  String.fromEnvironment('API_BASE', defaultValue: '/api');

  @override
  Future<Map<String, dynamic>> chat({
    required List<Map<String, dynamic>> messages,
    String model = 'gpt-4o-mini',
    Map<String, dynamic>? extra,
  }) async {
    final payload = {
      'model': model,
      'messages': messages,
      ...?extra,
    };
    final r = await http.post(
      Uri.parse('$_base/openai/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return jsonDecode(r.body) as Map<String, dynamic>;
    }
    throw Exception('proxy ${r.statusCode}: ${r.body}');
  }
}
