import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEvent {
  final String? id;
  final String title;
  final String content;
  final String location;
  final String parent;
  final String icon;   // Firestore에는 String으로 저장
  final Color color;
  final DateTime start;
  final DateTime end;

  CalendarEvent({
    this.id,          // ← required 제거
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

  factory CalendarEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CalendarEvent(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      location: data['location'] ?? '',
      parent: data['parent'] ?? '',
      start: (data['start'] as Timestamp).toDate(),
      end: (data['end'] as Timestamp).toDate(),
      icon: data['icon'] ?? 'event',
      color: Colors.blue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'location': location,
      'parent': parent,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'icon': icon,
      'color': color.value.toRadixString(16),
    };
  }

}
