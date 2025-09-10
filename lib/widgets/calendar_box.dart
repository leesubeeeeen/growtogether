// lib/widgets/calendar_box.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';

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
    _selectedDay = _focusedDay; // ✅ 앱 첫 진입에 오늘 자동 선택
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
        firstDay: DateTime.utc(2010, 1, 1),
        lastDay: DateTime.utc(2040, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.week,
        availableCalendarFormats: const {
          CalendarFormat.week: '주간', // ✅ 월간으로 바꾸는 버튼 비활성화
        },
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
        rowHeight: 44, // 살짝 키워서 원형 안에 숫자 깔끔히 보이게
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

        // ✅ 숫자 가림 방지: 텍스트 스타일과 데코레이션을 모두 명시
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

        // ✅ 혹시 커스텀 빌더로 덮을 때도 숫자를 반드시 그림
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
            if (isSelected) {
              // 오늘이면서 선택된 날짜일 경우 -> selectedBuilder가 우선 적용되기 때문에 여기선 안 그려도 됨
              return null;
            }

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
                  '${day.day}', // ✅ 숫자 보여주기!
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

        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
      ),
    );
  }
}
