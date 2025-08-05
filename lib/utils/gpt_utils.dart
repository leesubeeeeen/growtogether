List<String> extractRecommendedActions(String response) {
  final regex = RegExp(r'추천 행동:\s*\[(.*?)\]');
  final match = regex.firstMatch(response);

  if (match != null) {
    final actionsText = match.group(1)!;
    return actionsText
        .split(',')
        .map((e) => e.replaceAll('"', '').trim())
        .toList();
  }
  return [];
}