part of '../pages/characters_section.dart';

String _sanitizeCharacterMarkdown(String data) {
  final withoutHtml = data.replaceAll(RegExp(r'<[^>]*>'), '');
  final rawLines = withoutHtml.split('\n');
  final sanitizedLines = <String>[];
  final atxHeadingPattern = RegExp(r'^\s{0,3}#{1,6}\s*');
  final setextHeadingPattern = RegExp(r'^\s{0,3}(=+|-+)\s*$');

  for (final line in rawLines) {
    final normalizedLine = line.replaceFirst(atxHeadingPattern, '');

    if (setextHeadingPattern.hasMatch(normalizedLine) &&
        sanitizedLines.isNotEmpty &&
        sanitizedLines.last.trim().isNotEmpty) {
      continue;
    }

    sanitizedLines.add(normalizedLine);
  }

  return sanitizedLines.join('\n');
}

String _formatBirthdayLabel(int day, int month) {
  final dayLabel = day.toString().padLeft(2, '0');
  final monthLabel = month.toString().padLeft(2, '0');
  return '$dayLabel/$monthLabel';
}

int _calculateAge(DateTime birthday) {
  final now = DateTime.now();
  var age = now.year - birthday.year;
  final hadBirthdayThisYear =
      now.month > birthday.month ||
      (now.month == birthday.month && now.day >= birthday.day);

  if (!hadBirthdayThisYear) {
    age -= 1;
  }

  return age;
}

const List<String> _monthLabels = <String>[
  'Jan',
  'Fev',
  'Mar',
  'Abr',
  'Mai',
  'Jun',
  'Jul',
  'Ago',
  'Set',
  'Out',
  'Nov',
  'Dez',
];

int _daysInMonth(int month) {
  return DateTime(2000, month + 1, 0).day;
}

String _formatHeightEditorValue(double heightCm, _HeightUnit unit) {
  switch (unit) {
    case _HeightUnit.centimeters:
      return heightCm.toStringAsFixed(0);
    case _HeightUnit.meters:
      return (heightCm / 100).toStringAsFixed(2);
    case _HeightUnit.feetAndInches:
      return _formatFeetAndInches(heightCm);
  }
}

double? _parseHeightToCm(String rawValue, _HeightUnit unit) {
  switch (unit) {
    case _HeightUnit.centimeters:
      final normalized = rawValue.replaceAll(',', '.').trim();
      final parsed = double.tryParse(normalized);

      if (parsed == null || parsed <= 0) {
        return null;
      }

      return parsed;
    case _HeightUnit.meters:
      final normalized = rawValue.replaceAll(',', '.').trim();
      final parsed = double.tryParse(normalized);

      if (parsed == null || parsed <= 0) {
        return null;
      }

      return parsed * 100;
    case _HeightUnit.feetAndInches:
      return _parseFeetAndInchesToCm(rawValue);
  }
}

String _formatWeightEditorValue(double weightKg, _WeightUnit unit) {
  switch (unit) {
    case _WeightUnit.kilograms:
      return _formatCompactDecimal(weightKg);
    case _WeightUnit.grams:
      return _formatCompactDecimal(weightKg * 1000);
    case _WeightUnit.pounds:
      return _formatCompactDecimal(weightKg * 2.2046226218);
    case _WeightUnit.ounces:
      return _formatCompactDecimal(weightKg * 35.27396195);
  }
}

double? _parseWeightToKg(String rawValue, _WeightUnit unit) {
  final normalized = rawValue.replaceAll(',', '.').trim();
  final parsed = double.tryParse(normalized);

  if (parsed == null || parsed <= 0) {
    return null;
  }

  return switch (unit) {
    _WeightUnit.kilograms => parsed,
    _WeightUnit.grams => parsed / 1000,
    _WeightUnit.pounds => parsed / 2.2046226218,
    _WeightUnit.ounces => parsed / 35.27396195,
  };
}

String _formatHeightLabel(double heightCm, _HeightUnit unit) {
  return _formatHeightEditorValue(heightCm, unit);
}

String _formatWeightLabel(double weightKg, _WeightUnit unit) {
  return _formatWeightEditorValue(weightKg, unit);
}

String _formatFeetAndInches(double heightCm) {
  final totalInches = heightCm / 2.54;
  var feet = (totalInches / 12).floor();
  var inches = (totalInches - (feet * 12)).round();

  if (inches == 12) {
    feet += 1;
    inches = 0;
  }

  return "$feet'${inches.toString().padLeft(2, '0')}\"";
}

double? _parseFeetAndInchesToCm(String rawValue) {
  final normalized = rawValue.trim().toLowerCase();

  if (normalized.isEmpty) {
    return null;
  }

  final primaryPattern = RegExp(
    r"""^\s*(\d+)\s*(?:'|ft)\s*(\d{1,2})?\s*(?:"|in)?\s*$""",
  );
  final primaryMatch = primaryPattern.firstMatch(normalized);

  if (primaryMatch != null) {
    final feet = int.tryParse(primaryMatch.group(1)!);
    final inches = int.tryParse(primaryMatch.group(2) ?? '0');

    if (feet == null || inches == null || inches >= 12) {
      return null;
    }

    return ((feet * 12) + inches) * 2.54;
  }

  final spacedPattern = RegExp(r'^\s*(\d+)\s+(\d{1,2})\s*$');
  final spacedMatch = spacedPattern.firstMatch(normalized);

  if (spacedMatch != null) {
    final feet = int.tryParse(spacedMatch.group(1)!);
    final inches = int.tryParse(spacedMatch.group(2)!);

    if (feet == null || inches == null || inches >= 12) {
      return null;
    }

    return ((feet * 12) + inches) * 2.54;
  }

  final plainNumber = double.tryParse(normalized.replaceAll(',', '.'));

  if (plainNumber == null || plainNumber <= 0) {
    return null;
  }

  if (plainNumber <= 9) {
    return plainNumber * 30.48;
  }

  return plainNumber * 2.54;
}

String _formatCompactDecimal(double value) {
  final hasFraction = value != value.roundToDouble();
  return hasFraction ? value.toStringAsFixed(1) : value.toStringAsFixed(0);
}

String _heightUnitCompactLabel(_HeightUnit unit) {
  return switch (unit) {
    _HeightUnit.centimeters => 'cm',
    _HeightUnit.meters => 'm',
    _HeightUnit.feetAndInches => 'ft/in',
  };
}

String _heightUnitMenuLabel(_HeightUnit unit) {
  return switch (unit) {
    _HeightUnit.centimeters => 'Centimetros (cm)',
    _HeightUnit.meters => 'Metros (m)',
    _HeightUnit.feetAndInches => 'Pes e polegadas (ft/in)',
  };
}

String _weightUnitCompactLabel(_WeightUnit unit) {
  return switch (unit) {
    _WeightUnit.kilograms => 'kg',
    _WeightUnit.grams => 'g',
    _WeightUnit.pounds => 'lb',
    _WeightUnit.ounces => 'oz',
  };
}

String _weightUnitMenuLabel(_WeightUnit unit) {
  return switch (unit) {
    _WeightUnit.kilograms => 'Quilogramas (kg)',
    _WeightUnit.grams => 'Gramas (g)',
    _WeightUnit.pounds => 'Libras (lb)',
    _WeightUnit.ounces => 'Oncas (oz)',
  };
}

String _formatDateTime(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString().padLeft(4, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');

  return '$day/$month/$year $hour:$minute';
}

String _formatRelativePhrase(DateTime value) {
  final difference = DateTime.now().difference(value);

  if (difference.inMinutes < 1) return 'ha menos de 1 minuto';
  if (difference.inMinutes < 60) {
    return 'ha ${_pluralizeCount(difference.inMinutes, 'minuto', 'minutos')}';
  }
  if (difference.inHours < 24) {
    return 'ha ${_pluralizeCount(difference.inHours, 'hora', 'horas')}';
  }
  if (difference.inDays < 7) {
    return 'ha ${_pluralizeCount(difference.inDays, 'dia', 'dias')}';
  }
  if (difference.inDays < 30) {
    return 'ha ${_pluralizeCount((difference.inDays / 7).floor(), 'semana', 'semanas')}';
  }
  if (difference.inDays < 365) {
    return 'ha ${_pluralizeCount((difference.inDays / 30).floor(), 'mes', 'meses')}';
  }
  return 'ha ${_pluralizeCount((difference.inDays / 365).floor(), 'ano', 'anos')}';
}

String _pluralizeCount(int value, String singular, String plural) {
  final normalizedValue = value < 1 ? 1 : value;
  return normalizedValue == 1 ? '1 $singular' : '$normalizedValue $plural';
}

_ZodiacSignData _zodiacSignFor(DateTime birthday) {
  final month = birthday.month;
  final day = birthday.day;

  if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
    return const _ZodiacSignData(
      name: 'Áries',
      symbol: '\u2648',
      description: '21/03 - 20/04\niniciativa, impulsividade, assertividade, competitividade, ação direta.',
    );
  }
  if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
    return const _ZodiacSignData(
      name: 'Touro',
      symbol: '\u2649',
      description:
          '21/04 - 20/05\nestabilidade, persistência, apego material, sensorialidade, resistência à mudança.',
    );
  }
  if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
    return const _ZodiacSignData(
      name: 'Gêmeos',
      symbol: '\u264A',
      description:
          '21/05 - 20/06\ncuriosidade, versatilidade, comunicação rápida, dispersão, adaptação constante.',
    );
  }
  if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
    return const _ZodiacSignData(
      name: 'Câncer',
      symbol: '\u264B',
      description:
          '21/06 - 22/07\nemotividade, proteção, apego ao passado, sensibilidade, vínculo familiar.',
    );
  }
  if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
    return const _ZodiacSignData(
      name: 'Leão',
      symbol: '\u264C',
      description:
          '23/07 - 22/08\nautoexpressão, orgulho, liderança, necessidade de reconhecimento, teatralidade.',
    );
  }
  if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
    return const _ZodiacSignData(
      name: 'Virgem',
      symbol: '\u264D',
      description:
          '23/08 - 22/09\nanálise, precisão, utilidade, crítica, foco em melhoria contínua.',
    );
  }
  if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
    return const _ZodiacSignData(
      name: 'Libra',
      symbol: '\u264E',
      description:
          '23/09 - 22/10\nequilíbrio, mediação, estética, sociabilidade, indecisão estratégica.',
    );
  }
  if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
    return const _ZodiacSignData(
      name: 'Escorpião',
      symbol: '\u264F',
      description:
          '23/10 - 21/11\nintensidade, controle, profundidade emocional, transformação, sigilo.',
    );
  }
  if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
    return const _ZodiacSignData(
      name: 'Sagitário',
      symbol: '\u2650',
      description:
          '22/11 - 21/12\nexpansão, idealismo, franqueza, busca por sentido, inquietação.',
    );
  }
  if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
    return const _ZodiacSignData(
      name: 'Capricórnio',
      symbol: '\u2651',
      description:
          '22/12 - 20/01\ndisciplina, responsabilidade, ambição estrutural, pragmatismo, contenção emocional.',
    );
  }
  if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
    return const _ZodiacSignData(
      name: 'Aquário',
      symbol: '\u2652',
      description:
          '21/01 - 18/02\ninovação, ruptura de padrões, pensamento coletivo, desapego, excentricidade funcional.',
    );
  }
  return const _ZodiacSignData(
    name: 'Peixes',
    symbol: '\u2653',
    description:
        '19/02 - 20/03\nimaginação, empatia, dissolução de limites, escapismo, sensibilidade difusa.',
  );
}
