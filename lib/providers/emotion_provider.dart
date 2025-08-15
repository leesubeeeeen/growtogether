// emotion_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EmotionProvider with ChangeNotifier {
  String? _feeling;

  String? get feeling => _feeling;

  void setFeeling(String emoji) {
    _feeling = emoji;
    notifyListeners();
  }

  double _fatigue = 0.0; // 0~100 범위
  double get fatigue => _fatigue;

  void setFatigue(double value) {
    _fatigue = value; // 그대로 저장
    notifyListeners();
  }


  Future<void> saveTodayEmotion() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("로그인 필요");

    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('emotions')
        .doc(todayKey)
        .set({
      'feeling': _feeling ?? '😐',
      'fatigue': _fatigue,                  // ✅ 0~100 정수로 저장
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
