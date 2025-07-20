import 'package:flutter/material.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import 'todo_ai_page.dart';
import '../widgets/calendar_day_item.dart';
import '../widgets/schedule_item.dart';
import '../widgets/bottom_navi_bar.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';


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
          _buildCalendarBar(),
          const SizedBox(height: 12),
          Expanded(child: _buildScheduleList(context)),
        ],
      ),
      bottomNavigationBar: buildBottomNavBar(context, 1),
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



  Widget _buildScheduleList(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final todos = todoProvider.todos;

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

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: item,
        )),
        const SizedBox(height: 12),
        if (todos.isNotEmpty)
          const Text(
            '내가 추가한 할 일',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Palette.black,
            ),
          ),
        ...todos.map((todo) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ScheduleItem(
            time: '시간 미정',
            title: todo,
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