import 'ai_client_stub.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:dart_openai/dart_openai.dart';

class AiClientImpl implements AiClient {
  AiClientImpl() {
    // final key = dotenv.env['OPENAI_API_KEY'];
    // if (key != null && key.isNotEmpty) OpenAI.apiKey = key;
  }

  @override
  Future<Map<String, dynamic>> chat({
    required List<Map<String, dynamic>> messages,
    String model = 'gpt-4o-mini',
    Map<String, dynamic>? extra,
  }) async {
    // 네이티브에서만 OpenAI SDK를 사용하고 싶다면 여기에 구현
    // 지금은 웹과 동일하게 프록시를 쓰지 않도록 빈 구현으로 둔다.
    throw UnimplementedError('Implement native SDK call if needed');
  }
}

AiClient aiClient() => AiClientImpl();
