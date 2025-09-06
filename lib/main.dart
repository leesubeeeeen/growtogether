import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';


import 'package:flutter_dotenv/flutter_dotenv.dart';

// Providers
import 'providers/user_provider.dart';
import 'providers/partner_provider.dart';
import 'providers/emotion_provider.dart';
import 'providers/todo_provider.dart';
import 'providers/calendar_provider.dart';

// Screens
import 'screens/home_page.dart';
import 'screens/todo_page.dart';
import 'screens/todo_ai_page.dart';
import 'screens/counselor_selection_page.dart';
import 'screens/calendar_screen.dart';
import 'screens/connect_partner_screen.dart';
import 'screens/connect_complete_screen.dart';
import 'screens/login_screen.dart';
import 'screens/start_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/settings_screen.dart';

// Auth
import 'widgets/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ✅ Firestore 오프라인 캐시 설정
    FirebaseFirestore.instance.settings =
    const Settings(persistenceEnabled: true);

    // ✅ .env 설정 (웹 제외)
    if (!kIsWeb) {
      await dotenv.load(fileName: ".env");
      print("✅ .env 로드 성공: ${dotenv.env['OPENAI_API_KEY']}");
    }

    // ✅ Intl 한국어 초기화
    await initializeDateFormatting('ko_KR', null);
  } catch (e, st) {
    debugPrint('🚨 초기화 실패: $e\n$st');
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
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
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
      theme: ThemeData(
        fontFamily: 'BMJUA',
      ),

      // ✅ 시작 화면을 로그인으로
      initialRoute: '/start',
      // 시작점: 인증 게이트(로그인 상태에 따라 분기)
      home: const AuthGate(),
      // 모든 라우트를 합집합으로 등록
      routes: {
        '/start': (context) => const StartScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/link-partner': (context) => const ConnectPartnerScreen(),
        '/connect-complete': (context) => const ConnectCompleteScreen(),
        '/home': (context) => const HomePage(),
        '/todo': (context) => const TodoPage(),
        '/todo-ai': (context) => const TodoAiPage(),
        '/chat': (context) => const CounselorSelectionPage(),
        '/calendar': (context) => const CalendarScreen(),
      },
    );
  }
}
