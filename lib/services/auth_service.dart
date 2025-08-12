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
      // 1) 계정 생성
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = cred.user;

      // 2) displayName 업데이트
      await user?.updateDisplayName(name);

      // 3) Firestore 문서 생성
      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'email': email,
        'spouseUid': null,
        'inviteCode': _generateInviteCode(),
        'dday': dday != null ? Timestamp.fromDate(dday) : null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 4) 회원가입 직후 자동 로그인을 해제 → 로그인 화면으로 돌아가게 함
      await _auth.signOut();

      return null; // 성공
    } catch (e) {
      return e.toString();
    }
  }


  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // 성공
    } on FirebaseAuthException catch (e) {
      return e.message ?? '로그인 실패';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> linkSpouseByInviteCode(String code) async {
    try {
      final me = _auth.currentUser!;
      final meRef = _firestore.collection('users').doc(me.uid);

      await _firestore.runTransaction((tx) async {
        // ✅ QuerySnapshot으로 받아야 .docs 사용 가능
        final partnerQuery = await _firestore
            .collection('users')
            .where('inviteCode', isEqualTo: code)
            .limit(1)
            .get();

        if (partnerQuery.docs.isEmpty) {
          throw Exception('해당 초대코드의 사용자를 찾을 수 없습니다.');
        }

        final partnerRef = partnerQuery.docs.first.reference;

        if (partnerRef.id == me.uid) {
          throw Exception('본인 초대코드로는 연결할 수 없습니다.');
        }

        // ✅ 양쪽 spouseUid 세팅
        tx.update(meRef, {
          'spouseUid': partnerRef.id,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        tx.update(partnerRef, {
          'spouseUid': me.uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // ✅ 감정 & 피로도 공유 필드 초기화
        tx.update(meRef, {
          'emotion': null, // 예: "happy", "sad"
          'fatigue': 0,    // 숫자 (0~100)
        });
        tx.update(partnerRef, {
          'emotion': null,
          'fatigue': 0,
        });

        // ✅ 디데이 필드 초기화 (추후 UI에서 설정 가능)
        tx.update(meRef, {'dday': null});
        tx.update(partnerRef, {'dday': null});
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

