// file: lib/screens/todo_ai_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'add_schedule_bottom_screen.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import '../widgets/bottom_navi_bar.dart';

import '../models/suggestion.dart';
import '../repos/user_repo.dart';
import '../repos/event_repo.dart';
import '../repos/todo_repo.dart';
import '../repos/todo_ai_repo.dart';

import '../providers/todo_provider.dart';

import '../models/calendar_event.dart';


class TodoAiPage extends StatefulWidget {
  const TodoAiPage({super.key});

  @override
  State<TodoAiPage> createState() => _TodoAiPageState();
}

class _TodoAiPageState extends State<TodoAiPage> {
  final TextEditingController _controller = TextEditingController();
  Suggestion? _suggestion; // 추천 결과
  bool _loading = false;

  String _formatKo(DateTime dt) {
    try {
      return DateFormat('M월 d일 (E) a h:mm', 'ko_KR').format(dt);
    } catch (_) {
      return DateFormat('yyyy-MM-dd HH:mm').format(dt);
    }
  }

  Future<void> _onSubmit() async {
    final taskTitle = _controller.text.trim();
    if (taskTitle.isEmpty) return;

    setState(() {
      _loading = true;
      _suggestion = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userRepo = UserRepo();
      final eventRepo = EventRepo();

      final userDoc = await userRepo.userDoc(uid);
      final userData = userDoc.data() as Map<String, dynamic>?;
      final spouseUid = userData?['spouseUid'] as String?;

      final today = DateTime.now();

      // 🔹 타입을 확실히 지정
      final List<CalendarEvent> myEvents = await eventRepo.dayEvents(uid, today);
      final Map<String, dynamic> myEmotion =
      await userRepo.todayEmotion(uid, today);

      final List<CalendarEvent> partnerEvents = spouseUid != null
          ? await eventRepo.dayEvents(spouseUid, today)
          : <CalendarEvent>[];
      final Map<String, dynamic> partnerEmotion = spouseUid != null
          ? await userRepo.todayEmotion(spouseUid, today)
          : {'fatigue': 0.0, 'feeling': '😐'};

      // ✅ GPT 호출
      final aiRepo = TodoAiRepo();
      final result = await aiRepo.recommendTodo(
        task: taskTitle,
        mySchedule: myEvents.map((CalendarEvent e) => e.toJson()).toList(),
        myFeeling: myEmotion['feeling'] ?? '😐',
        partnerSchedule:
        partnerEvents.map((CalendarEvent e) => e.toJson()).toList(),
        partnerFeeling: partnerEmotion['feeling'] ?? '😐',
      );

      if (result.isNotEmpty) {
        final time = result['time'] ?? "08:00";
        final parts = time.split(":");
        final start = DateTime(today.year, today.month, today.day,
            int.parse(parts[0]), int.parse(parts[1]));
        final end = start.add(const Duration(hours: 1));

        setState(() {
          _suggestion = Suggestion(
            message: result['reason'] ?? '추천 이유 없음',
            start: start,
            end: end,
            assignedTo: result['assignedTo'] ?? 'me', slotLabel: '',
          );
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('추천을 만들지 못했어요.')),
        );
      }
    } catch (e, st) {
      debugPrint("❌ 추천 생성 에러: $e\n$st");
      setState(() => _loading = false);
    }
  }


  Future<void> _confirmSave({
    required String title,
    required DateTime start,
    required DateTime end,
    required String assignedTo, // 'me' | 'partner'
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // spouseUid 조회
      final userDoc = await UserRepo().userDoc(uid);
      final userData = userDoc.data() as Map<String, dynamic>?;
      final spouseUid = userData?['spouseUid'] as String?;

      // assignedTo → 실제 UID
      final assignedToUid = (assignedTo == 'me') ? uid : (spouseUid ?? uid);

      final String todoId = await TodoRepo().saveTodo(
        title: title,
        start: start,
        end: end,
        assignedToUid: assignedToUid,
        createEvent: false,
      );

      // 로컬 Provider 반영
      context.read<TodoProvider>().addTodo(
        id: todoId,
        title: title,
        date: start,
        done: false,
        assignedToUid: assignedToUid,
      );

      // 서버 동기화
      await context.read<TodoProvider>().refreshForUser(uid);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('할 일이 추가되었어요!')),
      );
      Navigator.pop(context);
    } catch (e, st) {
      debugPrint('❌ 저장 실패: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 중 오류: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: Palette.mainRed,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  '새로운 작업을 추가해봐요!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    fontFamily: AppFonts.primaryFont,
                    color: Palette.mainRed,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '무엇을 할까요?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.primaryFont,
                  color: Palette.black,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: '할 일을 적어봐요!',
                    hintStyle: TextStyle(
                      color: Palette.greyText,
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: false,
                  ),
                  onSubmitted: (_) => _onSubmit(),
                ),
              ),
              const SizedBox(height: 24),

              if (_loading && _suggestion == null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(width: 12),
                      Text("AI가 추천을 준비하고 있어요..."),
                    ],
                  ),
                ),
              ],

              if (_suggestion != null) ...[
                Text(
                  'AI가 추천해요!',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Palette.greyText,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline,
                              color: Palette.calmYellow),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _suggestion!.message,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                color: Palette.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: Palette.greyBorder),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Palette.mainRed),
                          const SizedBox(width: 6),
                          Text(_formatKo(_suggestion!.start),
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person,
                              size: 16, color: Palette.mainRed),
                          const SizedBox(width: 6),
                          Text(
                            _suggestion!.assignedTo == 'me' ? "나" : "배우자",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w100),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () async {
                    final todoText = _controller.text.trim();
                    if (todoText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('할 일을 입력해 주세요.')),
                      );
                      return;
                    }
                    await _confirmSave(
                      title: todoText,
                      start: _suggestion!.start,
                      end: _suggestion!.end,
                      assignedTo: _suggestion!.assignedTo,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.mainRed,
                    foregroundColor: Palette.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text(
                    '이렇게 할래요',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: () {
                    final todoText = _controller.text.trim();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => AddScheduleBottomScreen(
                        title: '추천된 일정을 수정해서 추가해볼까요?',
                        initialTitle: todoText,
                        initialStartTime:
                        TimeOfDay.fromDateTime(_suggestion!.start),
                        initialEndTime:
                        TimeOfDay.fromDateTime(_suggestion!.end),
                        initialDays: {
                          DateFormat.E('ko_KR').format(_suggestion!.start)
                        },
                        initialAssignedTo: _suggestion!.assignedTo,
                        onScheduleAdded: (updatedSchedule) async {
                          final String newTitle =
                          (updatedSchedule['title'] ?? todoText).toString();

                          final DateTime start =
                          (updatedSchedule['start'] is DateTime)
                              ? updatedSchedule['start']
                              : _suggestion!.start;
                          final DateTime end =
                          (updatedSchedule['end'] is DateTime)
                              ? updatedSchedule['end']
                              : _suggestion!.end;

                          final String newAssignedTo =
                              updatedSchedule['assignedTo'] as String? ??
                                  _suggestion!.assignedTo;

                          await _confirmSave(
                            title: newTitle,
                            start: start,
                            end: end,
                            assignedTo: newAssignedTo,
                          );
                          if (mounted) Navigator.pop(context);
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.lightRed,
                    foregroundColor: Palette.mainRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text(
                    '조금 수정할게요',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: () {
                    _controller.clear();
                    setState(() => _suggestion = null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.greyBackground,
                    foregroundColor: Palette.greyText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text(
                    '제가 직접할래요',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 3),
    );
  }
}
