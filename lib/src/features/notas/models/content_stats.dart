class ContentStats {
  final int words;
  final int characters;
  final int mentions;

  const ContentStats({
    required this.words,
    required this.characters,
    required this.mentions,
  });

  const ContentStats.zero() : words = 0, characters = 0, mentions = 0;

  bool get isEmpty => words == 0 && characters == 0 && mentions == 0;

  factory ContentStats.fromText(String text) {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) {
      return const ContentStats.zero();
    }

    final words = RegExp(r'\S+').allMatches(normalizedText).length;
    final characters = normalizedText.runes.length;
    final mentions = _mentionPattern.allMatches(text).length;

    return ContentStats(
      words: words,
      characters: characters,
      mentions: mentions,
    );
  }

  ContentStats operator +(ContentStats other) {
    return ContentStats(
      words: words + other.words,
      characters: characters + other.characters,
      mentions: mentions + other.mentions,
    );
  }
}

final RegExp _mentionPattern = RegExp(
  r'@[^\s\r\n`<>\[\]\(\){}@,.;:!?]+(?:\s+[^\s\r\n`<>\[\]\(\){}@,.;:!?]+)*',
  caseSensitive: false,
);

String formatCompactCount(int value) {
  final absValue = value.abs();
  if (absValue < 1000) {
    return value.toString();
  }

  const thresholds = <int>[1000000000, 1000000, 1000];
  const suffixes = <String>['B', 'M', 'k'];

  for (var index = 0; index < thresholds.length; index += 1) {
    final threshold = thresholds[index];
    if (absValue >= threshold) {
      final compact = value / threshold;
      final formatted = compact >= 10
          ? compact.toStringAsFixed(0)
          : compact.toStringAsFixed(1);
      return '$formatted${suffixes[index]}';
    }
  }

  return value.toString();
}

String buildNotePreview(String text, {int maxLength = 120}) {
  final normalized = _normalizePreviewText(text);
  if (normalized.isEmpty) {
    return 'Sem conteúdo';
  }

  if (normalized.length <= maxLength) {
    return normalized;
  }

  return normalized.substring(0, maxLength).trimRight();
}

String _normalizePreviewText(String text) {
  var value = text;

  value = value.replaceAll(RegExp(r'```[\s\S]*?```'), ' ');
  value = value.replaceAllMapped(
    RegExp(r'!\[([^\]]*)\]\([^)]+\)'),
    (match) => match.group(1) ?? '',
  );
  value = value.replaceAllMapped(
    RegExp(r'\[([^\]]+)\]\([^)]+\)'),
    (match) => match.group(1) ?? '',
  );
  value = value.replaceAllMapped(
    RegExp(r'`([^`]+)`'),
    (match) => match.group(1) ?? '',
  );
  value = value.replaceAll(RegExp(r'^\s{0,3}#{1,6}\s*', multiLine: true), '');
  value = value.replaceAll(RegExp(r'^\s{0,3}>\s?', multiLine: true), '');
  value = value.replaceAll(
    RegExp(r'^\s*(?:[-*+]|\d+\.)\s+', multiLine: true),
    '',
  );
  value = value.replaceAll(RegExp(r'[*_~]'), '');
  value = value.replaceAll(RegExp(r'<[^>]+>'), ' ');
  value = value.replaceAll(RegExp(r'\s+'), ' ').trim();

  return value;
}

String formatShortDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString().padLeft(4, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

String formatCompactDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}
