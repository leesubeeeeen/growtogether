import 'package:flutter/material.dart';
import '../widgets/counselor_chat_page.dart';

class Counselor1Page extends StatelessWidget {
  const Counselor1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const CounselorChatPage(
      counselorName: '따뜻한 친정엄마',
      imagePath: 'assets/images/counselor_1.png',
      themeColor: Color(0xFFFFE3E3),
    );
  }
}