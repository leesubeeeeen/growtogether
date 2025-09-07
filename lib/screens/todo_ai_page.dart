import 'package:flutter/material.dart';
import 'package:growtogether/screens/add_schedule_bottom_screen.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import '../widgets/bottom_navi_bar.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: false,
                  ),
                  onSubmitted: (_) => _onSubmit(),
                ),
              ),
              const SizedBox(height: 24),
              if (_showSuggestion) ...[
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
                          Icon(Icons.lightbulb_outline, color: Palette.calmYellow),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '대디의 일정이 최근 많이 비어있어요.\n화요일 오후는 어떠세요?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                color: Palette.black,
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
                          Icon(Icons.calendar_today, size: 16, color: Palette.mainRed),
                          SizedBox(width: 6),
                          Text('5월 28일 (화) 오후 7시', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(Icons.person, size: 16, color: Palette.mainRed),
                          SizedBox(width: 6),
                          Text('대디', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w100)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(Icons.sync, size: 16, color: Palette.mainRed),
                          SizedBox(width: 6),
                          Text('반복 없음', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w100)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final todoText = _controller.text.trim();
                    if (todoText.isNotEmpty) {
                      Provider.of<TodoProvider>(context, listen: false).addTodo({
                        'title': todoText,
                        'time': '시간 미정',
                      });
                      _controller.clear();
                      setState(() => _showSuggestion = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('할 일이 추가되었어요!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.mainRed,
                    foregroundColor: Palette.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text(
                    '이렇게 할래요',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    final todoText = _controller.text.trim();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => AddScheduleBottomScreen(
                        title: '추천된 일정을 수정해서 추가해볼까요?',
                        initialTitle: todoText,
                        initialStartTime: TimeOfDay(hour: 19, minute: 0),
                        initialEndTime: TimeOfDay(hour: 19, minute: 30),
                        initialDays: {'화'},
                        onScheduleAdded: (updatedSchedule) {
                          context.read<TodoProvider>().addTodo(updatedSchedule);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('일정을 수정해서 추가했어요!')),
                          );
                          _controller.clear();
                          setState(() => _showSuggestion = false);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.lightRed,
                    foregroundColor: Palette.mainRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text(
                    '조금 수정할게요',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
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
                  child: const Text(
                    '제가 직접할래요',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 3),
    );
  }
}
