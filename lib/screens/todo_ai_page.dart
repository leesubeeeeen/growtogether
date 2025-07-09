import 'package:flutter/material.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';

class TodoAiPage extends StatefulWidget {
  const TodoAiPage({super.key});

  @override
  State<TodoAiPage> createState() => _TodoAiPageState();
}

class _TodoAiPageState extends State<TodoAiPage> {
  final TextEditingController _controller = TextEditingController();
  bool _showSuggestion = false;

  void _onSubmit() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _showSuggestion = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Palette.mainRed,
        unselectedItemColor: Palette.greyText,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 뒤로가기
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12), // <- 변경됨
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Palette.mainRed),
                ),
              ),
              const SizedBox(height: 24),

              // 제목
              Center(
                child: Text(
                  '새로운 작업을 추가해봐요!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    fontFamily: AppFonts.primaryFont,
                    color: Palette.mainRed,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 부제목
              Text(
                '무엇을 할까요?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.primaryFont,
                  color: Palette.black,
                ),
              ),
              const SizedBox(height: 16),

              // 입력창
              Container(
                margin: const EdgeInsets.only(bottom: 8), // 그림자 공간 확보
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,      // 더 진한 그림자
                      blurRadius: 8,              // 퍼짐 정도
                      offset: Offset(0, 4),       // 수직 그림자
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: '할 일을 적어봐요!',
                    hintStyle: TextStyle(
                      color: Palette.greyText,
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    // fillColor: Colors.white,  <-- 이거 빼도 됨 (Container가 이미 white)
                    filled: false, // TextField 자체 배경 제거
                  ),
                  onSubmitted: (_) => _onSubmit(),
                ),
              ),


              const SizedBox(height: 24),

              if (_showSuggestion) ...[
                // AI 추천 카드
                Text(
                  'AI가 추천해요!',
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Palette.greyText,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.lightbulb_outline, color: Palette.greyText),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '대디의 일정이 최근 많이 비어있어요.\n화요일 오후는 어떠세요?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w100,
                                color: Palette.greyText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: Palette.greyBorder),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Icon(Icons.calendar_today, size: 16),
                          SizedBox(width: 6),
                          Text('5월 28일 (화) 오후 7시', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(Icons.person, size: 16),
                          SizedBox(width: 6),
                          Text('대디', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w100)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(Icons.sync, size: 16),
                          SizedBox(width: 6),
                          Text('반복 없음', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w100)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 선택 버튼 3개
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.mainRed,
                    foregroundColor: Palette.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('이렇게 할래요'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.lightRed,
                    foregroundColor: Palette.mainRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('조금 수정할게요'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.greyBackground,
                    foregroundColor: Palette.greyText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('제가 직접할래요'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}