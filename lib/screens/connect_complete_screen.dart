import 'package:flutter/material.dart';
import 'schedule_preference_page.dart'; // 요거 추가

class ConnectCompleteScreen extends StatelessWidget {
  const ConnectCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 여기서 2초 후 자동 이동
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SchedulePreferencePage()),
      );
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '연결 완료',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFFD26A5C),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 180,
                child: Image.asset(
                  'assets/images/seedling_placeholder.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      '🌱 캐릭터',
                      style: TextStyle(fontSize: 20),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
