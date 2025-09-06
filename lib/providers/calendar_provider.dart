import 'package:flutter/material.dart';
import 'package:growtogether/models/calendar_event.dart';

class CalendarProvider with ChangeNotifier {
  final List<CalendarEvent> _events = [];

  // ✅ 선택된 날짜 추가
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  void selectDate(DateTime newDate) {
    _selectedDate = DateTime(newDate.year, newDate.month, newDate.day); // 시간 제거
    notifyListeners();
  }

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
