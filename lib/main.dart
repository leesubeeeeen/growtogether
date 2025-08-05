import 'package:flutter/material.dart';
import 'package:growtogether/providers/calendar_provider.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/partner_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
//import 'package:flutter/foundation.dart'; // kIsWeb용 import

//import 'package:intl/date_symbol_data_local.dart';
import 'providers/emotion_provider.dart';
import 'providers/todo_provider.dart';
import 'screens/home_page.dart';
import 'screens/todo_page.dart';
import 'screens/todo_ai_page.dart';
import 'screens/counselor_selection_page.dart';
import 'screens/calendar_screen.dart';
import 'screens/connect_partner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);

  // ✅ 웹이 아닐 때만 .env 파일 로드
 /* if (!kIsWeb) {
    await dotenv.load(fileName: ".env");
  }*/

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PartnerProvider()),
        ChangeNotifierProvider(create: (_) => EmotionProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
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
        '/home': (context) => const HomePage(),
        '/todo': (context) => const TodoPage(),
        '/todo-ai': (context) => const TodoAiPage(),
        '/chat': (context) => const CounselorSelectionPage(),
        '/calendar': (context) => const CalendarScreen(),
        '/link-partner': (context) => const ConnectPartnerScreen(), // ✅ 이 줄만 추가!
      },
    );
  }
}
