import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/user_provider.dart';
import 'providers/partner_provider.dart';
import 'providers/emotion_provider.dart';
import 'providers/todo_provider.dart';

import 'screens/home_page.dart';
import 'screens/todo_page.dart';
import 'screens/todo_ai_page.dart';
import 'screens/counselor_selection_page.dart';
import 'screens/calendar_screen.dart';
import 'screens/connect_partner_screen.dart';
import 'screens/connect_complete_screen.dart';   // ✅ 추가
import 'screens/login_screen.dart';             // ✅ 추가
import 'screens/start_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await initializeDateFormatting('ko_KR', null);
  } catch (e, st) {
    debugPrint('🚨 Firebase/Intl 초기화 실패: $e\n$st');
  }
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PartnerProvider()),
        ChangeNotifierProvider(create: (_) => EmotionProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grow Together',
      // ✅ 시작 화면을 로그인으로
      initialRoute: '/start',
      routes: {
        '/start': (context) => const StartScreen(),
        '/login': (context) => const LoginScreen(),                 // ✅ 추가
        '/link-partner': (context) => const ConnectPartnerScreen(),
        '/connect-complete': (context) => const ConnectCompleteScreen(), // ✅ 추가
        '/home': (context) => const HomePage(),

        // 기존 라우트 유지
        '/todo': (context) => const TodoPage(),
        '/todo-ai': (context) => const TodoAiPage(),
        '/chat': (context) => const CounselorSelectionPage(),
        '/calendar': (context) => const CalendarScreen(),
      },
    );
  }
}
