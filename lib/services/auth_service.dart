import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> signUp(
      String name,
      String email,
      String password, {
        DateTime? dday,
      }) async {
    try {
      // 1) Auth 계정 생성
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = cred.user;

      // 🔹 인증 토큰 갱신 (중요!)
      await user?.reload();
      user = _auth.currentUser;

      // 2) displayName 업데이트
      await user?.updateDisplayName(name);

      // 3) Firestore에 유저 문서 생성
      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'email': email,
        'spouseUid': null,
        'inviteCode': _generateInviteCode(),
        'dday': dday != null ? Timestamp.fromDate(dday) : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }


// ====== 유니크 코드 생성기 ======
  Future<String> _generateUniqueInviteCode() async {
    while (true) {
      final code = _generateInviteCode();
      final snap = await _firestore
          .collection('users')
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return code; // 충돌 없음 → 사용
      // 충돌 시 while문으로 재시도
    }
  }


  Future<String?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _ensureInviteCode(cred.user!.uid); // ✅ 보정
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? '로그인 실패';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> _ensureInviteCode(String uid) async {
    final ref = _firestore.collection('users').doc(uid);
    final doc = await ref.get();
    if (!doc.exists) return;
    final data = doc.data()!;
    if (data['inviteCode'] == null || (data['inviteCode'] as String).isEmpty) {
      final unique = await _generateUniqueInviteCode();
      await ref.update({
        'inviteCode': unique,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }


  Future<String?> linkSpouseByInviteCode(String code) async {
    try {
      final me = _auth.currentUser!;
      final meRef = _firestore.collection('users').doc(me.uid);

      // 1. 상대방 찾기
      final partnerQuery = await _firestore
          .collection('users')
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();

      if (partnerQuery.docs.isEmpty) {
        return '해당 초대코드의 사용자를 찾을 수 없습니다.';
      }

      final partnerRef = partnerQuery.docs.first.reference;

      if (partnerRef.id == me.uid) {
        return '본인 초대코드로는 연결할 수 없습니다.';
      }

      // 2. 내 문서 수정
      await meRef.update({
        'spouseUid': partnerRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
        'emotion': null,
        'fatigue': 0,
        'dday': null,
      });

      // 3. 상대방 문서 수정
      await partnerRef.update({
        'spouseUid': me.uid,
        'updatedAt': FieldValue.serverTimestamp(),
        'emotion': null,
        'fatigue': 0,
        'dday': null,
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }


  Future<void> updateEmotion(String emotion) async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).update({
      'emotion': emotion,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateFatigue(int fatigue) async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).update({
      'fatigue': fatigue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDday(DateTime dday) async {
    final uid = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).update({
      'dday': dday != null ? Timestamp.fromDate(dday) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }



  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();


  // 초대코드 생성
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }
}

