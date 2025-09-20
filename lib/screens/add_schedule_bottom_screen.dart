// file: lib/screens/add_schedule_bottom_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/palette.dart';
import '../theme/fonts.dart';

typedef ScheduleAddedCallback = Future<void> Function(Map<String, dynamic> result);

class AddScheduleBottomScreen extends StatefulWidget {
  final String title;
  final String? initialTitle;
  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;
  final Set<String>? initialDays;        // {'월','수','금'} (ko_KR)
  final String? initialAssignedTo;       // 'me' | 'partner'
  final DateTime? initialDate;           // ✅ 선택 날짜

  final ScheduleAddedCallback onScheduleAdded;

  const AddScheduleBottomScreen({
    super.key,
    required this.title,
    this.initialTitle,
    this.initialStartTime,
    this.initialEndTime,
    this.initialDays,
    this.initialAssignedTo,
    this.initialDate,
    required this.onScheduleAdded,
  });

  @override
  State<AddScheduleBottomScreen> createState() => _AddScheduleBottomScreenState();
}

class _AddScheduleBottomScreenState extends State<AddScheduleBottomScreen> {
  late TextEditingController _titleCtrl;
  late DateTime _baseDate;            // 자정으로 정규화된 기준 날짜
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _assignedTo;            // 'me' | 'partner'
  final Set<String> _repeatDaysKo = {}; // {'월','화','수','목','금','토','일'}

  final List<String> _koWeeks = const ['월','화','수','목','금','토','일'];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialTitle ?? '');

    final now = DateTime.now();
    _baseDate = DateTime(
      (widget.initialDate ?? now).year,
      (widget.initialDate ?? now).month,
      (widget.initialDate ?? now).day,
    );

    _startTime = widget.initialStartTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime   = widget.initialEndTime   ?? const TimeOfDay(hour: 10, minute: 0);

    _assignedTo = widget.initialAssignedTo ?? 'me';

    if (widget.initialDays != null && widget.initialDays!.isNotEmpty) {
      _repeatDaysKo.addAll(widget.initialDays!);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  int _weekdayKoToIntl(String ko) {
    // 월(1)~일(7)
    final idx = _koWeeks.indexOf(ko);
    if (idx < 0) return DateTime.monday;
    return (idx + 1);
  }

  String _formatDate(DateTime d) => DateFormat('yyyy.MM.dd (E)', 'ko_KR').format(d);

  DateTime _merge(DateTime base, TimeOfDay t) =>
      DateTime(base.year, base.month, base.day, t.hour, t.minute);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _baseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      setState(() {
        _baseDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          final st = _startTime.hour * 60 + _startTime.minute;
          final et = _endTime.hour * 60 + _endTime.minute;
          if (et <= st) {
            _endTime = TimeOfDay(
              hour: (_startTime.hour + 1) % 24,
              minute: _startTime.minute,
            );
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('제목을 입력해 주세요.')));
      return;
    }

    final start = _merge(_baseDate, _startTime);
    final end   = _merge(_baseDate, _endTime);

    if (_repeatDaysKo.isNotEmpty) {
      // ✅ 반복 선택 시: 8주간 출현들 생성
      const weeks = 8;
      final occurrences = <Map<String, DateTime>>[];

      final int baseWeekday = _baseDate.weekday; // 1(월)~7(일)
      final DateTime weekMonday = _baseDate.subtract(Duration(days: baseWeekday - DateTime.monday));

      for (int w = 0; w < weeks; w++) {
        final DateTime weekStart = weekMonday.add(Duration(days: w * 7));
        for (final ko in _repeatDaysKo) {
          final intlW = _weekdayKoToIntl(ko);
          final DateTime dayDate = weekStart.add(Duration(days: intlW - 1));
          final DateTime s = _merge(dayDate, _startTime);
          final DateTime e = _merge(dayDate, _endTime);
          occurrences.add({'start': s, 'end': e});
        }
      }

      await widget.onScheduleAdded({
        'title': title,
        'assignedTo': _assignedTo,
        'occurrences': occurrences, // ✅ 배치 저장용 출력
      });
      return;
    }

    // 반복 없음 → 단일
    await widget.onScheduleAdded({
      'title': title,
      'assignedTo': _assignedTo,
      'start': start,
      'end': end,
    });
  }

  Widget _buildWeekdayChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _koWeeks.map((ko) {
        final selected = _repeatDaysKo.contains(ko);
        return FilterChip(
          label: Text(
            ko,
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              color: selected ? Colors.white : Palette.greyText,
            ),
          ),
          selected: selected,
          onSelected: (val) {
            setState(() {
              if (val) {
                _repeatDaysKo.add(ko);
              } else {
                _repeatDaysKo.remove(ko);
              }
            });
          },
          selectedColor: Palette.mainRed,
          backgroundColor: Palette.greyBackground,
          showCheckmark: false,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Palette.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: '제목',
                  hintStyle: TextStyle(color: Palette.greyText, fontFamily: AppFonts.primaryFont),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Palette.mainRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatDate(_baseDate),
                      style: TextStyle(fontFamily: AppFonts.primaryFont, color: Palette.black),
                    ),
                  ),
                  TextButton(onPressed: _pickDate, child: const Text('날짜 변경')),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Palette.mainRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_startTime.format(context)} ~ ${_endTime.format(context)}',
                      style: TextStyle(fontFamily: AppFonts.primaryFont, color: Palette.black),
                    ),
                  ),
                  TextButton(onPressed: () => _pickTime(isStart: true), child: const Text('시작')),
                  TextButton(onPressed: () => _pickTime(isStart: false), child: const Text('종료')),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Palette.mainRed),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _assignedTo,
                    items: const [
                      DropdownMenuItem(value: 'me', child: Text('나')),
                      DropdownMenuItem(value: 'partner', child: Text('배우자')),
                    ],
                    onChanged: (v) => setState(() => _assignedTo = v ?? 'me'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                '반복 요일 (선택 시 8주간 반복 인스턴스 저장)',
                style: TextStyle(fontFamily: AppFonts.primaryFont, fontSize: 12, color: Palette.greyText),
              ),
              const SizedBox(height: 8),
              _buildWeekdayChips(),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.mainRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('추가하기',
                      style: TextStyle(fontFamily: AppFonts.primaryFont, fontWeight: FontWeight.w500)),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
