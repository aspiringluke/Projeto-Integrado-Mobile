String normalizeSearchText(String input) {
  final collapsed = input.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (collapsed.isEmpty) return '';

  final buffer = StringBuffer();
  for (final rune in collapsed.runes) {
    final normalized = _latinFoldMap[String.fromCharCode(rune)];
    buffer.write(normalized ?? String.fromCharCode(rune));
  }

  return buffer.toString().toLowerCase();
}

const Map<String, String> _latinFoldMap = <String, String>{
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'Á': 'a',
  'À': 'a',
  'Â': 'a',
  'Ã': 'a',
  'Ä': 'a',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'É': 'e',
  'È': 'e',
  'Ê': 'e',
  'Ë': 'e',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ï': 'i',
  'Í': 'i',
  'Ì': 'i',
  'Î': 'i',
  'Ï': 'i',
  'ó': 'o',
  'ò': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'Ó': 'o',
  'Ò': 'o',
  'Ô': 'o',
  'Õ': 'o',
  'Ö': 'o',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'Ú': 'u',
  'Ù': 'u',
  'Û': 'u',
  'Ü': 'u',
  'ç': 'c',
  'Ç': 'c',
  'ñ': 'n',
  'Ñ': 'n',
};
