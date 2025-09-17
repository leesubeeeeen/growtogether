import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calendar_event.dart';

class CalendarProvider with ChangeNotifier {
  final List<CalendarEvent> _events = [];
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;
  List<CalendarEvent> get events => List.unmodifiable(_events);

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

  /// ✅ Firestore → Provider
  Future<void> loadEventsFromFirestore(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('events')
        .get();

    _events.clear();
    for (var doc in snapshot.docs) {
      _events.add(CalendarEvent.fromFirestore(doc));
    }
    notifyListeners();
  }
}
