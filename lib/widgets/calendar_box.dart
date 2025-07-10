import 'package:flutter/material.dart';
import '../theme/palette.dart';

class CalendarBox extends StatelessWidget {
  const CalendarBox({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
    final List<int> dates = [12, 13, 14, 15, 16, 17, 18];
    final int selectedIndex = 3; // 예: 15일 선택됨

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.lightRed,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // ✅ 요일 텍스트 색상 지정
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.asMap().entries.map((entry) {
              final int idx = entry.key;
              final String day = entry.value;

              final bool isWeekend = idx == 5 || idx == 6; // 토(5), 일(6)

              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: isWeekend ? Palette.mainRed : Palette.greyText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // ✅ 날짜 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dates.asMap().entries.map((entry) {
              int idx = entry.key;
              int date = entry.value;
              final bool isSelected = idx == selectedIndex;

              return Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: isSelected
                        ? BoxDecoration(
                      color: Palette.mainRed,
                      shape: BoxShape.circle,
                    )
                        : null,
                    child: Text(
                      '$date',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}