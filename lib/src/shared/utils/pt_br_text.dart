String ptBrPlural(
  int count, {
  required String singular,
  required String plural,
}) {
  return count == 1 ? singular : plural;
}

String ptBrCount(
  int count, {
  required String singular,
  required String plural,
  String Function(int count)? formatNumber,
}) {
  final number = formatNumber?.call(count) ?? count.toString();
  return '$number ${ptBrPlural(count, singular: singular, plural: plural)}';
}

String ptBrCountSummary(Iterable<String?> parts) {
  return parts
      .whereType<String>()
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .join(', ');
}
