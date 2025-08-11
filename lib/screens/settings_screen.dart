import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import 'start_screen.dart';
import 'connect_partner_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        elevation: 0,
        title: const Text(
          '설정',
          style: TextStyle(
            fontFamily: AppFonts.pretendard,
            fontWeight: FontWeight.bold,
            color: Palette.mainRed,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Palette.mainRed),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 정보
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('이름: ${user?.displayName ?? '이름 없음'}',
                      style: const TextStyle(fontFamily: AppFonts.pretendard)),
                  const SizedBox(height: 8),
                  Text('이메일: ${user?.email ?? ''}',
                      style: const TextStyle(fontFamily: AppFonts.pretendard)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 배우자 연결 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.mainRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConnectPartnerScreen(),
                    ),
                  );
                },
                child: const Text(
                  '배우자 연결하기',
                  style: TextStyle(
                    color: Palette.background,
                    fontFamily: AppFonts.pretendard,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 로그아웃 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const StartScreen()),
                        (route) => false,
                  );
                },
                child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    color: Palette.greyText,
                    fontFamily: AppFonts.pretendard,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
