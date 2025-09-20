import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';

class TodoAiRepo {
  Future<Map<String, dynamic>> recommendTodo({
    required String task,
    required List<Map<String, dynamic>> mySchedule,
    required String myFeeling,
    required List<Map<String, dynamic>> partnerSchedule,
    required String partnerFeeling,
  }) async {
    // ✅ OpenAIChat.create 로 호출
    final OpenAIChatCompletionModel response =  await OpenAI.instance.chat.create(   // ✅ 여기!
      model: "gpt-4o-mini",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system, // ✅ enum 사용
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text("""
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
"""),
          ],
        ),
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text("""
오늘 내 일정: $mySchedule
오늘 내 기분: $myFeeling
배우자 일정: $partnerSchedule
배우자 기분: $partnerFeeling
추천받고 싶은 태스크: $task
"""),
          ],
        ),
      ],
    );

    final raw = response.choices.first.message.content?.first.text ?? "{}";

    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      print("❌ JSON 파싱 실패: $raw");
      return {};
    }
  }
}
