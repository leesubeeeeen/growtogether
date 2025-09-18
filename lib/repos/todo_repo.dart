// file: lib/repos/todo_repo.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class TodoRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 선택한 대상(나/배우자)에 저장.
  /// - 기본은 투두만 저장 (중복 표시 방지). createEvent=true일 때만 events도 생성.
  /// - spouseUid가 null인데 assignedTo='partner'면, 안전하게 내 문서에 저장.
  ///
  /// return: 생성된 todo 문서 id
  Future<String> saveTodo({
    required String title,
    required DateTime start,
    required DateTime end,
    required String assignedTo, // 'me' | 'partner'
    String? spouseUid,
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
    final targetUid =
    (assignedTo == 'partner' && spouseUid != null && spouseUid.isNotEmpty)
        ? spouseUid
        : ownerUid;

    if (kDebugMode) {
      debugPrint('[TodoRepo.saveTodo] owner=$ownerUid, target=$targetUid, '
          'assignedTo=$assignedTo, title="$title", start=$start, end=$end, '
          'createEvent=$createEvent');
    }

    try {
      final userDocRef = _db.collection('users').doc(targetUid);

      // 1) todos 저장
      final todosRef = userDocRef.collection('todos');
      final todoDocRef = await todosRef.add({
        'title': title,
        'done': false,
        'assignedTo': assignedTo, // 표시용
        'start': Timestamp.fromDate(start),
        'end': Timestamp.fromDate(end),
        'ownerUid': ownerUid, // 누가 생성했는지 추적
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2) 옵션: events 저장 (캘린더 화면에서 쓰고 싶을 때만)
      if (createEvent) {
        final eventsRef = userDocRef.collection('events');
        await eventsRef.add({
          'title': title,
          'content': eventContent ?? ((assignedTo == 'me') ? '내 일정' : '배우자 일정'),
          'location': eventLocation ?? '',
          'parent': (assignedTo == 'me') ? '나' : '배우자',
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
