import 'package:cloud_firestore/cloud_firestore.dart';

class TodoRepo {
  final _db = FirebaseFirestore.instance;

  Future<void> saveTodoAndEvent({
    required String targetUid,
    required String title,
    required DateTime start,
    required DateTime end,
    required String assignedTo,
  }) async {
    // ✅ todos 자동 생성
    final todoRef = _db
        .collection('users')
        .doc(targetUid)
        .collection('todos')
        .doc(); // autoId

    await todoRef.set({
      'title': title,
      'assignedTo': assignedTo,
      'start': start,
      'end': end,
      'done': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // ✅ events 자동 생성
    final eventRef = _db
        .collection('users')
        .doc(targetUid)
        .collection('events')
        .doc();

    await eventRef.set({
      'title': title,
      'assignedTo': assignedTo,
      'start': start,
      'end': end,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
