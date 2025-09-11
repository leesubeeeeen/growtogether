import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEvent {
  final String id;          // Firestore 문서 ID
  final String title;
  final String content;     // optional
  final String location;    // optional
  final String parent;      // optional
  final IconData icon;      // UI용
  final Color color;        // UI용
  final DateTime start;
  final DateTime end;
  final String assignedTo;  // "me" | "partner" | uid

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
    this.assignedTo = 'me',
  });

  /// Firestore → CalendarEvent
  factory CalendarEvent.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CalendarEvent(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      location: data['location'] ?? '',
      parent: data['parent'] ?? '',
      start: (data['start'] as Timestamp).toDate(),
      end: (data['end'] as Timestamp).toDate(),
      assignedTo: data['assignedTo'] ?? 'me',
      // UI 값은 저장하지 않고 기본값 사용
      icon: Icons.event,
      color: Colors.grey,
    );
  }

  /// CalendarEvent → Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'location': location,
      'parent': parent,
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
      'assignedTo': assignedTo,
    };
  }
}
