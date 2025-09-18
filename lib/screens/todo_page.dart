import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/palette.dart';
import '../theme/fonts.dart';
import '../widgets/calendar_day_item.dart';
import '../widgets/bottom_navi_bar.dart';
import '../providers/todo_provider.dart';
import '../providers/calendar_provider.dart';
import 'todo_ai_page.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;

    // 최초 로딩
    await context.read<TodoProvider>().loadTodosFromFirestore(uid);

    // 날짜 동기화
    final today = DateTime.now();
    context.read<CalendarProvider>().selectDate(today);
    context.read<TodoProvider>().selectDate(today);
    setState(() => _focusedDay = today);
  }

  @override
  Widget build(BuildContext context) {
    final calendar = context.watch<CalendarProvider>();
    final selectedDate = calendar.selectedDate;

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Palette.background,
        elevation: 0,
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedDate.day.toString(),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Palette.black,
                  fontFamily: AppFonts.primaryFont,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.E('ko_KR').format(selectedDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: Palette.greyText,
                      fontFamily: AppFonts.primaryFont,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('M월 yyyy년', 'ko_KR').format(selectedDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: Palette.greyText,
                      fontFamily: AppFonts.primaryFont,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 24.0, right: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TodoAiPage()),
                );
                // 돌아왔을 때 새로고침
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null && mounted) {
                  await context.read<TodoProvider>().refreshForUser(uid);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.buttonBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                '+ 계획 추가',
                style: TextStyle(
                  color: Palette.mainRed,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.primaryFont,
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          _buildCalendarBar(context),
          const SizedBox(height: 12),
          Expanded(child: _buildTodoList(context)),
        ],
      ),
      bottomNavigationBar: buildBottomNavBar(context, 1),
    );
  }

  /// 상단 주간 캘린더 바
  Widget _buildCalendarBar(BuildContext context) {
    final calendar = context.watch<CalendarProvider>();
    final selectedDate = calendar.selectedDate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final currentDate =
          _focusedDay.add(Duration(days: index - _focusedDay.weekday + 1));
          final isSelected = currentDate.year == selectedDate.year &&
              currentDate.month == selectedDate.month &&
              currentDate.day == selectedDate.day;

          return GestureDetector(
            onTap: () {
              context.read<CalendarProvider>().selectDate(currentDate);
              context.read<TodoProvider>().selectDate(currentDate);
              setState(() => _focusedDay = currentDate);
            },
            child: CalendarDayItem(
              date: currentDate.day.toString(),
              week: DateFormat.E('ko_KR').format(currentDate),
              isSelected: isSelected,
            ),
          );
        }),
      ),
    );
  }

  /// 투두 리스트
  Widget _buildTodoList(BuildContext context) {
    final todos = context.watch<TodoProvider>().getTodosForSelectedDay();

    if (todos.isEmpty) {
      return const Center(
        child: Text(
          '오늘은 등록된 할 일이 없어요.',
          style: TextStyle(color: Palette.greyText),
        ),
      );
    }

    return FutureBuilder<Map<String, String>>(
      future: _loadUserNames(todos), // 🔹 UID → name 변환
      builder: (context, snapshot) {
        final nameMap = snapshot.data ?? {};

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: todos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final todo = todos[index];
            final DateTime? dt = todo['date'] as DateTime?;
            final timeStr =
            (dt != null) ? DateFormat.Hm().format(dt) : '시간 미정';

            final bool isTop = index == 0;

            final assignedUid = todo['assignedTo'] as String?;
            final assignedName = nameMap[assignedUid] ?? '알 수 없음';

            return _TodoTile(
              time: timeStr,
              title: todo['title'] ?? '제목 없음',
              content: '$assignedName에게 배정됨',
              location: '장소 없음',
              parent: assignedName,
              highlightTitle: isTop,
            );
          },
        );
      },
    );
  }

  /// UID → name 변환
  Future<Map<String, String>> _loadUserNames(
      List<Map<String, dynamic>> todos) async {
    final db = FirebaseFirestore.instance;
    final uids = todos
        .map((t) => t['assignedTo'] as String?)
        .whereType<String>()
        .toSet();

    final result = <String, String>{};
    for (final uid in uids) {
      final doc = await db.collection('users').doc(uid).get();
      if (doc.exists) {
        result[uid] = doc['name'] as String? ?? '알 수 없음';
      }
    }
    return result;
  }
}

/// 내부 전용 타일
class _TodoTile extends StatelessWidget {
  final String time, title, content, location, parent;
  final bool highlightTitle;

  const _TodoTile({
    required this.time,
    required this.title,
    required this.content,
    required this.location,
    required this.parent,
    required this.highlightTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 왼쪽 시간
        SizedBox(
          width: 64,
          child: Text(
            time,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              fontFamily: AppFonts.primaryFont,
              color: Palette.greyText,
            ),
          ),
        ),
        // 본문 카드
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Palette.greyBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.task_alt,
                        size: 20, color: Palette.greyText),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.primaryFont,
                        color:
                        highlightTitle ? Palette.mainRed : Palette.greyText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: AppFonts.primaryFont,
                    color: Palette.black,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 14, color: Palette.greyText),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 12,
                        color: Palette.greyText,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.person,
                        size: 14, color: Palette.greyText),
                    const SizedBox(width: 4),
                    Text(
                      parent,
                      style: TextStyle(
                        fontSize: 12,
                        color: Palette.greyText,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
