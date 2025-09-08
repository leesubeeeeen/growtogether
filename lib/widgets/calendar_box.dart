import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';

class CalendarBox extends StatefulWidget {
  final DateTime initialSelectedDay;
  final DateTime initialFocusedDay;

  const CalendarBox({
    super.key,
    required this.initialSelectedDay,
    required this.initialFocusedDay,
  });

  @override
  State<CalendarBox> createState() => _CalendarBoxState();
}

class _CalendarBoxState extends State<CalendarBox> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialFocusedDay;
    _selectedDay = widget.initialSelectedDay;

    // 렌더링 보장용 (일부 디바이스에서 첫 진입 시 선택 안 되는 현상 방지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _focusedDay = widget.initialFocusedDay;
        _selectedDay = widget.initialSelectedDay;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.lightRed,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TableCalendar(
        locale: 'ko_KR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        availableCalendarFormats: const {
          CalendarFormat.week: '주간',
        },
        daysOfWeekHeight: 24,
        rowHeight: MediaQuery.of(context).size.height * 0.07,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        headerVisible: false,
        calendarStyle: CalendarStyle(
          defaultTextStyle: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 16,
            color: Colors.black,
          ),
          weekendTextStyle: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 16,
            color: Palette.mainRed,
          ),
          todayDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Palette.mainRed),
          ),
          selectedDecoration: const BoxDecoration(
            color: Palette.mainRed,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          todayTextStyle: TextStyle(
            color: Palette.mainRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Colors.black87,
            fontSize: 14,
          ),
          weekendStyle: TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Palette.mainRed,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
