// lib/main.dart
import 'dart:ui' as ui; // 전역 에러 핸들러용

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
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

// Firebase / Auth
import 'firebase_options.dart';
import 'widgets/auth_gate.dart';

/// 🔧 빌드 타임 환경값(비밀 아님): 웹/네이티브 공통 API 베이스
/// flutter build 시 --dart-define=API_BASE=/api 로 주입(미주입 시 기본값 /api)
const apiBase = String.fromEnvironment('API_BASE', defaultValue: '/api');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 전역 에러 핸들러 (릴리스 빌드에서 원인 추적용)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    // ignore: avoid_print
    print('🔥 Uncaught: $error\n$stack');
    return true;
  };

  // 1) Firebase 초기화 (web 포함)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2) Intl (ko_KR 로케일)
  await initializeDateFormatting('ko_KR', null);

  // 3) .env는 "웹이 아닐 때만" 로드 (네이티브 로컬 개발용)
  if (!kIsWeb) {
    try {
      await dotenv.load(fileName: ".env");
      // 필요 시 네이티브에서 dotenv로 불러온 키를 사용 (웹에서는 절대 사용 금지)
      // final openaiKey = dotenv.env['OPENAI_API_KEY'];
      // if (openaiKey != null && openaiKey.isNotEmpty) { ... }
    } catch (_) {
      // 개발 편의를 위한 무시 (크래시 금지)
    }
  }

  // 4) 빌드 타임 주입값 확인(브라우저 Console에 찍힘)
  // ignore: avoid_print
  print('API_BASE = $apiBase');

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
