// file: lib/repos/todo_repo.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class TodoBatchEntry {
  final DateTime start;
  final DateTime end;
  final String assignedToUid;

  TodoBatchEntry({required this.start, required this.end, required this.assignedToUid});
}

class TodoRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> saveTodo({
    required String title,
    required DateTime start,
    required DateTime end,
    required String assignedToUid,
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
      String assignedToName = '알 수 없음';
      final assignedUserDoc = await _db.collection('users').doc(assignedToUid).get();
      if (assignedUserDoc.exists) {
        assignedToName = assignedUserDoc.data()?['name'] ?? '알 수 없음';
      }

      final userDocRef = _db.collection('users').doc(ownerUid);

      final todoDocRef = await userDocRef.collection('todos').add({
        'title': title,
        'done': false,
        'assignedTo': assignedToUid,
        'assignedToName': assignedToName,
        'start': Timestamp.fromDate(start),
        'end': Timestamp.fromDate(end),
        'ownerUid': ownerUid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (createEvent) {
        await userDocRef.collection('events').add({
          'title': title,
          'content': eventContent ?? '일정',
          'location': eventLocation ?? '',
          'parent': assignedToName,
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
      throw FirebaseException(plugin: 'cloud_firestore', code: 'unknown', message: e.toString());
    }
  }

  /// ✅ 반복 인스턴스 여러 개를 한 번에 저장
  Future<List<String>> saveTodosBatch({
    required String title,
    required List<TodoBatchEntry> entries,
    bool createEvents = false,
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

    try {
      final userDocRef = _db.collection('users').doc(ownerUid);
      final todosRef = userDocRef.collection('todos');
      final eventsRef = userDocRef.collection('events');

      // 미리 UID→이름 맵 생성
      final uidSet = entries.map((e) => e.assignedToUid).toSet();
      final nameMap = <String, String>{};
      for (final uid in uidSet) {
        String name = '알 수 없음';
        final u = await _db.collection('users').doc(uid).get();
        if (u.exists) name = u.data()?['name'] ?? '알 수 없음';
        nameMap[uid] = name;
      }

      final batch = _db.batch();
      final ids = <String>[];

      for (final e in entries) {
        final docRef = todosRef.doc();
        ids.add(docRef.id);
        batch.set(docRef, {
          'title': title,
          'done': false,
          'assignedTo': e.assignedToUid,
          'assignedToName': nameMap[e.assignedToUid] ?? '알 수 없음',
          'start': Timestamp.fromDate(e.start),
          'end': Timestamp.fromDate(e.end),
          'ownerUid': ownerUid,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (createEvents) {
          final evRef = eventsRef.doc();
          batch.set(evRef, {
            'title': title,
            'content': '일정',
            'location': '',
            'parent': nameMap[e.assignedToUid] ?? '알 수 없음',
            'start': Timestamp.fromDate(e.start),
            'end': Timestamp.fromDate(e.end),
            'icon': 'event',
            'color': '#FFF1F1',
            'ownerUid': ownerUid,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
      return ids;
    } on FirebaseException {
      rethrow;
    } catch (e) {
      throw FirebaseException(plugin: 'cloud_firestore', code: 'unknown', message: e.toString());
    }
  }
}
