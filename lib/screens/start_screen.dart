import 'package:flutter/material.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Palette.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 이미지
              Image.asset(
                'assets/images/logo.png',
                width: w * 0.3,
                height: w * 0.3,
                fit: BoxFit.contain,
              ),

              SizedBox(height: h * 0.05),

              // 타이틀
              Text(
                '같이 키우기\n시작해볼까요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: w * 0.065,
                  fontWeight: FontWeight.bold,
                  color: Palette.mainRed,
                  fontFamily: AppFonts.pretendard,
                ),
              ),

              SizedBox(height: h * 0.08),

              // 로그인 버튼
              SizedBox(
                width: double.infinity,
                height: h * 0.065,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.mainRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.pretendard,
                      color: Palette.background,
                    ),
                  ),
                ),
              ),

              SizedBox(height: h * 0.025),

              // 가입하기 버튼
              SizedBox(
                width: double.infinity,
                height: h * 0.065,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFCEDE7),
                    foregroundColor: Palette.mainRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '가입하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.pretendard,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

