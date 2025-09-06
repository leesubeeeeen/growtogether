import 'package:flutter/material.dart';
import 'package:growtogether/models/calendar_event.dart';

class CalendarProvider with ChangeNotifier {
  final List<CalendarEvent> _events = [];

  List<CalendarEvent> get events => List.unmodifiable(_events);

  void addEvent(CalendarEvent event) {
    _events.add(event);
    _events.sort((a, b) => a.start.compareTo(b.start)); // 시간순 정렬
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
        e.start.day == day.day
    ).toList();
  }
}
