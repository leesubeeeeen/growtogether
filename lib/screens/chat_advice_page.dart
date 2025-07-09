import 'package:flutter/material.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import 'dart:async';

class ChatAdvicePage extends StatefulWidget {
  const ChatAdvicePage({super.key});

  @override
  State<ChatAdvicePage> createState() => _ChatAdvicePageState();
}

class _ChatAdvicePageState extends State<ChatAdvicePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _controller.clear();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _messages.add(ChatMessage(
          text: _getDummyReply(text),
          isUser: false,
        ));
      });
      _scrollToBottom();
    });
  }

  String _getDummyReply(String input) {
    if (input.contains('언제 걷나요')) {
      return '보통 9~18개월 사이에 걷기 시작해요!';
    }
    if (input.contains('병원')) {
      return '걱정이 되신다면 소아과에서 상담 받아보는 것도 좋아요.';
    }
    return '좋은 질문이에요. 조금 더 자세히 알려주실 수 있나요?';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: Palette.black),
          ),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/avatar_doctor.png'), // 네 이미지로 변경
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '차분한 상담선생님',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Palette.black,
                  ),
                ),
                Text(
                  '• Online',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? Colors.white
                          : Palette.softRed,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: msg.isUser
                          ? []
                          : [
                        const BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: AppFonts.pretendard,
                        color: Palette.black,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 입력창
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: '궁금한 점을 뭐든지 물어보세요',
                      hintStyle: TextStyle(
                        color: Palette.greyText,
                        fontFamily: AppFonts.primaryFont,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Palette.mainRed),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
