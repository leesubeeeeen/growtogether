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
    _selectedDay = _focusedDay;
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
          CalendarFormat.week: '주간', // ✅ 월간 전환 막기
        },
        headerVisible: false, // ✅ 상단 월 이름 숨기기

        rowHeight: 44,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },

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
          selectedDecoration: const BoxDecoration(
            color: Palette.mainRed,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
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
              // 선택된 날이면 selectedBuilder가 우선 적용됨
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
      ),
    );
  }
}
