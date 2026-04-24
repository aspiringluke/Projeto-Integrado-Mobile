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

class CharacterCardData {
  final String name;
  final String alias;
  final String motto;
  final String formationsAndOccupations;
  final String titles;
  final String genderTag;
  final String sexualityTag;
  final String ethnicityTag;
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
    required this.seed,
  });
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
        label: 'Ultima modificacao',
        value: lastModified,
      ),
      lastAccessed: CharacterDateEntry(
        label: 'Ultimo acesso',
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
  final CharacterCardData data;
  bool isPinned = false;
  int unpinnedIndex;

  CharacterListItem({required this.data, required this.unpinnedIndex});
}
