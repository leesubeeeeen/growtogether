import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import '../services/auth_service.dart';
import 'connect_complete_screen.dart';

class ConnectPartnerScreen extends StatefulWidget {
  const ConnectPartnerScreen({super.key});

  @override
  State<ConnectPartnerScreen> createState() => _ConnectPartnerScreenState();
}

class _ConnectPartnerScreenState extends State<ConnectPartnerScreen> {
  final TextEditingController _partnerIdController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _loading = false;

  Future<void> _connectPartner() async {
    FocusScope.of(context).unfocus(); // 키보드 닫기
    setState(() => _loading = true);

    final code = _partnerIdController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showSnackBar('초대코드를 입력해주세요.', isError: true);
      setState(() => _loading = false);
      return;
    }

    final error = await _authService.linkSpouseByInviteCode(code);
    setState(() => _loading = false);

    if (error == null) {
      _showSnackBar('배우자와 성공적으로 연결되었습니다!', isError: false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ConnectCompleteScreen()),
      );
    } else {
      _showSnackBar('연결 실패: $error', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: AppFonts.pretendard)),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Palette.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: h * 0.05),
                Text(
                  '상대 배우자의\n초대코드를 입력하세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: w * 0.06,
                    color: Palette.mainRed,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppFonts.pretendard,
                  ),
                ),
                SizedBox(height: h * 0.05),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                  decoration: BoxDecoration(
                    color: Palette.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Palette.greyText),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, color: Palette.greyText),
                      SizedBox(width: w * 0.025),
                      Expanded(
                        child: TextField(
                          controller: _partnerIdController,
                          textCapitalization: TextCapitalization.characters, // ✅ 자동 대문자
                          style: const TextStyle(fontFamily: AppFonts.pretendard),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '초대코드 입력',
                            hintStyle: TextStyle(
                              color: Palette.greyText,
                              fontFamily: AppFonts.pretendard,
                            ),
                          ),
                          onSubmitted: (_) => _connectPartner(), // ✅ 엔터로 실행
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: h * 0.05),
                SizedBox(
                  width: double.infinity,
                  height: h * 0.065,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.mainRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _loading ? null : _connectPartner,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      '확인하기',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.pretendard,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: h * 0.015),
                SizedBox(
                  width: double.infinity,
                  height: h * 0.065,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '뒤로가기',
                      style: TextStyle(
                        color: Palette.greyText,
                        fontFamily: AppFonts.pretendard,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: h * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

