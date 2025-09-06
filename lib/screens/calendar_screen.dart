import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import '../widgets/bottom_navi_bar.dart';
import 'dart:async';


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, Map<String, dynamic>> _emotionsByDate = {};
  StreamSubscription? _emotionSub;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _subscribeToEmotions();
  }

  void _subscribeToEmotions() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _emotionSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('emotions')
        .snapshots()
        .listen((snapshot) {
      final data = <String, Map<String, dynamic>>{};
      for (var doc in snapshot.docs) {
        final dateKey = doc.id; // YYYY-MM-DD
        data[dateKey] = {
          'feeling': doc['feeling'],
          'fatigue': doc['fatigue'],
        };
      }
      setState(() {
        _emotionsByDate = data;
      });
    });
  }

  @override
  void dispose() {
    _emotionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildMonthHeader(),
            Expanded(
              child: TableCalendar(
                locale: 'ko_KR',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                headerVisible: false,
                rowHeight: 80,
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(),
                  selectedDecoration: BoxDecoration(),
                  defaultDecoration: BoxDecoration(),
                  weekendDecoration: BoxDecoration(),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) =>
                      _buildDayCell(day),
                  todayBuilder: (context, day, focusedDay) =>
                      _buildDayCell(day, isToday: true),
                  selectedBuilder: (context, day, focusedDay) =>
                      _buildDayCell(day, selected: true),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 0),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Palette.mainRed),
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(
                  _focusedDay.year, _focusedDay.month - 1, _focusedDay.day);
            });
          },
        ),
        Column(
          children: [
            Text(
              '${_focusedDay.month}월',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.pretendard,
              ),
            ),
            Text(
              '${_focusedDay.year}',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: AppFonts.pretendard,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded,
              color: Palette.mainRed),
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(
                  _focusedDay.year, _focusedDay.month + 1, _focusedDay.day);
            });
          },
        ),
      ],
    );
  }

  Widget _buildDayCell(DateTime day,
      {bool isToday = false, bool selected = false}) {
    final dateKey = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    final feeling = _emotionsByDate[dateKey]?['feeling'] ?? '';
    final fatigue = _emotionsByDate[dateKey]?['fatigue'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 날짜 숫자
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: Palette.mainRed, width: 1.5)
                : null,
            color: selected ? Palette.mainRed : null,
          ),
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 14,
              color: selected
                  ? Colors.white
                  : isToday
                  ? Palette.mainRed
                  : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // 이모티콘
        SizedBox(
          height: 20,
          child: Text(
            feeling,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 2),
        // 피로도
        SizedBox(
          height: 16,
          child: fatigue != null
              ? Text(
            '${fatigue.toInt()}%',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
