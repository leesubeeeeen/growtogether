import 'package:flutter/material.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';

class ScheduleItem extends StatelessWidget {
  final String time, title, content, location, parent;
  final IconData icon;
  final Color color;

  const ScheduleItem({
    super.key,
    required this.time,
    required this.title,
    required this.content,
    required this.location,
    required this.parent,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ 왼쪽 시간 표시 복원
        SizedBox(
          width: 64,
          child: Text(
            time,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              fontFamily: AppFonts.primaryFont,
              color: Palette.greyText,
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: Palette.greyText),
                    const SizedBox(width: 8),
                    // ✅ 여기서만 조건부 색상 적용
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.primaryFont,
                        color: title == '아이 아침 식사'
                            ? Palette.mainRed
                            : Palette.greyText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: AppFonts.primaryFont,
                    color: Palette.black,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 14, color: Palette.greyText),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 12,
                        color: Palette.greyText,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.person, size: 14, color: Palette.greyText),
                    const SizedBox(width: 4),
                    Text(
                      '$parent',
                      style: TextStyle(
                        fontSize: 12,
                        color: Palette.greyText,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}