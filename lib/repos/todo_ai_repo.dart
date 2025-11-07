import 'dart:convert';
import 'package:http/http.dart' as http;

/// Firebase Functions 프록시를 통해 안전하게 OpenAI에 요청.
/// - 웹 번들에 키가 포함되지 않음
/// - 동일한 페이로드 구조( model + messages ) 유지
class TodoAiRepo {
  static const String _base =
  String.fromEnvironment('API_BASE', defaultValue: '/api');

  /// 입력:
  /// - task: 사용자 입력 텍스트
  /// - mySchedule / partnerSchedule: List<Map> (CalendarEvent.toJson())
  /// - myFeeling / partnerFeeling: 😀 같은 이모지/텍스트
  ///
  /// 출력(Map):
  /// - time: "HH:mm"
  /// - reason: "문장"
  /// - assignedTo: "me" | "partner"
  Future<Map<String, dynamic>> recommendTodo({
    required String task,
    required List<Map<String, dynamic>> mySchedule,
    required String myFeeling,
    required List<Map<String, dynamic>> partnerSchedule,
    required String partnerFeeling,
  }) async {
    // 1) 시스템 프롬프트
    const systemPrompt = '''
너는 육아 일정 비서야.
규칙:
1. 아침(06:00~09:00) → 기상, 아침밥, 등원, 출근 준비
2. 오전(09:00~12:00) → 가벼운 집안일, 장보기
3. 오후(12:00~17:00) → 아이 하원, 놀이, 병원
4. 저녁(17:00~21:00) → 저녁식사, 목욕, 가족 시간
5. 밤(21:00~23:00) → 정리, 내일 준비
6. 이미 등록된 일정과 겹치면 절대 추천하지 않는다
7. 추천할 때 누구에게 할당할지도 (me | partner) 기분·피로도·일정을 고려한다

반드시 JSON 형식으로만 답하라:
{
  "assignedTo": "me" | "partner",
  "time": "HH:mm",
  "reason": "설명"
}
''';

    // 2) 사용자 프롬프트(일정/감정/요청 태스크를 JSON으로 전달)
    final userPayload = jsonEncode({
      'task': task,
      'mySchedule': mySchedule,
      'myFeeling': myFeeling,
      'partnerSchedule': partnerSchedule,
      'partnerFeeling': partnerFeeling,
    });

    // 3) Chat Completions 페이로드
    final payload = {
      'model': 'gpt-4o-mini',
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPayload},
      ],
    };

    // 4) 프록시 호출
    final resp = await http.post(
      Uri.parse('$_base/openai/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('proxy ${resp.statusCode}: ${resp.body}');
    }

    // 5) 응답 파싱
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final content = body['choices']?[0]?['message']?['content']?.toString() ?? '{}';

    // 모델이 코드블록/텍스트를 섞어줄 수 있어 안전 파싱
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
    final jsonStr = jsonMatch != null ? jsonMatch.group(0)! : content;

    try {
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
      final assignedTo = (parsed['assignedTo'] ?? 'me').toString();
      final time = (parsed['time'] ?? '08:00').toString();
      final reason = (parsed['reason'] ?? '기본 추천').toString();
      return {
        'assignedTo': assignedTo,
        'time': time,
        'reason': reason,
      };
    } catch (_) {
      // 파싱 실패 시 기본값
      return {
        'assignedTo': 'me',
        'time': '08:00',
        'reason': '기본 추천',
      };
    }
  }
}
