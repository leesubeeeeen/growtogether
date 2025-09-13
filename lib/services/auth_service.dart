import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔑 회원가입
  /// 성공 시 null, 실패 시 에러 메시지(String) 반환
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    DateTime? dday,
  }) async {
    try {
      // Firebase Auth 계정 생성
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      // Firestore users/{uid} 문서 생성
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'dday': dday != null ? Timestamp.fromDate(dday) : null,  // ✅ 이렇게 저장
        'spouseUid': null,
        'fatigue': 0,
        'inviteCode': _generateInviteCode(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return null; // 성공 시 null 반환
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return '이미 사용 중인 이메일입니다.';
      } else if (e.code == 'invalid-email') {
        return '유효하지 않은 이메일 형식입니다.';
      } else if (e.code == 'weak-password') {
        return '비밀번호가 너무 약합니다.';
      } else {
        return '회원가입 실패: ${e.message}';
      }
    } catch (e) {
      return '알 수 없는 오류가 발생했습니다: $e';
    }
  }



  /// 🔑 로그인
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return '해당 이메일의 사용자가 존재하지 않습니다.';
      } else if (e.code == 'wrong-password') {
        return '비밀번호가 올바르지 않습니다.';
      } else {
        return '로그인 실패: ${e.message}';
      }
    } catch (e) {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

  /// 🔗 초대코드로 배우자 연결
  Future<String?> linkSpouseByInviteCode(String inviteCode) async {
    try {
      final currentUid = _auth.currentUser?.uid;
      if (currentUid == null) return "로그인이 필요합니다.";

      final query = await _db
          .collection('users')
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return "해당 초대코드를 가진 사용자가 없습니다.";
      }

      final partnerDoc = query.docs.first;
      final partnerUid = partnerDoc.id;

      if (partnerUid == currentUid) {
        return "본인 초대코드는 사용할 수 없습니다.";
      }

      final batch = _db.batch();
      final myRef = _db.collection('users').doc(currentUid);
      final partnerRef = _db.collection('users').doc(partnerUid);

      batch.update(myRef, {'spouseUid': partnerUid});
      batch.update(partnerRef, {'spouseUid': currentUid});

      await batch.commit();
      return null;
    } catch (e) {
      print("❌ 배우자 연결 에러: $e");
      return "알 수 없는 오류가 발생했습니다.";
    }
  }

  /// 랜덤 초대코드 생성
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
  }
}
