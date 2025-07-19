class EmotionModel {
  final String feeling;  // 예: '행복해요', '피곤해요'
  final double fatigue;  // 0.0 ~ 1.0 사이 값
  final DateTime timestamp;

  EmotionModel({
    required this.feeling,
    required this.fatigue,
    required this.timestamp,
  });
}
