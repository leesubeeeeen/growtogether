import 'package:intl/intl.dart';
import '../models/calendar_event.dart';
import '../models/suggestion.dart';

class AssignmentEngine {
  final List<CalendarEvent> myEvents;
  final List<CalendarEvent> partnerEvents;
  final double myFatigue;
  final double partnerFatigue;
  final String myFeeling;
  final String partnerFeeling;
  final Map<String, dynamic> slots;
  final Map<String, dynamic> messages;

  AssignmentEngine({
    required this.myEvents,
    required this.partnerEvents,
    required this.myFatigue,
    required this.partnerFatigue,
    required this.myFeeling,
    required this.partnerFeeling,
    required this.slots,
    required this.messages,
  });

  Suggestion suggest(String taskTitle, DateTime today) {
    for (final entry in slots.entries) {
      final slotKey = entry.key; // morning, afternoon, evening
      final s = _combine(today, entry.value['start']);
      final e = _combine(today, entry.value['end']);

      final meBusy = myEvents.any((ev) => _overlaps(ev.start, ev.end, s, e));
      final partnerBusy = partnerEvents.any((ev) => _overlaps(ev.start, ev.end, s, e));

      // 1. 둘 다 비었을 때 → 피로도 낮은 사람 + 긍정 감정
      if (!meBusy && !partnerBusy) {
        final assigned = _chooseByFatigueAndFeeling();
        final msg = _buildMessage(assigned, slotKey, taskTitle);
        return Suggestion(
          assignedTo: assigned,
          start: s,
          end: e,
          slotLabel: _slotKo(slotKey),
          message: msg,
        );
      }

      // 2. 파트너만 비었을 때
      if (partnerBusy == false && meBusy == true) {
        final msg = (messages['partner_free'] as String)
            .replaceAll('{partnerName}', '배우자분')
            .replaceAll('{slotLabel}', _slotKo(slotKey))
            .replaceAll('{subjectPronoun}', '배우자분')
            .replaceAll('{taskTitle}', taskTitle);
        return Suggestion(
          assignedTo: 'partner',
          start: s,
          end: e,
          slotLabel: _slotKo(slotKey),
          message: msg,
        );
      }

      // 3. 나만 비었을 때
      if (meBusy == false && partnerBusy == true) {
        final msg = (messages['me_free'] as String)
            .replaceAll('{slotLabel}', _slotKo(slotKey))
            .replaceAll('{taskTitle}', taskTitle);
        return Suggestion(
          assignedTo: 'me',
          start: s,
          end: e,
          slotLabel: _slotKo(slotKey),
          message: msg,
        );
      }
    }

    // 4. 둘 다 바쁨 → 내일 아침 제안
    final firstSlot = slots.entries.first;
    final s = _combine(today.add(const Duration(days: 1)), firstSlot.value['start']);
    final e = _combine(today.add(const Duration(days: 1)), firstSlot.value['end']);
    final msg = (messages['both_busy'] as String)
        .replaceAll('{slotLabel}', '오늘')
        .replaceAll('{nextSlotLabel}', '내일 ${_slotKo(firstSlot.key)}')
        .replaceAll('{timeRange}', "${_fmt(s)}~${_fmt(e)}");
    return Suggestion(
      assignedTo: 'me',
      start: s,
      end: e,
      slotLabel: _slotKo(firstSlot.key),
      message: msg,
    );
  }

  // ---------- helper ----------
  String _chooseByFatigueAndFeeling() {
    // 간단 예시: 피로도 낮은 사람이 우선, 같으면 긍정적 이모지 우선
    if (myFatigue < partnerFatigue) return 'me';
    if (partnerFatigue < myFatigue) return 'partner';
    if (_isPositive(myFeeling) && !_isPositive(partnerFeeling)) return 'me';
    if (_isPositive(partnerFeeling) && !_isPositive(myFeeling)) return 'partner';
    return 'me';
  }

  bool _isPositive(String feeling) {
    const positive = ['😀','😊','😄','🥳','😎','🙂','❤️'];
    return positive.contains(feeling);
  }

  DateTime _combine(DateTime d, String hhmm) {
    final parts = hhmm.split(':');
    return DateTime(d.year, d.month, d.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  bool _overlaps(DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) {
    return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
  }

  String _fmt(DateTime t) => DateFormat('M월 d일 (E) a h:mm', 'ko_KR').format(t);
  String _slotKo(String key) {
    switch (key) {
      case 'morning': return '오전';
      case 'afternoon': return '오후';
      case 'evening': return '저녁';
      default: return key;
    }
  }

  String _buildMessage(String assigned, String slotKey, String taskTitle) {
    if (assigned == 'me') {
      return (messages['me_free'] as String)
          .replaceAll('{slotLabel}', _slotKo(slotKey))
          .replaceAll('{taskTitle}', taskTitle);
    } else {
      return (messages['partner_free'] as String)
          .replaceAll('{partnerName}', '배우자분')
          .replaceAll('{slotLabel}', _slotKo(slotKey))
          .replaceAll('{subjectPronoun}', '배우자분')
          .replaceAll('{taskTitle}', taskTitle);
    }
  }
}
