import 'package:flutter/material.dart';
import '../widgets/counselor_chat_page.dart';

class Counselor2Page extends StatelessWidget {
  const Counselor2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const CounselorChatPage(
      counselorName: '조용한 성실맘',
      imagePath: 'assets/images/counselor_2.png',
      themeColor: Color(0xFFE6ECF0),
    );
  }
}