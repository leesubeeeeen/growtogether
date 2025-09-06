class EmotionModel {
  final String feeling;   // 오늘 감정 (이모티콘)
  final double fatigue;   // 피로도 (0~100)
  final DateTime timestamp; // 저장된 날짜/시간

  EmotionModel({
    required this.feeling,
    required this.fatigue,
    required this.timestamp,
  });

  /// yyyy-MM-dd 형태 날짜 키 (문서 ID 용도)
  String get timestampKey =>
      timestamp.toIso8601String().split("T").first;
}
