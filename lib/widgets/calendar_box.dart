import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅ locale 지원

class CalendarBox extends StatefulWidget {
  const CalendarBox({super.key});

  @override
  State<CalendarBox> createState() => _CalendarBoxState();
}

class _CalendarBoxState extends State<CalendarBox> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;

    // ✅ 한국어 날짜 포맷 초기화
    initializeDateFormatting('ko_KR', null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TableCalendar(
        locale: 'ko_KR',
        firstDay: DateTime.utc(2010, 1, 1),
        lastDay: DateTime.utc(2040, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.week, // ✅ 주간 캘린더
        availableCalendarFormats: const {
          CalendarFormat.week: '주간', // ✅ 월간으로 바꾸는 버튼 비활성화
        },

        // ✅ 상단 타이틀 & 네비게이션
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Palette.black,
          ),
          leftChevronIcon: const Icon(Icons.chevron_left, color: Palette.black),
          rightChevronIcon: const Icon(Icons.chevron_right, color: Palette.black),
        ),

        // ✅ 요일 스타일
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Palette.black.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Palette.mainRed,
            fontWeight: FontWeight.w600,
          ),
        ),

        rowHeight: 44, // ✅ 원형 안에 숫자 깔끔히
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

        // ✅ 날짜 스타일
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Palette.black,
            fontWeight: FontWeight.w600,
          ),
          weekendTextStyle: TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Palette.mainRed,
            fontWeight: FontWeight.w700,
          ),
          disabledTextStyle: TextStyle(
            fontFamily: AppFonts.primaryFont,
            color: Palette.black.withOpacity(0.25),
            fontWeight: FontWeight.w600,
          ),

          // 선택된 날
          selectedDecoration: const BoxDecoration(
            color: Palette.mainRed,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),

          // 오늘(선택과 구분)
          todayDecoration: BoxDecoration(
            border: Border.all(color: Palette.mainRed, width: 2),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: Palette.mainRed,
            fontWeight: FontWeight.w800,
            fontFamily: AppFonts.primaryFont,
          ),
        ),

        // ✅ 숫자가 가려지지 않도록 커스텀 빌더
        calendarBuilders: CalendarBuilders(
          selectedBuilder: (context, day, focusedDay) {
            return Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Palette.mainRed,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            final isSelected = isSameDay(day, _selectedDay);
            if (isSelected) return null; // 오늘이면서 선택된 날짜는 selectedBuilder 우선
            return Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Palette.mainRed, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: Palette.mainRed,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppFonts.primaryFont,
                  ),
                ),
              ),
            );
          },
          defaultBuilder: (context, day, focusedDay) => Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: Palette.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          outsideBuilder: (context, day, focusedDay) => Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: Palette.black.withOpacity(0.25),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // ✅ 날짜 선택
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },

        // ✅ 페이지 변경
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
      ),
    );
  }
}
