import 'package:flutter/material.dart';

class CalendarEvent {
  final String title;
  final DateTime date;

  CalendarEvent({required this.title, required this.date});
}

class CalendarProvider with ChangeNotifier {
  final List<CalendarEvent> _events = [];

  List<CalendarEvent> get events => List.unmodifiable(_events);

  void addEvent(CalendarEvent event) {
    _events.add(event);
    notifyListeners();
  }

  void removeEvent(CalendarEvent event) {
    _events.remove(event);
    notifyListeners();
  }

  List<CalendarEvent> getEventsForDay(DateTime day) {
    return _events.where((e) =>
    e.date.year == day.year &&
        e.date.month == day.month &&
        e.date.day == day.day
    ).toList();
  }
}
