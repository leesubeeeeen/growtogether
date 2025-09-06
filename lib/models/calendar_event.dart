import 'package:flutter/material.dart';

class CalendarEvent {
  final String id; // Firestore용 or 중복방지용
  final String title;
  final String content;   // optional
  final String location;  // optional
  final String parent;    // optional
  final IconData icon;
  final Color color;
  final DateTime start;
  final DateTime end;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.content = '',
    this.location = '',
    this.parent = '',
    this.icon = Icons.event,
    this.color = Colors.grey,
  });
}
