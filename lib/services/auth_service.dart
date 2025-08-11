import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> signUp(String name, String email, String password) async {
    try {
      // 1) Auth 계정 생성
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = cred.user;

      // 2) Auth displayName 업데이트
      await user?.updateDisplayName(name);

      // 3) Firestore에 저장
      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'email': email,
        'partnerId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // 성공
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
