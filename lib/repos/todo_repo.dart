// file: lib/repos/todo_repo.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class TodoRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> saveTodo({
    required String title,
    required DateTime start,
    required DateTime end,
    required String assignedToUid, // 이제 UID 직접 받음
    bool createEvent = false,
    String? eventContent,
    String? eventLocation,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseException(
        plugin: 'firebase_auth',
        code: 'not-authenticated',
        message: '로그인이 필요합니다.',
      );
    }

    final ownerUid = user.uid;

    if (kDebugMode) {
      debugPrint('[TodoRepo.saveTodo] owner=$ownerUid, assignedTo=$assignedToUid, '
          'title="$title", start=$start, end=$end, createEvent=$createEvent');
    }

    try {
      // 🔹 assignedToName 가져오기
      String assignedToName = '알 수 없음';
      final assignedUserDoc =
      await _db.collection('users').doc(assignedToUid).get();
      if (assignedUserDoc.exists) {
        assignedToName = assignedUserDoc.data()?['name'] ?? '알 수 없음';
      }

      final userDocRef = _db.collection('users').doc(ownerUid);

      // 1) todos 저장
      final todosRef = userDocRef.collection('todos');
      final todoDocRef = await todosRef.add({
        'title': title,
        'done': false,
        'assignedTo': assignedToUid,    // UID
        'assignedToName': assignedToName, // 🔹 이름 같이 저장
        'start': Timestamp.fromDate(start),
        'end': Timestamp.fromDate(end),
        'ownerUid': ownerUid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2) 옵션: events 저장
      if (createEvent) {
        final eventsRef = userDocRef.collection('events');
        await eventsRef.add({
          'title': title,
          'content': eventContent ?? '일정',
          'location': eventLocation ?? '',
          'parent': assignedToName, // 🔹 이름 반영
          'start': Timestamp.fromDate(start),
          'end': Timestamp.fromDate(end),
          'icon': 'event',
          'color': '#FFF1F1',
          'ownerUid': ownerUid,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return todoDocRef.id;
    } on FirebaseException {
      rethrow;
    } catch (e) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unknown',
        message: e.toString(),
      );
    }
  }
}
