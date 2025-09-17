import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/palette.dart';
import '../theme/fonts.dart';
import '../widgets/calendar_day_item.dart';
import '../widgets/schedule_item.dart';
import '../widgets/bottom_navi_bar.dart';
import '../providers/todo_provider.dart';
import '../providers/calendar_provider.dart';
import '../models/calendar_event.dart';
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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await context.read<TodoProvider>().loadTodosFromFirestore(uid);
    await context.read<CalendarProvider>().loadEventsFromFirestore(uid);
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TodoAiPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.buttonBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Expanded(child: _buildScheduleList(context)),
        ],
      ),
      bottomNavigationBar: buildBottomNavBar(context, 1),
    );
  }

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

  Widget _buildScheduleList(BuildContext context) {
    final calendar = context.watch<CalendarProvider>();
    final todos = context.watch<TodoProvider>().getTodosForSelectedDay();
    final selectedDate = calendar.selectedDate;
    final events = calendar.getEventsForDay(selectedDate);

    String _formatTimeRange(DateTime start, DateTime end) {
      String h(DateTime t) =>
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      return '${h(start)} - ${h(end)}';
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        // 📅 CalendarProvider에서 불러온 일정들
        ...events.map((event) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ScheduleItem(
            time: _formatTimeRange(event.start, event.end),
            title: event.title,
            content: event.content,
            location: event.location,
            parent: event.parent,
            icon: CalendarEvent.getIconFromString(event.icon),
            color: event.color,
          ),
        )),

        const SizedBox(height: 24),

        if (todos.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '내가 추가한 할 일',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Palette.black,
              ),
            ),
          ),

        ...todos.map((todo) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ScheduleItem(
            time: DateFormat.Hm().format(todo['date']),
            title: todo['title'] ?? '제목 없음',
            content: '사용자가 직접 추가한 일정',
            location: '장소 없음',
            parent: '나',
            icon: Icons.task_alt,
            color: Palette.greyBackground,
          ),
        )),
      ],
    );
  }
}
