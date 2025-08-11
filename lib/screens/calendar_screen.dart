import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:growtogether/widgets/bottom_navi_bar.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Palette.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: h * 0.02),

            // month title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Palette.mainRed, size: w * 0.06),
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                    });
                  },
                ),
                Column(
                  children: [
                    Text(
                      '${_focusedDay.month}월',
                      style: TextStyle(
                        fontSize: w * 0.07,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.pretendard,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '${_focusedDay.year}',
                      style: TextStyle(
                        fontSize: w * 0.04,
                        fontFamily: AppFonts.pretendard,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios_rounded,
                      color: Palette.mainRed, size: w * 0.06),
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: h * 0.01),

            TableCalendar(
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
              rowHeight: MediaQuery.of(context).size.height * 0.09, // ✅ 행 높이 넓힘
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(
                  fontFamily: AppFonts.primaryFont, // ✅ BMJUA
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  color: Colors.black,
                ),
                weekendTextStyle: TextStyle(
                  fontFamily: AppFonts.primaryFont, // ✅ BMJUA
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  color: Palette.mainRed,
                ),
                todayDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Palette.mainRed),
                ),
                selectedDecoration: BoxDecoration(
                  color: Palette.mainRed,
                  shape: BoxShape.circle,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontFamily: AppFonts.primaryFont, // ✅ BMJUA
                  color: Colors.black87,
                  fontSize: MediaQuery.of(context).size.width * 0.033,
                ),
                weekendStyle: TextStyle(
                  fontFamily: AppFonts.primaryFont, // ✅ BMJUA
                  color: Palette.mainRed,
                  fontSize: MediaQuery.of(context).size.width * 0.033,
                ),
              ),
            )


          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 0),
    );
  }
}
