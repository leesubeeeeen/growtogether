import 'package:flutter/material.dart';
import '../models/emotion_model.dart';

class EmotionProvider with ChangeNotifier {
  String? _feeling;
  double _fatigue = 0.0;

  String? get feeling => _feeling;
  double get fatigue => _fatigue;

  void setFeeling(String emoji) {
    _feeling = emoji;
    notifyListeners();
  }

  void setFatigue(double value) {
    _fatigue = value;
    notifyListeners();
  }

  void saveTodayEmotion() {
    final newEmotion = EmotionModel(
      feeling: _feeling ?? '😐',
      fatigue: _fatigue,
      timestamp: DateTime.now(),
    );
    _emotions.add(newEmotion);
    notifyListeners();
  }

  final List<EmotionModel> _emotions = [];
  List<EmotionModel> get emotions => _emotions;
}

