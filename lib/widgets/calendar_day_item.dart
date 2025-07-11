import 'package:flutter/material.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';

class CalendarDayItem extends StatelessWidget {
  final String date;
  final String week;
  final bool isSelected;

  const CalendarDayItem({
    super.key,
    required this.date,
    required this.week,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: isSelected ? Palette.mainRed : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            week,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Palette.greyText,
              fontFamily: AppFonts.primaryFont,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Palette.black,
              fontFamily: AppFonts.primaryFont,
            ),
          ),
        ],
      ),
    );
  }
}