import 'package:flutter/material.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import 'home_page.dart'; // ← 추가
import 'counselor_1_page.dart'; // ← 추가
import 'counselor_2_page.dart'; // ← 추가
import 'counselor_3_page.dart'; // ← 추가

class CounselorSelectionPage extends StatelessWidget {
  const CounselorSelectionPage({super.key});

  Widget buildProfileCard({
    required String imagePath,
    required String name,
    required String description,
    required List<String> hashtags,
    required String quote,
    required VoidCallback onPressed, // 추가
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(imagePath),
                radius: 24,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Palette.black,
                        )),
                    const SizedBox(height: 4.0),
                    Text(description,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: Palette.greyText,
                        )),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 6,
            children: hashtags
                .map((tag) => Text(
              "#$tag",
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                color: Palette.mainRed,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 14.0),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 14.0),
          Text(
            "$quote",
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed, // ← 연결
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.softRed,
                foregroundColor: Palette.mainRed,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Text(
                "같이 해볼래요",
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Palette.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
        ),
        title: Text(
          '누구랑 같이 키워볼까요?',
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: Palette.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'AI는 언제든 바뀔 수 있어요.\n먼저 마음에 드는 친구부터 시작해볼까요?',
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Palette.greyText,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            buildProfileCard(
              imagePath: 'assets/images/counselor_1.png',
              name: '따뜻한 친정엄마',
              description: '감정에 먼저 공감하고, \n아이 중심의 부드러운 육아를 추천해요',
              hashtags: ['감정 중심', '실패에 위로', '부드러운 어휘 사용'],
              quote: "\"괜찮아, 너도 잘하고 있어. 억지로 안 해도 괜찮단다 :)",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Counselor1Page()),
                );
              },
            ),
            buildProfileCard(
              imagePath: 'assets/images/counselor_2.png',
              name: '조용한 성실맘',
              description: '과하지 않게, \n매일매일 반복되는 루틴을 함께 지켜가요.',
              hashtags: ['계획 중심', '공감보다는 팁 위주'],
              quote: "\"하루에 세 가지만 해도 충분해요. 규칙이 아이를 편하게 해줘요.",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Counselor2Page()),
                );
              },
            ),
            buildProfileCard(
              imagePath: 'assets/images/counselor_3.png',
              name: '차분한 상담선생님',
              description: '정답은 몰라도, 흐름은 알 수 있어요. \n루틴과 구조를 함께 만들어가는 육아 조력자예요.',
              hashtags: ['육아 원리 제시', '부모와 아이를 함께 보는 시야'],
              quote: "\"아이 반응은 예민한 흐름일 수 있어요. 안정 루틴을 잡아볼까요?",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Counselor3Page()),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

