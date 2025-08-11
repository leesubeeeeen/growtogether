import 'package:flutter/material.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';

class ConnectCompleteScreen extends StatefulWidget {
  const ConnectCompleteScreen({super.key});

  @override
  State<ConnectCompleteScreen> createState() => _ConnectCompleteScreenState();
}

class _ConnectCompleteScreenState extends State<ConnectCompleteScreen> {
  @override
  void initState() {
    super.initState();
    // 2초 뒤 홈으로 (스택 비우고 진입)
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final h = c.maxHeight;
            final titleSize = w * 0.065;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '연결 완료',
                    style: TextStyle(
                      fontSize: titleSize,
                      color: Palette.mainRed,
                      fontWeight: FontWeight.w800,
                      fontFamily: AppFonts.primaryFont,
                    ),
                  ),
                  SizedBox(height: h * 0.04),
                  FractionallySizedBox(
                    widthFactor: 0.45,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset(
                        'assets/images/seedling_placeholder.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                        const Text('🌱 캐릭터', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


