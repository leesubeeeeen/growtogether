import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService(); // ✅ 인스턴스 생성
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  Future<void> _login() async {
    if (_loading) return;
    setState(() => _loading = true);

    final email = emailController.text.trim();
    final password = passwordController.text; // ← 비밀번호는 trim() 제거

    String? error;
    try {
      // AuthService.login이 성공 시 null, 실패 시 에러 메시지(String) 반환한다고 가정
      error = await _authService.login(email, password);
    } catch (e) {
      error = '알 수 없는 오류가 발생했습니다.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $error')),
      );
      return; // ← 실패 시 여기서 종료! 네비게이션 금지
    }

    // 성공 시에만 이동
    Navigator.pushReplacementNamed(context, '/home');
  }


  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Palette.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: w * 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: h * 0.05),
                Text(
                  '접속 완료!\n같이 키우기 시작!',
                  style: TextStyle(
                    fontSize: w * 0.065,
                    fontWeight: FontWeight.bold,
                    color: Palette.mainRed,
                    fontFamily: AppFonts.pretendard,
                  ),
                ),
                SizedBox(height: h * 0.07),
                _buildInputField(
                  controller: emailController,
                  icon: Icons.email_outlined,
                  hint: '이메일을 입력해주세요',
                ),
                SizedBox(height: h * 0.025),
                _buildInputField(
                  controller: passwordController,
                  icon: Icons.lock_outline,
                  hint: '비밀번호를 입력해주세요',
                  isPassword: true,
                ),
                SizedBox(height: h * 0.07),
                SizedBox(
                  width: double.infinity,
                  height: h * 0.065,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.mainRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Palette.background,
                        fontFamily: AppFonts.pretendard,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        decoration: InputDecoration(
          icon: Icon(icon, color: Palette.black),
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: AppFonts.pretendard),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Palette.greyText,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          )
              : null,
        ),
        style: const TextStyle(fontFamily: AppFonts.pretendard),
      ),
    );
  }
}
