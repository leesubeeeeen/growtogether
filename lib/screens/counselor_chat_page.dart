import 'package:flutter/material.dart';
import 'package:growtogether/services/gpt_service.dart';

class CounselorChatPage extends StatefulWidget {
  const CounselorChatPage({super.key});

  @override
  State<CounselorChatPage> createState() => _CounselorChatPageState();
}

class _CounselorChatPageState extends State<CounselorChatPage> {
  final Color themeColor = const Color(0xFFEFDAD5);
  final List<Map<String, String>> _chatHistory = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _chatHistory.add({'role': 'user', 'message': question});
      _controller.clear();
    });

    String result = await GptService().getAnswer(question);
    setState(() {
      _chatHistory.add({'role': 'ai', 'message': result});
    });
  }

  Widget _buildChatCard(String role, String message) {
    final isUser = role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        padding: const EdgeInsets.all(12.0),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? Colors.orange[100] : themeColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(message, style: const TextStyle(fontSize: 15)),
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
                      const Text(
                        '차분한 상담선생님',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFE06C4E),
                        ),
                      ),
                      const Text(
                        '• Online',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

            // 채팅 영역
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final role = _chatHistory[index]['role']!;
                  final message = _chatHistory[index]['message']!;
                  return _buildChatCard(role, message);
                },
              ),
            ),

            // 입력창
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
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration.collapsed(
                        hintText: '궁금한 점을 뭐든지 물어보세요',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.deepOrange),
                    onPressed: _sendMessage,
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
