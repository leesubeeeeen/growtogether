import 'package:flutter/material.dart';
import 'package:growtogether/services/gpt_service.dart';
import 'package:growtogether/theme/palette.dart';

class CounselorChatPage extends StatefulWidget {
  final String counselorName;
  final String imagePath;
  final Color themeColor;
  final String systemPrompt;

  const CounselorChatPage({
    super.key,
    required this.counselorName,
    required this.imagePath,
    required this.themeColor,
    required this.systemPrompt,
  });

  @override
  State<CounselorChatPage> createState() => _CounselorChatPageState();
}

class _CounselorChatPageState extends State<CounselorChatPage> {
  final List<Map<String, String>> _chatHistory = [];
  final TextEditingController _controller = TextEditingController();

  Future<void> _sendMessage() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _chatHistory.add({'role': 'user', 'message': question});
      _controller.clear();
    });

    final messages = _buildMessagesForGPT(widget.systemPrompt);
    final result = await GptService().getAnswerFromMessages(messages);

    setState(() {
      _chatHistory.add({'role': 'assistant', 'message': result});
    });
  }

  List<Map<String, String>> _buildMessagesForGPT(String systemPrompt) {
    final messages = <Map<String, String>>[
      { "role": "system", "content": systemPrompt },
    ];

    for (final chat in _chatHistory) {
      messages.add({
        "role": chat["role"]!,
        "content": chat["message"]!,
      });
    }

    return messages;
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
          color: isUser ? Palette.softRed : widget.themeColor,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, size: 20),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundImage: AssetImage(widget.imagePath),
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.counselorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Palette.mainRed,
                        ),
                      ),
                      const Text(
                        '• Online',
                        style: TextStyle(
                          color: Color(0xFF4A705E),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.settings, color: Palette.greyText),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '이 시기에는 이런 질문이 많아요 😊',
              style: TextStyle(fontSize: 15, color: Palette.black),
            ),
            const SizedBox(height: 12),
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
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: const [
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
                    icon: const Icon(Icons.send, color: Palette.mainRed),
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

