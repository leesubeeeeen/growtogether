class Suggestion {
  final String assignedTo;
  final DateTime start;
  final DateTime end;
  final String slotLabel;
  final String message;
  final String? location; // ⬅️ 새로 추가(확장)
  final String? icon;     // ⬅️ 새로 추가(확장)

  const Suggestion({
    required this.assignedTo,
    required this.start,
    required this.end,
    required this.slotLabel,
    required this.message,
    this.location,
    this.icon,
  });
}
