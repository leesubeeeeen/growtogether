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
              _buildTopRow(), // ✅ 디데이 + 설정 버튼 같이 있는 상단 행
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

  /// ✅ 디데이와 설정 버튼을 같은 줄에 배치
  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.settings, color: Palette.mainRed),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
        _buildDdaySection(),
      ],
    );
  }

  Widget _buildDdaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Palette.black,
            ),
            children: [
              const TextSpan(text: '엄마 아빠 함께한지 '),
              TextSpan(
                text: '+600일',
                style: const TextStyle(color: Palette.mainRed),
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
    );
  }

  Widget _buildPlantImage() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showPartnerPopup,
            child: const Icon(Icons.mail_outline, size: 28),
          ),
          const SizedBox(height: 12),
          Image.asset(
            'assets/images/seedling_placeholder.png',
            height: 100,
          ),
        ],
      ),
    );
  }

  bool isPartnerLinked = true; // 실제 연동 여부에 따라 변경
  void _showPartnerPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (isPartnerLinked) {
          final dummyMood = "피곤하지만 괜찮음 😊";
          final dummyFatigue = 4;

          return AlertDialog(
            title: const Text('배우자의 감정'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('오늘의 감정: $dummyMood'),
                const SizedBox(height: 8),
                Text('피로도: $dummyFatigue / 10'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: const Text('연동되지 않음'),
            content: const Text('아직 배우자와 연동되지 않았습니다.\n연동 설정으로 이동하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/link-partner');
                },
                child: const Text('연동하기'),
              ),
            ],
          );
        }
      },
    );
  }
}
