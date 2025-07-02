import 'package:flutter/material.dart';
import 'screens/start_screen.dart';
import 'screens/schedule_preference_page.dart';
import 'screens/add_schedule_bottom_screen.dart';
import 'screens/calendar_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null); // <-- 로케일 초기화
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalendarScreen(),
    );
  }
}
//
//StartScreen()