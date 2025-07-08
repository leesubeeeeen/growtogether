import 'package:flutter/material.dart';

class CounselorChatPage extends StatelessWidget {
  const CounselorChatPage({super.key});

  final Color themeColor = const Color(0xFFEFDAD5); // 우리 테마색

  Widget buildQuestionCard({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '\"$question\"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.open_in_new, size: 16, color: Colors.black45),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            answer,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F9),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_ios, size: 20),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/counselor_3.png'),
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '차분한 상담선생님',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFE06C4E), // 우리 테마색 텍스트
                        ),
                      ),
                      const Text(
                        '• Online',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.settings, color: Colors.grey[700]),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '이 시기에는 이런 질문이 많아요 😊',
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            // 질문 리스트
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  buildQuestionCard(
                    question: '아직 안 걷는데 괜찮나요?',
                    answer: '걷기는 18개월까지 기다려보셔도 괜찮아요.',
                  ),
                  buildQuestionCard(
                    question: '이 시기에 말을 안 해도 되나요?',
                    answer: '응알이만 해도 괜찮은 시기예요, 너무 걱정 마세요.',
                  ),
                  buildQuestionCard(
                    question: '밤에 자주 깨요 왜죠?',
                    answer: '성장통이나 불안 때문일 수 있어요, 루틴 점검도 좋아요.',
                  ),
                  buildQuestionCard(
                    question: '편식이 심한데 어쩌죠?',
                    answer: '편식은 흔한 일이에요, 즐겁게 식사 분위기 만들어주세요.',
                  ),
                ],
              ),
            ),
            // Footer Input
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '궁금한 점을 뭐든지 물어보세요',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic, color: Colors.redAccent),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.deepOrange),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
