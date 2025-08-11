import 'package:flutter/material.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import 'signup_screen.dart';
import 'connect_complete_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

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
            padding: EdgeInsets.only(
              left: w * 0.06,
              right: w * 0.06,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
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

                // 이메일 입력
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                  child: TextField(
                    controller: emailController,
                    style: const TextStyle(fontFamily: AppFonts.pretendard),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.email_outlined, color: Palette.black),
                      hintText: '이메일을 입력해주세요',
                      hintStyle: TextStyle(fontFamily: AppFonts.pretendard),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                SizedBox(height: h * 0.025),

                // 비밀번호 입력
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                  child: TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontFamily: AppFonts.pretendard),
                    decoration: InputDecoration(
                      icon: const Icon(Icons.lock_outline, color: Palette.black),
                      hintText: '비밀번호를 입력해주세요',
                      hintStyle: const TextStyle(fontFamily: AppFonts.pretendard),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Palette.greyText,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: h * 0.07),

                // 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  height: h * 0.065,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConnectCompleteScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.mainRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
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

                SizedBox(height: h * 0.025),

                // 회원가입 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '계정이 없으신가요? ',
                      style: TextStyle(
                        color: Palette.greyText,
                        fontFamily: AppFonts.pretendard,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        '회원가입하기',
                        style: TextStyle(
                          color: Palette.mainRed,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.pretendard,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
