import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _todos = [];
  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> get todos => List.unmodifiable(_todos);
  DateTime get selectedDate => _selectedDate;

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void addTodo(Map<String, dynamic> todo) {
    _todos.add(todo);
    notifyListeners();
  }

  void clearTodos() {
    _todos.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> getTodosForSelectedDay() {
    return _todos.where((todo) {
      final todoDate = todo['date'] as DateTime?;
      return todoDate != null &&
          todoDate.year == _selectedDate.year &&
          todoDate.month == _selectedDate.month &&
          todoDate.day == _selectedDate.day;
    }).toList();
  }

  // 🔑 Firestore에서 todos 불러오기
  Future<void> loadTodosFromFirestore(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todos')
        .orderBy('start')
        .get();

    _todos.clear();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      _todos.add({
        'title': data['title'] ?? '',
        'time': (data['start'] as Timestamp).toDate(),
        'done': data['done'] ?? false,
        'date': (data['start'] as Timestamp).toDate(),
      });
    }
    notifyListeners();
  }
}
