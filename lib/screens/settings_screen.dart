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
  String? myName; // ✅ Firestore에서 가져온 내 이름
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _loading = true);
    try {
      // 내 문서 읽기 (허용됨)
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용자 정보를 찾을 수 없습니다.')),
        );
        return;
      }

      final String? code = (data['inviteCode'] as String?);
      final String? partnerUidRaw = (data['spouseUid'] as String?);
      if (!mounted) return;
      setState(() {
        inviteCode = code;
        myName = (data['name'] as String?) ?? FirebaseAuth.instance.currentUser?.displayName;
        spouseName = null; // 아래에서 시도해서 채움
      });

      // 배우자 이름 읽기 (상대 문서가 "상호 연결"되어 있어야 규칙상 허용)
      final partnerUid = (partnerUidRaw != null && partnerUidRaw.isNotEmpty) ? partnerUidRaw : null;
      if (partnerUid != null) {
        try {
          final spouseDoc = await FirebaseFirestore.instance.collection('users').doc(partnerUid).get();
          final sdata = spouseDoc.data();
          if (!mounted) return;
          setState(() {
            spouseName = sdata?['name'] as String? ?? '이름 없음';
          });
        } on FirebaseException catch (e) {
          // 읽기 거절은 "상대 문서에서 아직 spouseUid가 나(현재 사용자)로 안 박힘" 상황일 수 있음
          if (e.code == 'permission-denied') {
            // 조용히 무시하고 초대코드만 보여주도록 둠
            debugPrint('spouse read denied: 상대와 상호 연결 미완료 또는 규칙 조건 미충족');
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('배우자 정보 불러오기 실패: ${e.code}')),
            );
          }
        }
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('설정 불러오기 실패: ${e.code}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정 불러오기 중 알 수 없는 오류가 발생했습니다.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 정보 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이름: ${myName ?? '이름 없음'}',
                    style: const TextStyle(fontFamily: AppFonts.pretendard),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '이메일: ${user?.email ?? ''}',
                    style: const TextStyle(fontFamily: AppFonts.pretendard),
                  ),
                  const SizedBox(height: 8),
                  if (spouseName != null)
                    Text(
                      '배우자: $spouseName',
                      style: const TextStyle(fontFamily: AppFonts.pretendard),
                    )
                  else if (inviteCode != null && inviteCode!.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          '초대코드: $inviteCode',
                          style: const TextStyle(fontFamily: AppFonts.pretendard),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: inviteCode!));
                            if (!mounted) return;
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

            // 배우자 연결 버튼 (아직 표시 이름이 없을 때만)
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
                      MaterialPageRoute(builder: (_) => const ConnectPartnerScreen()),
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
                  if (!mounted) return;
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
