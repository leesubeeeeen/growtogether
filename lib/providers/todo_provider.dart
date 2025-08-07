import 'package:flutter/material.dart';

class TodoProvider with ChangeNotifier {
  // ✅ title, time을 포함한 Map 리스트로 변경
  final List<Map<String, String>> _todos = [];

  List<Map<String, String>> get todos => List.unmodifiable(_todos);

  // ✅ Map 구조로 todo 추가
  void addTodo(Map<String, String> todo) {
    _todos.add(todo);
    notifyListeners();
  }

  void removeTodo(int index) {
    if (index >= 0 && index < _todos.length) {
      _todos.removeAt(index);
      notifyListeners();
    }
  }

  void clearTodos() {
    _todos.clear();
    notifyListeners();
  }
}
