import 'package:flutter/material.dart';

class AddScheduleBottomScreen extends StatefulWidget {
  final Function(Map<String, String>) onScheduleAdded;

  final String? initialTitle;
  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;
  final Set<String>? initialDays;

  const AddScheduleBottomScreen({
    required this.onScheduleAdded,
    this.initialTitle,
    this.initialStartTime,
    this.initialEndTime,
    this.initialDays,
    super.key,
  });

  @override
  State<AddScheduleBottomScreen> createState() => _AddScheduleBottomScreenState();
}


class _AddScheduleBottomScreenState extends State<AddScheduleBottomScreen> {
  final TextEditingController titleController = TextEditingController();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  Set<String> selectedDays = {};

  final List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  void initState() {
    super.initState();

    // ✅ 수정모드면 초기값 세팅
    if (widget.initialTitle != null) {
      titleController.text = widget.initialTitle!;
    }
    if (widget.initialStartTime != null) {
      startTime = widget.initialStartTime;
    }
    if (widget.initialEndTime != null) {
      endTime = widget.initialEndTime;
    }
    if (widget.initialDays != null) {
      selectedDays = Set.from(widget.initialDays!);
    }
  }

  void _submit() {
    if (titleController.text.isEmpty || startTime == null || endTime == null || selectedDays.isEmpty) {
      return; // 유효성 검사
    }

    final newSchedule = {
      'title': titleController.text,
      'time': '${startTime!.format(context)} - ${endTime!.format(context)}',
      'days': selectedDays.join(', ')
    };

    widget.onScheduleAdded(newSchedule); // ✅ 콜백 실행
    Navigator.pop(context); // ✅ 모달 닫기
  }


  @override
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      child: Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery
              .of(context)
              .viewInsets
              .bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '육아가 어려운 시간을 알려주세요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD26A5C),
              ),
            ),
            SizedBox(height: 24),

            // 일정 이름
            Align(
              alignment: Alignment.centerLeft,
              child: Text('일정 이름을 말해주세요',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: '회사, 수업, 진료 등등',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 24),

            // 시간 선택
            Align(
              alignment: Alignment.centerLeft,
              child: Text('언제부터 언제까지 인가요?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (picked != null) setState(() => startTime = picked);
                    },
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                          startTime == null ? '시작 시간' : startTime!.format(
                              context)),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (picked != null) setState(() => endTime = picked);
                    },
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                          endTime == null ? '종료 시간' : endTime!.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // 요일 선택
            Align(
              alignment: Alignment.centerLeft,
              child: Text('반복 요일을 선택해주세요',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: weekdays.map((day) {
                final selected = selectedDays.contains(day);
                return ChoiceChip(
                  label: Text(day),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (selected) {
                        selectedDays.remove(day);
                      } else {
                        selectedDays.add(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            SizedBox(height: 24),

            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD26A5C),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(widget.initialTitle != null ? '일정 수정하기' : '일정 저장하기'),
            ),
          ],
        ),
      ),
    );
  }
}
