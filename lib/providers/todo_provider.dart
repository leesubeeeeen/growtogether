import 'package:flutter/material.dart';

class TodoProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _todos = [];

  // ✅ 선택된 날짜 추가
  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> get todos => List.unmodifiable(_todos);

  // ✅ 선택된 날짜 getter
  DateTime get selectedDate => _selectedDate;

  // ✅ 선택된 날짜 setter
  void selectDate(DateTime date) {
    _selectedDate = date;
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
}
