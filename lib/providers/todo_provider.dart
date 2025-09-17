import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _todos = [];
  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> get todos => List.unmodifiable(_todos);
  DateTime get selectedDate => _selectedDate;

  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  void addTodo(Map<String, dynamic> todo) {
    _todos.add(todo);
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

  void clearTodos() {
    _todos.clear();
    notifyListeners();
  }

  /// ✅ Firestore → Provider
  Future<void> loadTodosFromFirestore(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todos')
        .get();

    _todos.clear();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      _todos.add({
        'title': data['title'] ?? '',
        'done': data['done'] ?? false,
        'time': data['start'] != null
            ? (data['start'] as Timestamp).toDate()
            : null,
        'date': data['start'] != null
            ? (data['start'] as Timestamp).toDate()
            : null,
      });
    }
    notifyListeners();
  }
}
