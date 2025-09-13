import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepo {
  final _db = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> userDoc(String uid) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
  }


  Future<Map<String, dynamic>> todayEmotion(String uid, DateTime day) async {
    final key = "${day.year.toString().padLeft(4, '0')}-"
        "${day.month.toString().padLeft(2, '0')}-"
        "${day.day.toString().padLeft(2, '0')}";
    final d = await _db.collection('users/$uid/emotions').doc(key).get();
    return d.data() ?? {}; // {fatigue: num, feeling: "🙂"} 없으면 빈 맵
  }
}
