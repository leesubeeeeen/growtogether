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
    final userRef = _db.collection('users').doc(targetUid);

    // ✅ todos 저장
    final todoRef = userRef.collection('todos').doc(); // 자동 ID
    await todoRef.set({
      'title': title,
      'done': false,
      'start': start,
      'end': end,
      'assignedTo': assignedTo,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // ✅ events 저장
    final eventRef = userRef.collection('events').doc(); // 자동 ID
    await eventRef.set({
      'title': title,
      'start': start,
      'end': end,
      'assignedTo': assignedTo,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
