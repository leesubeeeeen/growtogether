// file: lib/screens/schedule_preference_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_schedule_bottom_screen.dart';

class SchedulePreferencePage extends StatefulWidget {
  const SchedulePreferencePage({super.key});

  @override
  State<SchedulePreferencePage> createState() => _SchedulePreferencePageState();
}

class _SchedulePreferencePageState extends State<SchedulePreferencePage> {
  final Color mainColor = const Color(0xFFD26A5C);
  final TextEditingController _nicknameController = TextEditingController();

  // String → dynamic (DateTime도 들어가기 때문에)
  final List<Map<String, dynamic>> schedules = [];

  String _fmt(DateTime dt) => DateFormat('M/d (E) HH:mm', 'ko_KR').format(dt);

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

            Row(
              children: [
                Icon(Icons.looks_one, color: mainColor),
                const SizedBox(width: 8),
                const Text('상대방의 애칭을 정해주세요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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

            Row(
              children: [
                Icon(Icons.looks_two, color: mainColor),
                const SizedBox(width: 8),
                const Text('고정적인 스케줄이 있나요?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
                      title: '고정 스케줄 추가',
                      initialDate: DateTime.now(),
                      onScheduleAdded: (newSchedule) async {
                        setState(() {
                          schedules.add(newSchedule);
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

            ...schedules.map((schedule) {
              // 단일 or 반복 모두 대응하여 예쁘게 보여주기
              final title = schedule['title'] ?? '';
              final assigned = schedule['assignedTo'] ?? 'me';
              final occurrences = schedule['occurrences'] as List?; // 반복일 경우 존재

              Widget timeWidget;
              if (occurrences != null && occurrences.isNotEmpty) {
                // 반복: 첫 1~2개만 요약 표시
                final preview = occurrences.take(2).toList();
                final text = preview.map((e) {
                  final s = e['start'] as DateTime;
                  final eEnd = e['end'] as DateTime;
                  return '${_fmt(s)} ~ ${DateFormat.Hm().format(eEnd)}';
                }).join('\n');
                timeWidget = Text(text);
              } else {
                // 단일
                final start = schedule['start'] as DateTime?;
                final end = schedule['end'] as DateTime?;
                if (start != null && end != null) {
                  timeWidget = Text('${_fmt(start)} ~ ${DateFormat.Hm().format(end)}');
                } else {
                  timeWidget = const Text('시간 정보 없음');
                }
              }

              // 요일 텍스트(있으면)
              final daysText = (schedule['days'] is List)
                  ? (schedule['days'] as List).join(', ')
                  : (schedule['occurrences'] != null ? '반복 스케줄' : '-');

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.lightbulb_outline, color: mainColor),
                        const SizedBox(width: 8),
                        Text(title, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(assigned == 'me' ? '나' : '배우자'),
                          backgroundColor: const Color(0xFFFFF2ED),
                          side: BorderSide(color: mainColor.withOpacity(0.2)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Icon(Icons.calendar_today, color: mainColor, size: 16),
                        const SizedBox(width: 4),
                        Expanded(child: timeWidget),
                      ]),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.sync, color: mainColor, size: 16),
                        const SizedBox(width: 4),
                        Expanded(child: Text(daysText)),
                      ]),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
