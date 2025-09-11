import 'package:cloud_firestore/cloud_firestore.dart';

class TodoRepo {
  final _db = FirebaseFirestore.instance;

  Future<void> saveTodoAndEvent({
    required String targetUid,   // 배정된 사용자 uid
    required String title,
    required DateTime start,
    required DateTime end,
    required String assignedTo,  // "me" | "partner"
  }) async {
    final batch = _db.batch();

    // todos
    final todoRef = _db.collection('users/$targetUid/todos').doc();
    batch.set(todoRef, {
      'title': title,
      'dueDate': Timestamp.fromDate(start),
      'assignedTo': assignedTo,
      'done': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // events
    final eventRef = _db.collection('users/$targetUid/events').doc();
    batch.set(eventRef, {
      'title': title,
      'start': Timestamp.fromDate(start),
      'end': Timestamp.fromDate(end),
      'assignedTo': assignedTo,
    });

    await batch.commit();
  }
}
