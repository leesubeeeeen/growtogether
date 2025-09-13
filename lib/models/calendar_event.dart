import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String content;
  final String location;
  final String parent;
  final String icon;   // Firestore에는 String으로 저장
  final Color color;
  final DateTime start;
  final DateTime end;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.content,
    required this.location,
    required this.parent,
    required this.icon,
    required this.color,
    required this.start,
    required this.end,
  });

  // 🔑 String → IconData 변환 함수
  static IconData getIconFromString(String iconName) {
    switch (iconName) {
      case 'task_alt':
        return Icons.task_alt;
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.event;
    }
  }

  factory CalendarEvent.fromFirestore(doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CalendarEvent(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      location: data['location'] ?? '',
      parent: data['parent'] ?? '',
      icon: data['icon'] ?? 'event', // String으로 저장됨
      color: Colors.grey.shade200,
      start: (data['start'] as Timestamp).toDate(),
      end: (data['end'] as Timestamp).toDate(),
    );
  }
}
