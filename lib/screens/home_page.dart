import 'package:flutter/material.dart';
import '../widgets/calendar_box.dart';
import '../widgets/mood_box.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import '../widgets/bottom_navi_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDdaySection(),
              const SizedBox(height: 16),
              const CalendarBox(),
              const SizedBox(height: 20),
              const MoodBox(),
              const SizedBox(height: 24),
              _buildPlantImage(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
    );
  }

// _buildDdaySection, _buildPlantImage는 그대로


  Widget _buildDdaySection() {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: AppFonts.primaryFont, // const 제거
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Palette.black,
              ),
              children: [
                const TextSpan(text: '엄마 아빠 함께한지 '),
                TextSpan(
                  text: '+600일',
                  style: const TextStyle(
                    color: Palette.mainRed,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Text(
            '튼튼이와 함께한지 +100일',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Palette.greyText,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildPlantImage() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.mail_outline, size: 28),
          const SizedBox(height: 12),
          Image.asset(
            'assets/images/seedling_placeholder.png',
            height: 100,
          ),
        ],
      ),
    );
  }
}