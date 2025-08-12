import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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

  Future<void> saveTodayEmotion() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("로그인 상태가 아닙니다");

    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('emotions')
        .doc(todayKey)
        .set({
      'feeling': _feeling ?? '😐',
      'fatigue': (_fatigue * 100).round(),
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    notifyListeners();
  }

}
