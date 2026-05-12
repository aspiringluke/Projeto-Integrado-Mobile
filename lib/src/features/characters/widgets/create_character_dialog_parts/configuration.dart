part of '../create_character_dialog.dart';

enum _CharacterTagKind { gender, sexuality, ethnicity, function }

class _RelevanceParameterConfig {
  final String id;
  final String symbol;
  final String name;
  final String description;
  final double weight;

  const _RelevanceParameterConfig({
    required this.id,
    required this.symbol,
    required this.name,
    required this.description,
    required this.weight,
  });

  _RelevanceParameterConfig copyWith({
    String? name,
    String? description,
    double? weight,
  }) {
    return _RelevanceParameterConfig(
      id: id,
      symbol: symbol,
      name: name ?? this.name,
      description: description ?? this.description,
      weight: weight ?? this.weight,
    );
  }
}

class _RelevanceCategoryConfig {
  final String name;
  final double min;
  final double max;
  final String description;
  final Color color;

  const _RelevanceCategoryConfig({
    required this.name,
    required this.min,
    required this.max,
    required this.description,
    required this.color,
  });
}

class _RelevanceSelectionResult {
  final Map<String, double> values;
  final Map<String, double> weights;
  final List<_RelevanceParameterConfig> parameters;
  final String categoryName;

  const _RelevanceSelectionResult({
    required this.values,
    required this.weights,
    required this.parameters,
    required this.categoryName,
  });
}

List<_RelevanceParameterConfig> _defaultRelevanceParameters() {
  return const [
    _RelevanceParameterConfig(
      id: 'causal',
      symbol: 'Cc',
      name: 'Centralidade causal',
      description:
          'Baixo: reage aos eventos. Alto: cria viradas, escolhas vitais e consequencias irreversiveis.',
      weight: 0.45,
    ),
    _RelevanceParameterConfig(
      id: 'relational',
      symbol: 'Dr',
      name: 'Densidade relacional',
      description:
          'Baixo: poucas conexoes. Alto: conecta grupos, move relacoes e irradia influencia no elenco.',
      weight: 0.25,
    ),
    _RelevanceParameterConfig(
      id: 'thematic',
      symbol: 'Ct',
      name: 'Carga tematica',
      description:
          'Baixo: pouca tese propria. Alto: encarna conflitos, ideias e perguntas centrais da obra.',
      weight: 0.15,
    ),
    _RelevanceParameterConfig(
      id: 'presence',
      symbol: 'Pd',
      name: 'Presenca discursiva',
      description:
          'Baixo: aparece pouco. Alto: ocupa cenas, falas, paginas ou atencao recorrente.',
      weight: 0.10,
    ),
    _RelevanceParameterConfig(
      id: 'mutability',
      symbol: 'Me',
      name: 'Mutabilidade estrutural',
      description:
          'Baixo: permanece estável. Alto: muda psicologicamente ou reposiciona sua função na trama.',
      weight: 0.05,
    ),
  ];
}

List<_RelevanceCategoryConfig> _defaultRelevanceCategories() {
  return const [
    _RelevanceCategoryConfig(
      name: 'Contorno',
      min: 0,
      max: 1.9,
      description: 'Figura passiva ou cenografica.',
      color: Color(0xFF8E838B),
    ),
    _RelevanceCategoryConfig(
      name: 'Periferico',
      min: 2,
      max: 4.9,
      description: 'Agente funcional, gatilho ou catalisador.',
      color: Color(0xFF8EAFF1),
    ),
    _RelevanceCategoryConfig(
      name: 'Orbital',
      min: 5,
      max: 7.9,
      description: 'Sustentação crítica ao redor do núcleo.',
      color: Color(0xFFDF9C53),
    ),
    _RelevanceCategoryConfig(
      name: 'Núcleo',
      min: 8,
      max: 10,
      description: 'Entidade vital da espinha causal da historia.',
      color: Color(0xFFDF6EB8),
    ),
  ];
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

List<ProjectTagData> _seedCharacterTags(_CharacterTagKind kind) {
  final labels = switch (kind) {
    _CharacterTagKind.gender => const ['Masculino', 'Feminino', 'N/A'],
    _CharacterTagKind.sexuality => const [
      'Assexual',
      'Heterossexual',
      'Homossexual',
      'Bissexual',
      'Pansexual',
    ],
    _CharacterTagKind.ethnicity => const ['Branco', 'Negro', 'Pardo'],
    _CharacterTagKind.function => const [
      'Vilao',
      'Heroi',
      'Anti-heroi',
      'Anti-vilao',
    ],
  };

  return [
    for (var i = 0; i < labels.length; i += 1)
      ProjectTagData(label: labels[i], color: _tagCategoryColor(kind)),
  ];
}

Color _tagCategoryColor(_CharacterTagKind kind) {
  return switch (kind) {
    _CharacterTagKind.gender => projectTagColorAt(0),
    _CharacterTagKind.sexuality => projectTagColorAt(1),
    _CharacterTagKind.ethnicity => projectTagColorAt(2),
    _CharacterTagKind.function => projectTagColorAt(3),
  };
}

String _tagKindTitle(_CharacterTagKind kind) {
  return switch (kind) {
    _CharacterTagKind.gender => 'Gênero',
    _CharacterTagKind.sexuality => 'Sexualidade',
    _CharacterTagKind.ethnicity => 'Etnia',
    _CharacterTagKind.function => 'Função',
  };
}

String _tagKindDescription(_CharacterTagKind kind) {
  return switch (kind) {
    _CharacterTagKind.gender =>
      'Escolha uma opção existente ou adicione uma nova para o gênero do personagem.',
    _CharacterTagKind.sexuality =>
      'Escolha uma opção existente ou adicione uma nova para a sexualidade do personagem.',
    _CharacterTagKind.ethnicity =>
      'Escolha uma opção existente ou adicione uma nova para a etnia do personagem.',
    _CharacterTagKind.function =>
      'Escolha a função dramática principal do personagem.',
  };
}

IconData _tagKindIcon(_CharacterTagKind kind) {
  return switch (kind) {
    _CharacterTagKind.gender => Icons.wc_rounded,
    _CharacterTagKind.sexuality => Icons.favorite_border_rounded,
    _CharacterTagKind.ethnicity => Icons.groups_2_outlined,
    _CharacterTagKind.function => Icons.theater_comedy_outlined,
  };
}
