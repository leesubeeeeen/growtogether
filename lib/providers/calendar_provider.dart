/// file: lib/providers/calendar_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/calendar_event.dart';

/// Firestore 스키마(권장)
/// users/{uid}/events/{eventId}
///   - title: string
///   - content: string
///   - location: string
///   - parent: string   // '나' | '배우자' 등 표시용
///   - start: Timestamp
///   - end: Timestamp
///   - icon: string     // 'event', 'work', 'home' 등
///   - color: string    // '#RRGGBB' 또는 '#AARRGGBB' (선택)
///
/// 본 Provider는 위 스키마를 로드하여 CalendarEvent로 보관/제공한다.
class CalendarProvider with ChangeNotifier {
  final List<CalendarEvent> _events = [];
  DateTime _selectedDate = DateTime.now();

  List<CalendarEvent> get events => List.unmodifiable(_events);
  DateTime get selectedDate => _stripTime(_selectedDate);

  // 자정 정규화
  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  void selectDate(DateTime date) {
    _selectedDate = _stripTime(date);
    notifyListeners();
  }

  /// Firestore → Provider 로드
  Future<void> loadEventsFromFirestore(String uid) async {
    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('events');

    // 시간순 정렬로 가져오기(없으면 클라이언트에서 정렬)
    final snapshot = await col.orderBy('start', descending: false).get();

    _events
      ..clear()
      ..addAll(snapshot.docs.map((doc) {
        final data = doc.data();

        final DateTime start =
            (data['start'] as Timestamp?)?.toDate() ?? DateTime.now();
        final DateTime end =
            (data['end'] as Timestamp?)?.toDate() ?? start;

        final String colorRaw = (data['color'] ?? '').toString();
        final Color color = _parseColorOrDefault(colorRaw);

        return CalendarEvent(
          id: doc.id,
          title: (data['title'] ?? '').toString(),
          content: (data['content'] ?? '').toString(),
          location: (data['location'] ?? '').toString(),
          parent: (data['parent'] ?? '').toString(),
          start: start,
          end: end,
          icon: (data['icon'] ?? 'event').toString(),
          color: color,
        );
      }));

    // 혹시 orderBy가 없을 때 대비
    _events.sort((a, b) => a.start.compareTo(b.start));

    notifyListeners();
  }

  /// 전체 새로고침 헬퍼
  Future<void> refreshForUser(String uid) => loadEventsFromFirestore(uid);

  /// 이벤트 추가(로컬 반영). Firestore 저장은 별도 Repo/서비스에서 수행 권장.
  void addEvent(CalendarEvent event) {
    _events.add(event);
    _events.sort((a, b) => a.start.compareTo(b.start));
    notifyListeners();
  }

  /// 선택 날짜의 이벤트만 반환(시간순)
  List<CalendarEvent> getEventsForDay(DateTime day) {
    final d = _stripTime(day);
    final list = _events.where((e) {
      final sd = _stripTime(e.start);
      return sd.year == d.year && sd.month == d.month && sd.day == d.day;
    }).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

/// 아이콘 문자열 → IconData 변환을 모델 또는 위젯에서 처리할 수 있으므로
/// 본 Provider에는 포함하지 않았다. (TodoPage에서 CalendarEvent.getIconFromString 사용)
}

/// '#RRGGBB' 또는 '#AARRGGBB' → Color
Color _parseColorOrDefault(String hex, {Color fallback = const Color(0xFFFFE6E6)}) {
  if (hex.isEmpty) return fallback;
  try {
    var h = hex.toUpperCase().replaceAll('#', '');
    if (h.length == 6) {
      h = 'FF$h'; // 불투명도 채움
    }
    final value = int.parse(h, radix: 16);
    return Color(value);
  } catch (_) {
    return fallback;
  }
}
