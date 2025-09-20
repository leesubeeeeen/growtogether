import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:growtogether/services/gpt_service.dart';
import 'package:growtogether/theme/palette.dart';
import 'package:growtogether/widgets/todo_recommend_popup.dart';
import 'package:growtogether/providers/todo_provider.dart';
import 'package:growtogether/utils/gpt_utils.dart';
import 'package:growtogether/providers/calendar_provider.dart';
import 'package:growtogether/screens/add_schedule_bottom_screen.dart';
import 'package:growtogether/models/calendar_event.dart';
import 'package:growtogether/repos/todo_repo.dart';
import 'package:growtogether/repos/user_repo.dart';

class CounselorChatPage extends StatefulWidget {
  final String counselorName;
  final String imagePath;
  final Color themeColor;
  final String systemPrompt;

  const CounselorChatPage({
    super.key,
    required this.counselorName,
    required this.imagePath,
    required this.themeColor,
    required this.systemPrompt,
  });

  @override
  State<CounselorChatPage> createState() => _CounselorChatPageState();
}

class _CounselorChatPageState extends State<CounselorChatPage> {
  final List<Map<String, String>> _chatHistory = [];
  final TextEditingController _controller = TextEditingController();

  bool _showPopup = false;
  String _todoSuggestion = "";

  Future<String?> _askAssignee() async {
    // '나' 또는 '배우자' 선택 다이얼로그. 반환: 'me' | 'partner' | null
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('누구에게 배정할까요?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.person, color: Palette.mainRed),
                  title: const Text('나에게'),
                  onTap: () => Navigator.pop(context, 'me'),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite, color: Palette.mainRed),
                  title: const Text('배우자에게'),
                  onTap: () => Navigator.pop(context, 'partner'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveUnifiedTodo({
    required String title,
    required DateTime start,
    Duration duration = const Duration(minutes: 30),
    required String assignedTo, // 'me' | 'partner'
  }) async {
    final end = start.add(duration);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다.')),
        );
        return;
      }

      // spouseUid 조회
      final userDoc = await UserRepo().userDoc(uid);
      final userData = userDoc.data() as Map<String, dynamic>?;
      final spouseUid = userData?['spouseUid'] as String?;

      // ✅ 투두만 저장 (이벤트 생성 X → 투두 화면 중복 방지)
      // 🔹 assignedToUid를 확정 (me → 내 uid, partner → 배우자 uid)
      final assignedToUid = (assignedTo == 'me') ? uid : (spouseUid ?? uid);

      final String todoId = await TodoRepo().saveTodo(
        title: title,
        start: start,
        end: end,
        assignedToUid: assignedToUid, // ✅ 이제 UID만 넘김
        createEvent: false,
      );


      // 로컬에 즉시 넣는 대신 → 서버 권위로 재로딩(중복 표시 방지)
      await context.read<TodoProvider>().refreshForUser(uid);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('할 일을 추가했어요!')),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패(${e.code}): ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 중 오류: $e')),
      );
    }
  }

  DateTime? _parseTodayHmOrNull(String? hm) {
    if (hm == null) return null;
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(hm.trim());
    if (m == null) return null;
    final h = int.tryParse(m.group(1)!);
    final mm = int.tryParse(m.group(2)!);
    if (h == null || mm == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, mm);
  }

  Future<void> _sendMessage() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _chatHistory.add({'role': 'user', 'message': question});
      _controller.clear();
    });

    final messages = _buildMessagesForGPT(widget.systemPrompt);
    final result = await GptService().getAnswerFromMessages(messages);

    setState(() {
      _chatHistory.add({'role': 'assistant', 'message': result});
    });

    final actions = extractRecommendedActions(result);
    if (actions.isNotEmpty) {
      setState(() {
        _todoSuggestion = actions.first; // 예: 첫 번째만 제안
        _showPopup = true;
      });
    }
  }

  List<Map<String, String>> _buildMessagesForGPT(String systemPrompt) {
    final messages = <Map<String, String>>[
      {"role": "system", "content": systemPrompt},
    ];
    for (final chat in _chatHistory) {
      messages.add({
        "role": chat["role"]!,
        "content": chat["message"]!,
      });
    }
    return messages;
  }

  Widget _buildChatCard(String role, String message) {
    final isUser = role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        padding: const EdgeInsets.all(12.0),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? Palette.softRed : widget.themeColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(message, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F9),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 헤더
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios, size: 20),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundImage: AssetImage(widget.imagePath),
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.counselorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Palette.mainRed,
                              ),
                            ),
                            const Text(
                              '• Online',
                              style: TextStyle(
                                color: Color(0xFF4A705E),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.settings, color: Palette.greyText),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                const Text(
                  '이 시기에는 이런 질문이 많아요 😊',
                  style: TextStyle(fontSize: 15, color: Palette.black),
                ),
                const SizedBox(height: 12),

                // 채팅 리스트
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: _chatHistory.length,
                    itemBuilder: (context, index) {
                      final role = _chatHistory[index]['role']!;
                      final message = _chatHistory[index]['message']!;
                      return _buildChatCard(role, message);
                    },
                  ),
                ),

                // 메시지 입력창
                Container(
                  margin: const EdgeInsets.all(16.0),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration.collapsed(
                            hintText: '궁금한 점을 뭐든지 물어보세요',
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Palette.mainRed),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 🟡 추천 팝업
            if (_showPopup)
              TodoRecommendPopup(
                recommendationText: _todoSuggestion,
                onAdd: () async {
                  final when = DateTime.now();
                  final assignee = await _askAssignee();
                  if (assignee == null) return;

                  await _saveUnifiedTodo(
                    title: _todoSuggestion,
                    start: when,
                    assignedTo: assignee,
                  );

                  if (mounted) setState(() => _showPopup = false);
                },
                onEdit: () async {
                  setState(() => _showPopup = false);

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => AddScheduleBottomScreen(
                      title: '추천된 일정을 수정해서 추가해볼까요?', // ✅ 필수 파라미터 추가
                      onScheduleAdded: (updated) async {
                        DateTime? start = updated['start'] is DateTime
                            ? updated['start']
                            : _parseTodayHmOrNull(updated['time']?.toString());
                        start ??= DateTime.now();

                        final title =
                        (updated['title'] ?? _todoSuggestion).toString();

                        // 저장 대상 선택
                        final assignee = await _askAssignee();
                        if (assignee == null) return;

                        await _saveUnifiedTodo(
                          title: title,
                          start: start,
                          assignedTo: assignee,
                        );
                      },
                      initialTitle: _todoSuggestion,
                      initialStartTime: const TimeOfDay(hour: 9, minute: 0),
                      initialEndTime: const TimeOfDay(hour: 9, minute: 30),
                      initialDays: {"월"},
                    ),

                  );
                },
                onDismiss: () => setState(() => _showPopup = false),
              ),
          ],
        ),
      ),
    );
  }
}
