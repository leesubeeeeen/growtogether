import 'package:flutter/material.dart';
import 'package:growtogether/models/calendar_event.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarProvider with ChangeNotifier {
  final List<CalendarEvent> _events = [];
  DateTime _selectedDate = DateTime.now();

  List<CalendarEvent> get events => List.unmodifiable(_events);
  DateTime get selectedDate => _selectedDate;

  void selectDate(DateTime newDate) {
    _selectedDate = DateTime(newDate.year, newDate.month, newDate.day);
    notifyListeners();
  }

  void addEvent(CalendarEvent event) {
    _events.add(event);
    _events.sort((a, b) => a.start.compareTo(b.start));
    notifyListeners();
  }

  void removeEvent(CalendarEvent event) {
    _events.remove(event);
    notifyListeners();
  }

  List<CalendarEvent> getEventsForDay(DateTime day) {
    return _events.where((e) =>
    e.start.year == day.year &&
        e.start.month == day.month &&
        e.start.day == day.day).toList();
  }

  // 🔑 Firestore에서 events 불러오기
  Future<void> loadEventsFromFirestore(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('events')
        .orderBy('start')
        .get();

    _events.clear();
    for (var doc in snapshot.docs) {
      _events.add(CalendarEvent.fromFirestore(doc));
    }
    notifyListeners();
  }
}
