import 'package:flutter/material.dart';
import 'screens/start_screen.dart';
import 'screens/schedule_preference_page.dart';
import 'screens/add_schedule_bottom_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SchedulePreferencePage(),
    );
  }
}
//
//StartScreen()