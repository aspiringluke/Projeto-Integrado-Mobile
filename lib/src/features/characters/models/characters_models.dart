import 'dart:convert';

import 'package:flutter/material.dart';

import '../../projects/models/project_image_data.dart';

enum CharacterProfileFieldId {
  motto,
  alias,
  formationsAndOccupations,
  titles,
  weight,
  height,
  gender,
  sexuality,
  ethnicity,
  relevance,
}

enum CharacterComplexityDomain { geral, notas, psique, historia, design }

enum CharacterComplexityTier { contorno, periferico, orbital, nucleo }

class CharacterComplexityFieldDefinition {
  final String key;
  final CharacterComplexityDomain domain;
  final int unlockLevel;
  final String label;
  final String placeholder;

  const CharacterComplexityFieldDefinition({
    required this.key,
    required this.domain,
    required this.unlockLevel,
    required this.label,
    required this.placeholder,
  });
}

extension CharacterComplexityTierLevel on CharacterComplexityTier {
  int get level => switch (this) {
    CharacterComplexityTier.contorno => 1,
    CharacterComplexityTier.periferico => 2,
    CharacterComplexityTier.orbital => 3,
    CharacterComplexityTier.nucleo => 4,
  };
}

CharacterComplexityTier characterComplexityTierFromRelevanceTag(
  String relevanceTag,
) {
  switch (relevanceTag.trim().toLowerCase()) {
    case 'nucleo':
      return CharacterComplexityTier.nucleo;
    case 'orbital':
      return CharacterComplexityTier.orbital;
    case 'periferico':
      return CharacterComplexityTier.periferico;
    case 'contorno':
    default:
      return CharacterComplexityTier.contorno;
  }
}

List<CharacterComplexityFieldDefinition> resolveCharacterComplexityFields({
  required CharacterComplexityDomain domain,
  required CharacterComplexityTier tier,
  required Iterable<CharacterComplexityFieldDefinition> catalog,
}) {
  final level = tier.level;
  return catalog
      .where((field) => field.domain == domain && field.unlockLevel <= level)
      .toList(growable: false);
}

class CharacterCardData {
  final String name;
  final String alias;
  final String motto;
  final String formationsAndOccupations;
  final String titles;
  final String genderTag;
  final String sexualityTag;
  final String ethnicityTag;
  final String functionTag;
  final String relevanceTag;
  final Set<CharacterProfileFieldId> visibleProfileFields;
  final Color accent;
  final Color avatarColor;
  final ProjectImageData profileImage;
  final IconData icon;
  final int birthYear;
  final int birthDay;
  final int birthMonth;
  final double heightCm;
  final double weightKg;
  final String quote;
  final String synopsis;
  final Map<String, String> notebookComplexityValues;
  final int seed;

  const CharacterCardData({
    required this.name,
    required this.alias,
    this.motto = '',
    this.formationsAndOccupations = '',
    this.titles = '',
    this.genderTag = '',
    this.sexualityTag = '',
    this.ethnicityTag = '',
    this.functionTag = '',
    this.relevanceTag = '',
    this.visibleProfileFields = const <CharacterProfileFieldId>{},
    required this.accent,
    required this.avatarColor,
    this.profileImage = const ProjectImageData(),
    required this.icon,
    required this.birthYear,
    required this.birthDay,
    required this.birthMonth,
    required this.heightCm,
    required this.weightKg,
    required this.quote,
    required this.synopsis,
    this.notebookComplexityValues = const <String, String>{},
    required this.seed,
  });

  CharacterCardData copyWith({
    String? name,
    String? alias,
    String? motto,
    String? formationsAndOccupations,
    String? titles,
    String? genderTag,
    String? sexualityTag,
    String? ethnicityTag,
    String? functionTag,
    String? relevanceTag,
    Set<CharacterProfileFieldId>? visibleProfileFields,
    Color? accent,
    Color? avatarColor,
    ProjectImageData? profileImage,
    IconData? icon,
    int? birthYear,
    int? birthDay,
    int? birthMonth,
    double? heightCm,
    double? weightKg,
    String? quote,
    String? synopsis,
    Map<String, String>? notebookComplexityValues,
    int? seed,
  }) {
    return CharacterCardData(
      name: name ?? this.name,
      alias: alias ?? this.alias,
      motto: motto ?? this.motto,
      formationsAndOccupations:
          formationsAndOccupations ?? this.formationsAndOccupations,
      titles: titles ?? this.titles,
      genderTag: genderTag ?? this.genderTag,
      sexualityTag: sexualityTag ?? this.sexualityTag,
      ethnicityTag: ethnicityTag ?? this.ethnicityTag,
      functionTag: functionTag ?? this.functionTag,
      relevanceTag: relevanceTag ?? this.relevanceTag,
      visibleProfileFields: visibleProfileFields ?? this.visibleProfileFields,
      accent: accent ?? this.accent,
      avatarColor: avatarColor ?? this.avatarColor,
      profileImage: profileImage ?? this.profileImage,
      icon: icon ?? this.icon,
      birthYear: birthYear ?? this.birthYear,
      birthDay: birthDay ?? this.birthDay,
      birthMonth: birthMonth ?? this.birthMonth,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      quote: quote ?? this.quote,
      synopsis: synopsis ?? this.synopsis,
      notebookComplexityValues:
          notebookComplexityValues ?? this.notebookComplexityValues,
      seed: seed ?? this.seed,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'name': name,
      'alias': alias,
      'motto': motto,
      'formationsAndOccupations': formationsAndOccupations,
      'titles': titles,
      'genderTag': genderTag,
      'sexualityTag': sexualityTag,
      'ethnicityTag': ethnicityTag,
      'functionTag': functionTag,
      'relevanceTag': relevanceTag,
      'visibleProfileFields': visibleProfileFields
          .map((field) => field.name)
          .toList(growable: false),
      'accent': accent.toARGB32(),
      'avatarColor': avatarColor.toARGB32(),
      'profileImage': profileImage.toJson(),
      'icon': <String, Object?>{
        'codePoint': icon.codePoint,
        'fontFamily': icon.fontFamily,
        'fontPackage': icon.fontPackage,
        'matchTextDirection': icon.matchTextDirection,
      },
      'birthYear': birthYear,
      'birthDay': birthDay,
      'birthMonth': birthMonth,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'quote': quote,
      'synopsis': synopsis,
      'notebookComplexityValues': notebookComplexityValues,
      'seed': seed,
    };
  }

  factory CharacterCardData.fromJson(Map<String, Object?> map) {
    final rawVisibleFields = map['visibleProfileFields'];
    final rawNotebookValues = map['notebookComplexityValues'];
    final rawIcon = map['icon'];

    return CharacterCardData(
      name: map['name'] as String? ?? '',
      alias: map['alias'] as String? ?? '',
      motto: map['motto'] as String? ?? '',
      formationsAndOccupations:
          map['formationsAndOccupations'] as String? ?? '',
      titles: map['titles'] as String? ?? '',
      genderTag: map['genderTag'] as String? ?? '',
      sexualityTag: map['sexualityTag'] as String? ?? '',
      ethnicityTag: map['ethnicityTag'] as String? ?? '',
      functionTag: map['functionTag'] as String? ?? '',
      relevanceTag: map['relevanceTag'] as String? ?? '',
      visibleProfileFields: rawVisibleFields is List
          ? rawVisibleFields
                .whereType<String>()
                .map(_characterProfileFieldFromName)
                .whereType<CharacterProfileFieldId>()
                .toSet()
          : const <CharacterProfileFieldId>{},
      accent: Color(_readColorValue(map['accent']) ?? 0xFFDF6EB8),
      avatarColor: Color(_readColorValue(map['avatarColor']) ?? 0xFFDF6EB8),
      profileImage: _projectImageFromJson(map['profileImage']),
      icon: _iconDataFromJson(rawIcon),
      birthYear: _readIntValue(map['birthYear']) ?? 2000,
      birthDay: _readIntValue(map['birthDay']) ?? 1,
      birthMonth: _readIntValue(map['birthMonth']) ?? 1,
      heightCm: _readDoubleValue(map['heightCm']) ?? 0,
      weightKg: _readDoubleValue(map['weightKg']) ?? 0,
      quote: map['quote'] as String? ?? '',
      synopsis: map['synopsis'] as String? ?? '',
      notebookComplexityValues: rawNotebookValues is Map
          ? rawNotebookValues.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : const <String, String>{},
      seed: _readIntValue(map['seed']) ?? 0,
    );
  }
}

enum CharacterDateType { lastModified, lastAccessed, createdAt }

enum HeightUnit { centimeters, meters, feetAndInches }

enum WeightUnit { kilograms, grams, pounds, ounces }

class CharacterDateEntry {
  final String label;
  final DateTime value;

  const CharacterDateEntry({required this.label, required this.value});
}

class CharacterDateEntries {
  final CharacterDateEntry lastModified;
  final CharacterDateEntry lastAccessed;
  final CharacterDateEntry createdAt;

  const CharacterDateEntries({
    required this.lastModified,
    required this.lastAccessed,
    required this.createdAt,
  });

  factory CharacterDateEntries.fromSeed(int seed) {
    final normalizedSeed = seed.abs();
    final now = DateTime.now();
    final createdAt = now.subtract(
      Duration(
        days: 180 + (normalizedSeed % 250),
        hours: 3 + (normalizedSeed % 9),
      ),
    );
    final lastModified = now.subtract(
      Duration(
        days: 1 + (normalizedSeed % 15),
        hours: 3 + (normalizedSeed % 7),
      ),
    );
    final lastAccessed = now.subtract(
      Duration(
        hours: 4 + (normalizedSeed % 18),
        minutes: 8 + (normalizedSeed % 40),
      ),
    );

    return CharacterDateEntries(
      lastModified: CharacterDateEntry(
        label: '\u00DAltima modifica\u00E7\u00E3o',
        value: lastModified,
      ),
      lastAccessed: CharacterDateEntry(
        label: '\u00DAltimo acesso',
        value: lastAccessed,
      ),
      createdAt: CharacterDateEntry(label: 'Criado em', value: createdAt),
    );
  }

  factory CharacterDateEntries.fromValues({
    required DateTime createdAt,
    required DateTime lastModified,
    required DateTime lastAccessed,
  }) {
    return CharacterDateEntries(
      lastModified: CharacterDateEntry(
        label: '\u00DAltima modifica\u00E7\u00E3o',
        value: lastModified,
      ),
      lastAccessed: CharacterDateEntry(
        label: '\u00DAltimo acesso',
        value: lastAccessed,
      ),
      createdAt: CharacterDateEntry(label: 'Criado em', value: createdAt),
    );
  }

  CharacterDateEntry forType(CharacterDateType type) {
    return switch (type) {
      CharacterDateType.lastModified => lastModified,
      CharacterDateType.lastAccessed => lastAccessed,
      CharacterDateType.createdAt => createdAt,
    };
  }
}

class ZodiacSignData {
  final String name;
  final String symbol;
  final String description;

  const ZodiacSignData({
    required this.name,
    required this.symbol,
    required this.description,
  });
}

class CharacterListItem {
  final int? id;
  final int projectId;
  final String? projectTitle;
  CharacterCardData data;
  bool isPinned;
  int unpinnedIndex;
  DateTime createdAt;
  DateTime lastModified;
  DateTime lastAccessed;

  CharacterListItem({
    this.id,
    required this.projectId,
    this.projectTitle,
    required this.data,
    required this.unpinnedIndex,
    this.isPinned = false,
    required this.createdAt,
    required this.lastModified,
    required this.lastAccessed,
  });

  CharacterListItem copyWith({
    int? id,
    int? projectId,
    String? projectTitle,
    CharacterCardData? data,
    bool? isPinned,
    int? unpinnedIndex,
    DateTime? createdAt,
    DateTime? lastModified,
    DateTime? lastAccessed,
  }) {
    return CharacterListItem(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectTitle: projectTitle ?? this.projectTitle,
      data: data ?? this.data,
      isPinned: isPinned ?? this.isPinned,
      unpinnedIndex: unpinnedIndex ?? this.unpinnedIndex,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }
}

CharacterProfileFieldId? _characterProfileFieldFromName(String name) {
  for (final field in CharacterProfileFieldId.values) {
    if (field.name == name) {
      return field;
    }
  }

  return null;
}

IconData _iconDataFromJson(Object? value) {
  if (value is! Map) {
    return Icons.person_rounded;
  }

  final codePoint = _readIntValue(value['codePoint']);
  if (codePoint == null) {
    return Icons.person_rounded;
  }

  return IconData(
    codePoint,
    fontFamily: value['fontFamily'] as String?,
    fontPackage: value['fontPackage'] as String?,
    matchTextDirection: value['matchTextDirection'] == true,
  );
}

int? _readColorValue(Object? value) {
  if (value is int) {
    return value;
  }

  if (value is String) {
    return int.tryParse(value);
  }

  return null;
}

int? _readIntValue(Object? value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value);
  }

  return null;
}

double? _readDoubleValue(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value);
  }

  return null;
}

ProjectImageData _projectImageFromJson(Object? value) {
  if (value is Map<String, Object?>) {
    return ProjectImageData.fromJson(value);
  }

  if (value is Map) {
    return ProjectImageData.fromJson(
      value.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  return const ProjectImageData();
}

String encodeCharacterPayload(CharacterCardData data) {
  return jsonEncode(data.toJson());
}

CharacterCardData decodeCharacterPayload(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return CharacterCardData(
      name: '',
      alias: '',
      accent: const Color(0xFFDF6EB8),
      avatarColor: const Color(0xFFDF6EB8),
      icon: Icons.person_rounded,
      birthYear: 2000,
      birthDay: 1,
      birthMonth: 1,
      heightCm: 0,
      weightKg: 0,
      quote: '',
      synopsis: '',
      seed: 0,
    );
  }

  final decoded = jsonDecode(raw);
  if (decoded is Map<String, Object?>) {
    return CharacterCardData.fromJson(decoded);
  }

  if (decoded is Map) {
    return CharacterCardData.fromJson(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  return CharacterCardData(
    name: '',
    alias: '',
    accent: const Color(0xFFDF6EB8),
    avatarColor: const Color(0xFFDF6EB8),
    icon: Icons.person_rounded,
    birthYear: 2000,
    birthDay: 1,
    birthMonth: 1,
    heightCm: 0,
    weightKg: 0,
    quote: '',
    synopsis: '',
    seed: 0,
  );
}
