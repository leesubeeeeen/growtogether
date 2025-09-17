import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------- utils ----------
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
  String _sanitizeCode(String raw) => raw.trim().toUpperCase();

  // ---------- sign up ----------
  // 성공: null, 실패: 에러 메시지
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    DateTime? dday,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      final code = _generateInviteCode();

      // users/{uid}
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        if (dday != null) 'dday': Timestamp.fromDate(dday),
        'spouseUid': null,
        'fatigue': 0,
        'inviteCode': code,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // codes/{code} -> { uid }
      await _db.collection('codes').doc(code).set({'uid': uid});

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return '이미 사용 중인 이메일입니다.';
      if (e.code == 'invalid-email') return '유효하지 않은 이메일 형식입니다.';
      if (e.code == 'weak-password') return '비밀번호가 너무 약합니다.';
      return '회원가입 실패: ${e.message}';
    } catch (e) {
      return '알 수 없는 오류가 발생했습니다: $e';
    }
  }

  // ---------- login ----------
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return '해당 이메일의 사용자가 존재하지 않습니다.';
      if (e.code == 'wrong-password') return '비밀번호가 올바르지 않습니다.';
      return '로그인 실패: ${e.message}';
    } catch (_) {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }

  // ---------- link spouse by invite code ----------
  // 성공: null, 실패: 에러 메시지
  Future<String?> linkSpouseByInviteCode(String inviteCode) async {
    try {
      final me = _auth.currentUser;
      if (me == null) return '로그인이 필요합니다.';
      final myUid = me.uid;

      final code = _sanitizeCode(inviteCode);

      // 1) codes/{code} 에서 partnerUid 조회
      final snap = await _db.collection('codes').doc(code).get();
      if (!snap.exists) return '해당 초대코드를 가진 사용자가 없습니다.';

      final partnerUid = (snap.data()!['uid'] as String);
      if (partnerUid == myUid) return '본인 초대코드는 사용할 수 없습니다.';

      final myRef = _db.collection('users').doc(myUid);
      final partnerRef = _db.collection('users').doc(partnerUid);

      // 2) 규칙 요구: partner 문서에 spouseUid 최초 설정 + inviteCodeAttempt 포함
      final batch = _db.batch();
      batch.update(partnerRef, {
        'spouseUid': myUid,
        'inviteCodeAttempt': code,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // 3) 내 문서는 내가 쓰기 가능
      batch.update(myRef, {
        'spouseUid': partnerUid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return null;
    } on FirebaseException catch (e) {
      return '연결 실패(${e.code})';
    } catch (e) {
      return '알 수 없는 오류가 발생했습니다: $e';
    }
  }

  // ---------- (옵션) 기존 유저 백필 ----------
  Future<void> backfillCodesOnce() async {
    final qs = await _db.collection('users').get();
    final batch = _db.batch();
    for (final d in qs.docs) {
      final code = (d.data()['inviteCode'] as String?)?.trim();
      if (code != null && code.isNotEmpty) {
        batch.set(_db.collection('codes').doc(code.toUpperCase()), {'uid': d.id});
      }
    }
    await batch.commit();
  }
}
