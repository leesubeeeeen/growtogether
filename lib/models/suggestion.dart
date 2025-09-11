class Suggestion {
  final String assignedTo; // "me" | "partner"
  final DateTime start;
  final DateTime end;
  final String slotLabel;  // "오전/오후/저녁"
  final String message;    // 카드에 표시할 멘트

  const Suggestion({
    required this.assignedTo,
    required this.start,
    required this.end,
    required this.slotLabel,
    required this.message,
  });
}
