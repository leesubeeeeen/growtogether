import 'package:flutter/material.dart';

class AppFonts {
  static const String primaryFont = 'BMJUA';

    return ThemeData(
      fontFamily: primaryFont,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
      ),
    );
  }
}