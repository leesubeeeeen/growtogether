import 'package:flutter/material.dart';

class ConnectCompleteScreen extends StatelessWidget {
  const ConnectCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  'assets/images/seedling_placeholder.png', // 나중에 교체할 이미지
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
