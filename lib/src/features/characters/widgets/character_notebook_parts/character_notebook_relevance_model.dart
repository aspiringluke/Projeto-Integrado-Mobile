part of '../character_notebook_page.dart';

class _RelevanceParameter {
  final String id;
  final String symbol;
  final String name;
  final String description;
  final double weight;

  const _RelevanceParameter({
    required this.id,
    required this.symbol,
    required this.name,
    required this.description,
    required this.weight,
  });

  _RelevanceParameter copyWith({
    String? symbol,
    String? name,
    String? description,
    double? weight,
  }) {
    return _RelevanceParameter(
      id: id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      description: description ?? this.description,
      weight: weight ?? this.weight,
    );
  }
}

class _RelevanceCategory {
  final String name;
  final double min;
  final double max;
  final String description;
  final Color color;

  const _RelevanceCategory({
    required this.name,
    required this.min,
    required this.max,
    required this.description,
    required this.color,
  });
}

class _RelevanceParameterBundle {
  final List<_RelevanceParameter> parameters;
  final Map<String, double> values;
  final Map<String, double> weights;

  const _RelevanceParameterBundle({
    required this.parameters,
    required this.values,
    required this.weights,
  });

  factory _RelevanceParameterBundle.defaults() {
    final parameters = _defaultRelevanceParameters();
    return _RelevanceParameterBundle(
      parameters: parameters,
      values: {for (final parameter in parameters) parameter.id: 0},
      weights: {
        for (final parameter in parameters) parameter.id: parameter.weight,
      },
    );
  }

  List<_RelevanceCategory> get categories => _defaultRelevanceCategories();

  double get score => _calculateScore();

  _RelevanceCategory categoryForScore(double score) {
    return categories.firstWhere(
      (category) => score >= category.min && score <= category.max,
      orElse: () => categories.last,
    );
  }

  _RelevanceParameterBundle copyWith({
    Map<String, double>? values,
    Map<String, double>? weights,
    List<_RelevanceParameter>? parameters,
  }) {
    return _RelevanceParameterBundle(
      parameters: parameters ?? this.parameters,
      values: values ?? this.values,
      weights: weights ?? this.weights,
    );
  }

  double _calculateScore() {
    var weightedTotal = 0.0;
    var weightTotal = 0.0;
    for (final parameter in parameters) {
      final weight = weights[parameter.id] ?? parameter.weight;
      weightedTotal += (values[parameter.id] ?? 0) * weight;
      weightTotal += weight;
    }
    if (weightTotal <= 0) return 0;
    return (weightedTotal / weightTotal).clamp(0, 10);
  }
}

List<_RelevanceParameter> _defaultRelevanceParameters() {
  return const [
    _RelevanceParameter(
      id: 'causal',
      symbol: 'Cc',
      name: 'Centralidade causal',
      description:
          'Baixo: reage aos eventos. Alto: cria viradas, escolhas vitais e consequências irreversíveis.',
      weight: 0.45,
    ),
    _RelevanceParameter(
      id: 'relational',
      symbol: 'Dr',
      name: 'Densidade relacional',
      description:
          'Baixo: poucas conexões. Alto: conecta grupos, move relações e irradia influência no elenco.',
      weight: 0.25,
    ),
    _RelevanceParameter(
      id: 'thematic',
      symbol: 'Ct',
      name: 'Carga temática',
      description:
          'Baixo: pouca tese própria. Alto: encarna conflitos, ideias e perguntas centrais da obra.',
      weight: 0.15,
    ),
    _RelevanceParameter(
      id: 'presence',
      symbol: 'Pd',
      name: 'Presença discursiva',
      description:
          'Baixo: aparece pouco. Alto: ocupa cenas, falas, páginas ou atenção recorrente.',
      weight: 0.10,
    ),
    _RelevanceParameter(
      id: 'mutability',
      symbol: 'Me',
      name: 'Mutabilidade estrutural',
      description:
          'Baixo: permanece estável. Alto: muda psicologicamente ou reposiciona sua função na trama.',
      weight: 0.05,
    ),
  ];
}

_RelevanceParameter? _defaultRelevanceParameterById(String id) {
  for (final parameter in _defaultRelevanceParameters()) {
    if (parameter.id == id) {
      return parameter;
    }
  }
  return null;
}

List<_RelevanceCategory> _defaultRelevanceCategories() {
  return const [
    _RelevanceCategory(
      name: 'Contorno',
      min: 0,
      max: 1.9,
      description:
          'Existem apenas para enriquecer o mundo, dar cor ou construir o contexto de algum objeto narrativo (como familiares ou habitantes locais), com pouco ou nenhum impacto no avanço da trama.',
      color: Color(0xFF8E838B),
    ),
    _RelevanceCategory(
      name: 'Periférico',
      min: 2,
      max: 4.9,
      description:
          'Têm momentos de importância pontual. Brilham ou influenciam a história em eventos específicos, mas permanecem omissos ou em segundo plano na maior parte do tempo.',
      color: Color(0xFF8EAFF1),
    ),
    _RelevanceCategory(
      name: 'Orbital',
      min: 5,
      max: 7.9,
      description:
          'Personagens orbitais têm grande significância para algo importante para a narrativa (como outros personagens de núcleo). A história não é sobre eles, mas mesmo assim têm grande peso em seu direcionamento.',
      color: Color(0xFFDF9C53),
    ),
    _RelevanceCategory(
      name: 'Núcleo',
      min: 8,
      max: 10,
      description:
          'Personagens que fazem a narrativa girar ao redor deles, movendo a trama central em conjunto. A história comumente é sobre eles.',
      color: Color(0xFFDF6EB8),
    ),
  ];
}

const String _relevanceStoragePrefix = 'relevance::';
const String _relevanceStorageOrderKey = '${_relevanceStoragePrefix}order';
const String _relevanceStorageModeKey = '${_relevanceStoragePrefix}mode';

String _relevanceStorageKey(String parameterId, String field) {
  return '$_relevanceStoragePrefix$parameterId::$field';
}

String _relevanceMonogram(String name, {String fallback = '?'}) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .take(2)
      .toList(growable: false);
  if (words.isEmpty) {
    return fallback;
  }
  if (words.length == 1) {
    final letter = words.first[0];
    return '${letter.toUpperCase()}${letter.toLowerCase()}';
  }

  final first = words.first[0];
  final second = words[1][0];
  return '${first.toUpperCase()}${second.toLowerCase()}';
}

_RelevanceEditorMode _readStoredRelevanceMode(
  Map<String, String> notebookValues,
) {
  return switch (notebookValues[_relevanceStorageModeKey]) {
    'simple' => _RelevanceEditorMode.simple,
    _ => _RelevanceEditorMode.advanced,
  };
}

_RelevanceParameterBundle _readStoredRelevanceBundle(
  Map<String, String> notebookValues, {
  String fallbackTag = '',
}) {
  final rawOrder = notebookValues[_relevanceStorageOrderKey];
  final orderedIds = rawOrder
      ?.split('|')
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
  if (orderedIds == null || orderedIds.isEmpty) {
    return _defaultRelevanceBundleForTag(fallbackTag);
  }

  final defaults = {
    for (final parameter in _defaultRelevanceParameters())
      parameter.id: parameter,
  };
  final parameters = <_RelevanceParameter>[];
  final values = <String, double>{};
  final weights = <String, double>{};

  for (var index = 0; index < orderedIds.length; index += 1) {
    final id = orderedIds[index];
    final fallback = defaults[id];
    final parameter = _RelevanceParameter(
      id: id,
      symbol:
          notebookValues[_relevanceStorageKey(id, 'symbol')] ??
          fallback?.symbol ??
          'P${index + 1}',
      name:
          notebookValues[_relevanceStorageKey(id, 'name')] ??
          fallback?.name ??
          'Novo parâmetro',
      description:
          notebookValues[_relevanceStorageKey(id, 'description')] ??
          fallback?.description ??
          'Descreva o critério narrativo.',
      weight:
          (double.tryParse(
                    notebookValues[_relevanceStorageKey(id, 'weight')] ?? '',
                  ) ??
                  fallback?.weight ??
                  0.10)
              .clamp(0.0, 1.0)
              .toDouble(),
    );
    parameters.add(parameter);
    values[id] =
        (double.tryParse(
                  notebookValues[_relevanceStorageKey(id, 'value')] ?? '',
                ) ??
                0.0)
            .clamp(0.0, 10.0)
            .toDouble();
    weights[id] = parameter.weight;
  }

  return _RelevanceParameterBundle(
    parameters: parameters,
    values: values,
    weights: _normalizeRelevanceWeights(
      parameters: parameters,
      weights: weights,
    ),
  );
}

_RelevanceParameterBundle _defaultRelevanceBundleForTag(String relevanceTag) {
  final parameters = _defaultRelevanceParameters();
  final normalizedTag = relevanceTag
      .trim()
      .toLowerCase()
      .replaceAll('ú', 'u')
      .replaceAll('é', 'e');
  final seededScore = switch (normalizedTag) {
    'nucleo' => 9.0,
    'orbital' => 6.5,
    'periferico' => 3.5,
    'contorno' => 1.0,
    _ => 0.0,
  };
  return _RelevanceParameterBundle(
    parameters: parameters,
    values: {for (final parameter in parameters) parameter.id: seededScore},
    weights: {
      for (final parameter in parameters) parameter.id: parameter.weight,
    },
  );
}

Map<String, String> _storeRelevanceBundle(
  Map<String, String> currentValues,
  _RelevanceParameterBundle bundle, {
  required _RelevanceEditorMode mode,
}) {
  final nextValues = Map<String, String>.from(currentValues)
    ..removeWhere((key, _) => key.startsWith(_relevanceStoragePrefix));
  nextValues[_relevanceStorageModeKey] = switch (mode) {
    _RelevanceEditorMode.simple => 'simple',
    _RelevanceEditorMode.advanced => 'advanced',
  };
  nextValues[_relevanceStorageOrderKey] = bundle.parameters
      .map((parameter) => parameter.id)
      .join('|');

  for (final parameter in bundle.parameters) {
    nextValues[_relevanceStorageKey(parameter.id, 'symbol')] = parameter.symbol;
    nextValues[_relevanceStorageKey(parameter.id, 'name')] = parameter.name;
    nextValues[_relevanceStorageKey(parameter.id, 'description')] =
        parameter.description;
    nextValues[_relevanceStorageKey(parameter.id, 'value')] =
        (bundle.values[parameter.id] ?? 0).toStringAsFixed(1);
    nextValues[_relevanceStorageKey(
      parameter.id,
      'weight',
    )] = ((bundle.weights[parameter.id] ?? parameter.weight).clamp(
      0.0,
      1.0,
    )).toString();
  }

  return nextValues;
}

Map<String, double> _redistributeRelevanceWeights({
  required List<_RelevanceParameter> parameters,
  required Map<String, double> weights,
  required String changedId,
  required double requestedWeight,
}) {
  const totalWeightUnits = 20;
  final ids = [for (final parameter in parameters) parameter.id];
  final current = {
    for (final parameter in parameters)
      parameter.id: weights[parameter.id] ?? parameter.weight,
  };
  final changedUnits = (requestedWeight.clamp(0.0, 1.0) * totalWeightUnits)
      .round()
      .clamp(0, totalWeightUnits);
  final remainingUnits = totalWeightUnits - changedUnits;
  final otherIds = ids.where((id) => id != changedId).toList();
  final otherCurrentTotal = otherIds.fold<double>(
    0,
    (total, id) => total + (current[id] ?? 0),
  );

  final adjustedUnits = <String, int>{changedId: changedUnits};
  if (otherIds.isEmpty) {
    return {changedId: changedUnits / totalWeightUnits};
  }

  if (remainingUnits == 0) {
    for (final id in otherIds) {
      adjustedUnits[id] = 0;
    }
    return {
      for (final entry in adjustedUnits.entries)
        entry.key: entry.value / totalWeightUnits,
    };
  }

  if (otherCurrentTotal <= 0) {
    final baseUnits = remainingUnits ~/ otherIds.length;
    final leftoverUnits = remainingUnits % otherIds.length;
    for (var index = 0; index < otherIds.length; index += 1) {
      adjustedUnits[otherIds[index]] =
          baseUnits + (index < leftoverUnits ? 1 : 0);
    }
    return {
      for (final entry in adjustedUnits.entries)
        entry.key: entry.value / totalWeightUnits,
    };
  }

  final quotas = <String, double>{};
  var allocatedUnits = changedUnits;
  for (final id in otherIds) {
    final quota = ((current[id] ?? 0) / otherCurrentTotal) * remainingUnits;
    quotas[id] = quota;
    final units = quota.floor();
    adjustedUnits[id] = units;
    allocatedUnits += units;
  }

  final sortedRemainders = otherIds.toList()
    ..sort(
      (a, b) => ((quotas[b] ?? 0) - (quotas[b] ?? 0).floor()).compareTo(
        (quotas[a] ?? 0) - (quotas[a] ?? 0).floor(),
      ),
    );

  var remainderIndex = 0;
  while (allocatedUnits < totalWeightUnits) {
    final id = sortedRemainders[remainderIndex % sortedRemainders.length];
    adjustedUnits[id] = (adjustedUnits[id] ?? 0) + 1;
    allocatedUnits += 1;
    remainderIndex += 1;
  }

  return {
    for (final entry in adjustedUnits.entries)
      entry.key: entry.value / totalWeightUnits,
  };
}

Map<String, double> _normalizeRelevanceWeights({
  required List<_RelevanceParameter> parameters,
  required Map<String, double> weights,
}) {
  if (parameters.isEmpty) {
    return {};
  }

  final total = parameters.fold<double>(
    0,
    (sum, parameter) => sum + (weights[parameter.id] ?? parameter.weight),
  );

  if (total <= 0) {
    final equalWeight = 1 / parameters.length;
    return {for (final parameter in parameters) parameter.id: equalWeight};
  }

  return {
    for (final parameter in parameters)
      parameter.id: (weights[parameter.id] ?? parameter.weight) / total,
  };
}

_RelevanceParameter _createBlankRelevanceParameter(
  List<_RelevanceParameter> parameters,
) {
  var index = parameters.length + 1;
  var id = 'custom_$index';
  while (parameters.any((parameter) => parameter.id == id)) {
    index += 1;
    id = 'custom_$index';
  }

  return _RelevanceParameter(
    id: id,
    symbol: 'P$index',
    name: 'Novo parâmetro',
    description: 'Descreva o critério narrativo.',
    weight: 0.10,
  );
}

List<ZodiacSignData> _allZodiacSigns() {
  return [
    DateTime(2000, 3, 21),
    DateTime(2000, 4, 20),
    DateTime(2000, 5, 21),
    DateTime(2000, 6, 21),
    DateTime(2000, 7, 23),
    DateTime(2000, 8, 23),
    DateTime(2000, 9, 23),
    DateTime(2000, 10, 23),
    DateTime(2000, 11, 22),
    DateTime(2000, 12, 22),
    DateTime(2000, 1, 20),
    DateTime(2000, 2, 19),
  ].map(zodiacSignFor).toList(growable: false);
}

DateTime _randomBirthdayForSign(ZodiacSignData signData) {
  final dates = <DateTime>[];
  for (var month = 1; month <= 12; month += 1) {
    for (var day = 1; day <= daysInMonth(month); day += 1) {
      final date = DateTime(2000, month, day);
      if (zodiacSignFor(date).symbol == signData.symbol) {
        dates.add(date);
      }
    }
  }
  return dates[Random().nextInt(dates.length)];
}

String _tagKindTitle(_TagKind kind) {
  return switch (kind) {
    _TagKind.gender => 'Gênero',
    _TagKind.sexuality => 'Sexualidade',
    _TagKind.ethnicity => 'Etnia',
    _TagKind.function => 'Função',
  };
}

String _tagKindDescription(_TagKind kind) {
  return switch (kind) {
    _TagKind.gender => 'Escolha uma opção para o gênero do personagem.',
    _TagKind.sexuality => 'Escolha uma opção para a sexualidade do personagem.',
    _TagKind.ethnicity => 'Escolha uma opção para a etnia do personagem.',
    _TagKind.function => 'Escolha a função dramática principal do personagem.',
  };
}

IconData _tagKindIcon(_TagKind kind) {
  return switch (kind) {
    _TagKind.gender => Icons.wc_rounded,
    _TagKind.sexuality => Icons.favorite_border_rounded,
    _TagKind.ethnicity => Icons.groups_2_outlined,
    _TagKind.function => Icons.theater_comedy_outlined,
  };
}

Color _darkenCharacterDialogColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0, 1)).toColor();
}

BoxDecoration _buildCharacterDialogSurfaceDecoration({
  required Color accentColor,
  required bool selected,
  required BorderRadius borderRadius,
}) {
  return BoxDecoration(
    color: Colors.white.withValues(alpha: selected ? 0.62 : 0.54),
    borderRadius: borderRadius,
    border: Border.all(
      color: selected
          ? accentColor.withValues(alpha: 0.28)
          : Colors.white.withValues(alpha: 0.82),
      width: 0.8,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );
}
