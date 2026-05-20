import '../models/characters_models.dart';

const String _relevanceStoragePrefix = 'relevance::';

double characterRelevanceScore(CharacterCardData data) {
  final values = <String, double>{};
  final weights = <String, double>{};

  for (final entry in data.notebookComplexityValues.entries) {
    if (!entry.key.startsWith(_relevanceStoragePrefix)) {
      continue;
    }

    final parts = entry.key.split('::');
    if (parts.length != 3) {
      continue;
    }

    final id = parts[1];
    final field = parts[2];
    final value = double.tryParse(entry.value);
    if (value == null) {
      continue;
    }

    if (field == 'value') {
      values[id] = value.clamp(0.0, 10.0).toDouble();
    } else if (field == 'weight') {
      weights[id] = value.clamp(0.0, 1.0).toDouble();
    }
  }

  if (values.isEmpty) {
    return _defaultScoreForRelevanceTag(data.relevanceTag);
  }

  var weightedTotal = 0.0;
  var weightTotal = 0.0;
  for (final entry in values.entries) {
    final weight = weights[entry.key] ?? 1.0;
    weightedTotal += entry.value * weight;
    weightTotal += weight;
  }

  if (weightTotal <= 0) {
    return _defaultScoreForRelevanceTag(data.relevanceTag);
  }

  return (weightedTotal / weightTotal).clamp(0.0, 10.0).toDouble();
}

double _defaultScoreForRelevanceTag(String tag) {
  return switch (_normalizeRelevanceTag(tag)) {
    'nucleo' => 9.0,
    'orbital' => 6.5,
    'periferico' => 3.5,
    'contorno' => 1.0,
    _ => 0.0,
  };
}

String _normalizeRelevanceTag(String tag) {
  return tag
      .trim()
      .toLowerCase()
      .replaceAll('ú', 'u')
      .replaceAll('é', 'e')
      .replaceAll('ê', 'e');
}
