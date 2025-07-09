import 'package:flutter/material.dart';
import '../theme/palette.dart';

class MoodBox extends StatelessWidget {
  const MoodBox({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> emojis = ['🤪', '😊', '😐', '☹️', '😭', '😮', '😡'];
    final int selectedIndex = 1; // 예시: 두 번째 이모지 선택됨

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.lightRed,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            '오늘의 상태를 알려주세요',
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: emojis.asMap().entries.map((entry) {
              final int idx = entry.key;
              final String emoji = entry.value;
              final bool isSelected = idx == selectedIndex;

              return Expanded(
                child: Center(
                  child: Container(
                    width: 40, // 안드로이드에서 안정적인 터치 크기
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Palette.mainRed : Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      emoji,
                      style: TextStyle(
                        fontSize: 24,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Slider(
            value: 0.7,
            onChanged: (_) {},
            activeColor: Palette.calmYellow,
            inactiveColor: Palette.greyBorder,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.bolt, color: Palette.calmYellow, size: 20),
              SizedBox(width: 6),
              Text('70%', style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}