import 'package:flutter/material.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
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
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

                SizedBox(height: h * 0.05),

                Text(
                  '계정을 만들고\n같이 키워봐요!',
                  style: TextStyle(
                    fontSize: w * 0.065,
                    fontWeight: FontWeight.bold,
                    color: Palette.mainRed,
                    fontFamily: AppFonts.pretendard,
                  ),
                ),

                SizedBox(height: h * 0.07),

                // 이름 입력
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                  child: TextField(
                    controller: nameController,
                    style: const TextStyle(fontFamily: AppFonts.pretendard),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person_outline, color: Colors.black),
                      hintText: '이름을 입력해주세요',
                      hintStyle: TextStyle(fontFamily: AppFonts.pretendard),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                SizedBox(height: h * 0.025),

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
                      icon: Icon(Icons.email_outlined, color: Colors.black),
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
                      icon: const Icon(Icons.lock_outline, color: Colors.black),
                      hintText: '비밀번호를 입력해주세요',
                      hintStyle: const TextStyle(fontFamily: AppFonts.pretendard),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
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

                // 계정 만들기 버튼
                SizedBox(
                  width: double.infinity,
                  height: h * 0.065,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
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
                      '계정 만들기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.pretendard,
                        color: Palette.background,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: h * 0.025),

                // 이미 계정이 있나요? 로그인하기
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '이미 계정이 있으신가요? ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: AppFonts.pretendard,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        '로그인하기',
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