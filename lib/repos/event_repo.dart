import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calendar_event.dart';

class EventRepo {
  final _db = FirebaseFirestore.instance;

  Future<List<CalendarEvent>> dayEvents(String uid, DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final qs = await _db.collection('users/$uid/events')
        .where('start', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('start', isLessThan: Timestamp.fromDate(end))
        .get();
    return qs.docs.map(CalendarEvent.fromDoc).toList();
  }
}
