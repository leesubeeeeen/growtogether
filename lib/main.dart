import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/home_page.dart';
import 'screens/todo_page.dart';
import 'screens/todo_ai_page.dart';
//import 'package:growtogether/screens/chat_advice_page.dart';
//브랜치 간 연결이 안 되어서 주석처리

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '육아 일정 앱',
      initialRoute: '/',  // 앱 시작 경로
      routes: {
        '/': (context) => const HomePage(),
        '/todo': (context) => const TodoPage(),
        '/todo-ai': (context) => const TodoAiPage(),
        //'/chat': (context) => const ChatAdvicePage(),
      },
    );
  }
}
