import 'package:flutter/material.dart';
import '../widgets/counselor_chat_page.dart';

class Counselor3Page extends StatelessWidget {
  const Counselor3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const CounselorChatPage(
      counselorName: '차분한 상담선생님',
      imagePath: 'assets/images/counselor_3.png',
      themeColor: Color(0xFFEFDAD5),
    );
  }
}