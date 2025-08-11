import 'package:flutter/material.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';

class ConnectPartnerScreen extends StatefulWidget {
  const ConnectPartnerScreen({super.key});

  @override
  State<ConnectPartnerScreen> createState() => _ConnectPartnerScreenState();
}

class _ConnectPartnerScreenState extends State<ConnectPartnerScreen> {
  final TextEditingController _partnerIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Palette.background,
      resizeToAvoidBottomInset: false, // 키보드 올려도 화면 안밀림
      body: SafeArea(
        child: SingleChildScrollView( // 오버플로우 방지
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: h * 0.05),

                Text(
                  '상대 배우자의\n아이디를 입력하세요',
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
                          style: const TextStyle(fontFamily: AppFonts.pretendard),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '같이 키우기',
                            hintStyle: TextStyle(
                              color: Palette.greyText,
                              fontFamily: AppFonts.pretendard,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: h * 0.05),

                // 확인 버튼
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
                    onPressed: () {
                      // 나중에 연결 요청 API 호출 예정
                      print('입력된 ID: ${_partnerIdController.text}');
                    },
                    child: const Text(
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

                // 뒤로가기 버튼
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

