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
          notebookComplexityValues ?? this.notebookComplexityValues ?? const <String, String>{},
      seed: seed ?? this.seed,
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
        label: 'Última modificação',
        value: lastModified,
      ),
      lastAccessed: CharacterDateEntry(
        label: 'Último acesso',
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
  CharacterCardData data;
  bool isPinned = false;
  int unpinnedIndex;

  CharacterListItem({required this.data, required this.unpinnedIndex});
}
