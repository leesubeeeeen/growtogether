  import 'package:flutter/material.dart';
  import '../theme/palette.dart';
  import '../theme/fonts.dart';
  import '../services/auth_service.dart';

  class SignUpScreen extends StatefulWidget {
    const SignUpScreen({super.key});

    @override
    State<SignUpScreen> createState() => _SignUpScreenState();
  }

  class _SignUpScreenState extends State<SignUpScreen> {
    final AuthService _authService = AuthService();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    bool _loading = false;
    DateTime? _selectedDday; // ✅ 디데이 저장

    void _signUp() async {
      setState(() => _loading = true);
      String? error = await _authService.signUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        dday: _selectedDday, // DateTime? 가능
      );

      setState(() => _loading = false);

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 실패: $error')),
        );
      }
      // ✅ 성공 시 화면 이동 안 함 → AuthGate가 자동으로 HomePage로
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
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
                    '회원가입',
                    style: TextStyle(
                      fontSize: w * 0.065,
                      fontWeight: FontWeight.bold,
                      color: Palette.mainRed,
                      fontFamily: AppFonts.pretendard,
                    ),
                  ),
                  SizedBox(height: h * 0.07),

                  _buildTextField(nameController, '이름', Icons.person_outline),
                  SizedBox(height: h * 0.025),
                  _buildTextField(emailController, '이메일', Icons.email_outlined),
                  SizedBox(height: h * 0.025),
                  _buildTextField(passwordController, '비밀번호', Icons.lock_outline, obscure: true),
                  SizedBox(height: h * 0.025),

                  // ✅ D-day 선택 버튼
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _selectedDday = picked);
                      }
                    },
                    child: Text(
                      _selectedDday == null
                          ? 'D-day 선택'
                          : '선택된 D-day: ${_selectedDday!.year}-${_selectedDday!.month}-${_selectedDday!.day}',
                    ),
                  ),
                  SizedBox(height: h * 0.07),

                  SizedBox(
                    width: double.infinity,
                    height: h * 0.065,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Palette.mainRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        '가입하기',
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

    Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool obscure = false}) {
      final w = MediaQuery.of(context).size.width;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(horizontal: w * 0.04),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontFamily: AppFonts.pretendard),
          decoration: InputDecoration(
            icon: Icon(icon, color: Palette.black),
            hintText: hint,
            hintStyle: const TextStyle(fontFamily: AppFonts.pretendard),
            border: InputBorder.none,
          ),
        ),
      );
    }
  }

