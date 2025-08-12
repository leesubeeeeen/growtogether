import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
import 'screens/connect_complete_screen.dart';
import 'screens/login_screen.dart';
import 'screens/start_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/settings_screen.dart';

import 'firebase_options.dart';
import 'widgets/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ dotenv 로드 시 로그 출력
  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env 로드 성공: ${dotenv.env['OPENAI_API_KEY']}");
  } catch (e) {
    print("⚠️ .env 로드 실패: $e");
  }

  await initializeDateFormatting('ko_KR', null);
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
      routes: {
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
      home: const AuthGate(),
    );
  }
}
