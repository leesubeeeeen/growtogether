import 'package:flutter/material.dart';
import 'screens/chat_advice_page.dart'; // ← 이 경로 맞는지 꼭 확인
import 'screens/connect_complete_screen.dart';
void main() {
  runApp(const GrowTogetherApp());
}

class GrowTogetherApp extends StatelessWidget {
  const GrowTogetherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grow Together',
      theme: ThemeData(
        fontFamily: 'Pretendard', // 너가 사용하는 폰트에 맞게 수정
        scaffoldBackgroundColor: const Color(0xFFFAF9F9),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const ConnectCompleteScreen(), // 앱 시작 시 보여줄 화면
    );
  }
}
