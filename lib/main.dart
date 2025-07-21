import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/user_provider.dart';
import 'providers/partner_provider.dart';
import 'providers/emotion_provider.dart';
import 'providers/todo_provider.dart';

import 'screens/home_page.dart';
import 'screens/todo_page.dart';
import 'screens/todo_ai_page.dart';
import 'screens/counselor_selection_page.dart';
import 'pages/gpt_test_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null); // 한국 로케일 초기화

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PartnerProvider()),
        ChangeNotifierProvider(create: (_) => EmotionProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grow Together',
      initialRoute: '/home', // ✅ 홈화면을 시작점으로
      routes: {
        '/': (context) => const GPTTestPage(), // 필요 시 테스트 진입용
        '/home': (context) => const HomePage(),
        '/todo': (context) => const TodoPage(),
        '/todo-ai': (context) => const TodoAiPage(),
        '/chat': (context) => const CounselorSelectionPage(),
      },
    );
  }
}
