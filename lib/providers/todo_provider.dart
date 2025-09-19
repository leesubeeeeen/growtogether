import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// TodoProvider
/// - 파이어스토어: users/{uid}/todos 에서 읽기
/// - assignedTo는 uid로 저장됨 → 여기서 name으로 resolve
/// - 정렬: start 오름차순
/// - 날짜 필터: selectedDate 기준으로 당일만 반환
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

  /// uid → name 변환
  Future<String> _resolveUserName(String uid) async {
    try {
      final doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!doc.exists) return '알 수 없음';
      final data = doc.data();
      return (data?['name'] ?? '알 수 없음') as String;
    } catch (_) {
      return '알 수 없음';
    }
  }

  /// 로컬에 투두 추가 (정렬 유지)
  void addTodo({
    required String id,
    required String title,
    required DateTime date,
    required bool done,
    required String assignedToUid,
    String? assignedToName,
  }) {
    _todos.add({
      'id': id,
      'title': title,
      'date': date,
      'time': date,
      'done': done,
      'assignedToUid': assignedToUid,
      'assignedToName': assignedToName ?? '알 수 없음',
    });
    _todos.sort(_compareByDate);
    notifyListeners();
  }

  /// 선택된 날짜의 투두만 반환
  List<Map<String, dynamic>> getTodosForSelectedDay() {
    final y = _selectedDate.year, m = _selectedDate.month, d = _selectedDate.day;
    final list = _todos.where((todo) {
      final dt = todo['date'] as DateTime?;
      return dt != null && dt.year == y && dt.month == m && dt.day == d;
    }).toList();

    list.sort(_compareByDate);
    return list;
  }

  /// Firestore → Provider 로드
  Future<void> loadTodosFromFirestore(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todos')
        .orderBy('start', descending: false)
        .get();

    final List<Map<String, dynamic>> loaded = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final Timestamp? tsStart = data['start'] as Timestamp?;
      final DateTime? start = tsStart?.toDate();

      final assignedToUid = data['assignedTo'] as String? ?? '';
      final assignedToName =
      assignedToUid.isNotEmpty ? await _resolveUserName(assignedToUid) : '알 수 없음';

      loaded.add({
        'id': doc.id,
        'title': data['title'] ?? '',
        'done': (data['done'] ?? false) as bool,
        'assignedToUid': assignedToUid,
        'assignedToName': assignedToName,
        'date': start,
        'time': start,
      });
    }

    _todos
      ..clear()
      ..addAll(loaded);

    _todos.sort(_compareByDate);
    notifyListeners();
  }

  /// 새로고침(내 uid 기준 재로딩)
  Future<void> refreshForUser(String uid) async {
    await loadTodosFromFirestore(uid);
  }

  /// 전체 비우기
  void clearTodos() {
    _todos.clear();
    notifyListeners();
  }

  int _compareByDate(Map<String, dynamic> a, Map<String, dynamic> b) {
    final ad = a['date'] as DateTime?;
    final bd = b['date'] as DateTime?;
    if (ad == null && bd == null) return 0;
    if (ad == null) return 1;
    if (bd == null) return -1;
    return ad.compareTo(bd);
  }
}
