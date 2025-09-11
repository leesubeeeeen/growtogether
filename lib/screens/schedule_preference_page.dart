import 'package:flutter/material.dart';
import 'add_schedule_bottom_screen.dart';

class SchedulePreferencePage extends StatefulWidget {
  @override
  _SchedulePreferencePageState createState() => _SchedulePreferencePageState();
}

class _SchedulePreferencePageState extends State<SchedulePreferencePage> {
  final Color mainColor = const Color(0xFFD26A5C);
  final TextEditingController _nicknameController = TextEditingController();

  // 🔥 String → dynamic (DateTime도 들어가기 때문에)
  List<Map<String, dynamic>> schedules = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '함께 키우기 위한\n첫 걸음을 시작해볼까요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // step 1
            Row(
              children: [
                Icon(Icons.looks_one, color: mainColor),
                const SizedBox(width: 8),
                const Text(
                  '상대방의 애칭을 정해주세요',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                hintText: '상대방을 부르고 싶은 이름을 알려주세요',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // step 2
            Row(
              children: [
                Icon(Icons.looks_two, color: mainColor),
                const SizedBox(width: 8),
                const Text(
                  '고정적인 스케줄이 있나요?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                    return AddScheduleBottomScreen(
                      onScheduleAdded: (newSchedule) {
                        setState(() {
                          schedules.add(newSchedule); // ✅ 리스트에 추가
                        });
                      },
                    );
                  },
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('추가'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFF2ED),
                foregroundColor: mainColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: mainColor.withOpacity(0.3)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 리스트 표시
            ...schedules.map((schedule) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: mainColor),
                        const SizedBox(width: 8),
                        Text(
                          schedule['title'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: mainColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${schedule['start'].hour}:${schedule['start'].minute.toString().padLeft(2, '0')}'
                              ' - ${schedule['end'].hour}:${schedule['end'].minute.toString().padLeft(2, '0')}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.sync, color: mainColor, size: 16),
                        const SizedBox(width: 4),
                        Text((schedule['days'] as List).join(', ')),
                      ],
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
