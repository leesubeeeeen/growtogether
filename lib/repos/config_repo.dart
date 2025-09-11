import 'package:cloud_firestore/cloud_firestore.dart';

class ConfigRepo {
  final _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> loadMessagesKo() async {
    final doc = await _db.collection('configs').doc('messages').get();
    return (doc.data()?['ko_KR'] as Map<String, dynamic>? ?? {});
  }

  Future<Map<String, dynamic>> loadDefaultSlots() async {
    final doc = await _db.collection('configs').doc('slots').get();
    return (doc.data()?['default'] as Map<String, dynamic>? ?? {});
  }
}
