import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import 'connect_partner_screen.dart';
import 'start_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? inviteCode;
  String? spouseName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          inviteCode = data['inviteCode'];
        });

        // spouseUid 가 있으면 배우자 이름 불러오기
        if (data['spouseUid'] != null) {
          final spouseDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(data['spouseUid'])
              .get();

          if (spouseDoc.exists) {
            setState(() {
              spouseName = spouseDoc.data()?['name'] ?? '이름 없음';
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        elevation: 0,
        title: const Text(
          '설정',
          style: TextStyle(
            fontFamily: AppFonts.pretendard,
            fontWeight: FontWeight.bold,
            color: Palette.mainRed,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Palette.mainRed),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 정보
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('이름: ${user?.displayName ?? '이름 없음'}',
                      style: const TextStyle(fontFamily: AppFonts.pretendard)),
                  const SizedBox(height: 8),
                  Text('이메일: ${user?.email ?? ''}',
                      style: const TextStyle(fontFamily: AppFonts.pretendard)),
                  const SizedBox(height: 8),

                  // 배우자 이름 or 초대코드
                  if (spouseName != null)
                    Text('배우자: $spouseName',
                        style: const TextStyle(fontFamily: AppFonts.pretendard))
                  else if (inviteCode != null)
                    Row(
                      children: [
                        Text('초대코드: $inviteCode',
                            style: const TextStyle(fontFamily: AppFonts.pretendard)),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: inviteCode!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('초대코드가 복사되었습니다.')),
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 배우자 연결 버튼
            if (spouseName == null)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.mainRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConnectPartnerScreen(),
                      ),
                    ).then((_) => _loadUserData()); // 연결 후 새로고침
                  },
                  child: const Text(
                    '배우자 연결하기',
                    style: TextStyle(
                      color: Palette.background,
                      fontFamily: AppFonts.pretendard,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // 로그아웃 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const StartScreen()),
                        (route) => false,
                  );
                },
                child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    color: Palette.greyText,
                    fontFamily: AppFonts.pretendard,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
