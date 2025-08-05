List<String> extractRecommendedActions(String response) {
  final regex = RegExp(r'\[(.*?)\]');
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
