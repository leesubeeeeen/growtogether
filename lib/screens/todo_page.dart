import 'package:flutter/material.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import 'todo_ai_page.dart';
import '../widgets/calendar_day_item.dart';
import '../widgets/schedule_item.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                '15',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Palette.black,
                  fontFamily: AppFonts.primaryFont,
                ),
              ),
              const SizedBox(width: 12), // 좌우 간격
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '목요일',
                    style: TextStyle(
                      fontSize: 14,
                      color: Palette.greyText,
                      fontFamily: AppFonts.primaryFont,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '6월 2025',
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
                  Navigator.pushNamed(context, '/todo-ai'); // ✅ TodoAiPage로 이동
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
          _buildCalendarBar(),
          const SizedBox(height: 12),
          Expanded(child: _buildScheduleList()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Palette.mainRed,
        unselectedItemColor: Palette.greyText,
        onTap: (index) {
          switch (index) {
            case 0: break; // 캘린더 (아직 기능 없음)
            case 1: break; // 현재 페이지
            case 2: Navigator.pushNamed(context, '/'); break; // ✅ HomePage
            case 3: break; // 검색
            case 4: Navigator.pushNamed(context, '/chat'); break; // ✅ ChatAdvicePage
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  Widget _buildCalendarBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final dates = ['12', '13', '14', '15', '16', '17', '18'];
          final week = ['월', '화', '수', '목', '금', '토', '일'];
          final isSelected = index == 3; // 예: 목요일 선택됨

          return CalendarDayItem(
            date: dates[index],
            week: week[index],
            isSelected: isSelected,
          );
        }),
      ),
    );
  }



  Widget _buildScheduleList() {
    final items = [
      ScheduleItem(
        time: '9:15 - 10:00',
        title: '아이 아침 식사',
        content: '새우애호박볶음, 무나물, 배추무침',
        location: '우리집',
        parent: '마미',
        icon: Icons.breakfast_dining,
        color: Palette.mealBox,
      ),
      ScheduleItem(
        time: '10:00 - 11:00',
        title: '아이 씻기기',
        content: '물놀이처럼 즐겁게 씻어요',
        location: '우리집',
        parent: '대디',
        icon: Icons.bathtub,
        color: Palette.washBox,
      ),
      ScheduleItem(
        time: '11:00 - 13:00',
        title: '아이 유치원 등원',
        content: '오늘도 씩씩하게 잘 다녀오자!',
        location: '금빛어린이집',
        parent: '대디',
        icon: Icons.directions_bus,
        color: Palette.schoolBox,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: items.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: items[index],
      ),
    );
  }
}