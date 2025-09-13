import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calendar_event.dart';

class EventRepo {
  final _db = FirebaseFirestore.instance;

  Future<List<CalendarEvent>> dayEvents(String uid, DateTime day) async {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('events')
        .where('start', isGreaterThanOrEqualTo: startOfDay)
        .where('start', isLessThan: endOfDay)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return CalendarEvent(
        id: doc.id,
        title: data['title'] ?? '',
        start: (data['start'] as Timestamp).toDate(),
        end: (data['end'] as Timestamp).toDate(),
        assignedTo: data['assignedTo'] ?? 'me',
      );
    }).toList();
  }
}
