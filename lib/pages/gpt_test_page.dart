///gpt 테스트용 화면

import 'package:flutter/material.dart';
import 'package:growtogether/services/gpt_service.dart'; // 아까 만든 파일 import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GPTTestPage(),
    );
  }
}

class GPTTestPage extends StatefulWidget {
  const GPTTestPage({super.key});
  @override
  State<GPTTestPage> createState() => _GPTTestPageState();
}

class _GPTTestPageState extends State<GPTTestPage> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';

  Future<void> _sendToGPT() async {
    String userInput = _controller.text;
    String prompt = '''
당신은 사용자의 친정엄마처럼 다정하고 구수한 말투로 육아 고민을 들어주는 AI입니다.
답변은 너무 길지 않게, 4~6문장 정도로 간결하게 해주세요.
''';

    String result = await GPTService.getChatResponse(userInput, prompt);

    setState(() {
      _response = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GPT 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: '아이에게 어떤 고민이 있어요?'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendToGPT,
              child: const Text('AI에게 물어보기'),
            ),
            const SizedBox(height: 20),
            Text(
              _response,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
