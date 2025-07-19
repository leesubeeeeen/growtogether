import 'package:flutter/material.dart';

class TodoProvider with ChangeNotifier {
  final List<String> _todos = [];

  List<String> get todos => List.unmodifiable(_todos);

  void addTodo(String todo) {
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
