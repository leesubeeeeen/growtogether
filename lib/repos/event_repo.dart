import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calendar_event.dart';

class EventRepo {
  final _db = FirebaseFirestore.instance;

  // ✅ 이벤트 저장
  Future<void> saveEvent({
    required String uid,
    required String title,
    required DateTime start,
    required DateTime end,
    required String assignedTo,
  }) async {
    final eventRef = _db.collection('users').doc(uid).collection('events').doc();
    await eventRef.set({
      'title': title,
      'start': start,
      'end': end,
      'assignedTo': assignedTo,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ 하루 이벤트 불러오기
  Future<List<CalendarEvent>> dayEvents(String uid, DateTime day) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('events')
        .where('start',
        isGreaterThanOrEqualTo: DateTime(day.year, day.month, day.day),
        isLessThan: DateTime(day.year, day.month, day.day + 1))
        .get();

    return snapshot.docs
        .map((doc) => CalendarEvent.fromFirestore(doc))
        .toList();
  }
}
