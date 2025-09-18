import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// TodoProvider
/// - 파이어스토어: users/{uid}/todos 에서 읽기
/// - 정렬: start 오름차순
/// - 날짜 필터: selectedDate 기준으로 당일만 반환
/// - API:
///   - selectDate(DateTime)
///   - loadTodosFromFirestore(String uid) / refreshForUser(String uid)
///   - addTodo({id,title,date,done,assignedToUid})
///   - getTodosForSelectedDay()
class TodoProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _todos = [];
  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> get todos => List.unmodifiable(_todos);
  DateTime get selectedDate => _selectedDate;

  /// 날짜 선택(시분초 제거)
  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  /// 로컬에 투두 추가 (정렬 유지)
  void addTodo({
    required String id,
    required String title,
    required DateTime date,
    required bool done,
    required String assignedToUid, // 🔹 UID로 저장
  }) {
    _todos.add({
      'id': id,
      'title': title,
      'date': date,       // DateTime
      'time': date,       // 호환 필드 (UI에서 사용하던 키)
      'done': done,
      'assignedTo': assignedToUid, // 🔹 UID
    });
    _todos.sort((a, b) {
      final ad = a['date'] as DateTime?;
      final bd = b['date'] as DateTime?;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });
    notifyListeners();
  }

  /// 선택된 날짜의 투두만 반환(시간 오름차순)
  List<Map<String, dynamic>> getTodosForSelectedDay() {
    final y = _selectedDate.year, m = _selectedDate.month, d = _selectedDate.day;
    final list = _todos.where((todo) {
      final dt = todo['date'] as DateTime?;
      return dt != null && dt.year == y && dt.month == m && dt.day == d;
    }).toList();

    list.sort((a, b) {
      final ad = a['date'] as DateTime?;
      final bd = b['date'] as DateTime?;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });
    return list;
  }

  /// 전체 비우기
  void clearTodos() {
    _todos.clear();
    notifyListeners();
  }

  /// Firestore → Provider 로드 (start 기준 정렬)
  Future<void> loadTodosFromFirestore(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todos')
        .orderBy('start', descending: false)
        .get();

    _todos
      ..clear()
      ..addAll(snapshot.docs.map((doc) {
        final data = doc.data();
        final Timestamp? tsStart = data['start'] as Timestamp?;
        final DateTime? start = tsStart?.toDate();

        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'done': (data['done'] ?? false) as bool,
          'assignedTo': data['assignedTo'] as String? ?? '', // 🔹 UID
          'date': start, // 주 필드
          'time': start, // 호환 필드
        };
      }));

    // 안전하게 한 번 더 정렬
    _todos.sort((a, b) {
      final ad = a['date'] as DateTime?;
      final bd = b['date'] as DateTime?;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });

    notifyListeners();
  }

  /// 새로고침(내 uid 기준 재로딩)
  Future<void> refreshForUser(String uid) async {
    await loadTodosFromFirestore(uid);
  }
}
