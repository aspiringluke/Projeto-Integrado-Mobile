part of '../pages/characters_section.dart';

class _CharacterCardData {
  final String name;
  final String alias;
  final Color accent;
  final Color avatarColor;
  final IconData icon;
  final int birthYear;
  final int birthDay;
  final int birthMonth;
  final double heightCm;
  final double weightKg;
  final String quote;
  final String synopsis;
  final int seed;

  const _CharacterCardData({
    required this.name,
    required this.alias,
    required this.accent,
    required this.avatarColor,
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

enum _CharacterDateType { lastModified, lastAccessed, createdAt }

enum _HeightUnit { centimeters, meters, feetAndInches }

enum _WeightUnit { kilograms, grams, pounds, ounces }

class _CharacterDateEntry {
  final String label;
  final DateTime value;

  const _CharacterDateEntry({
    required this.label,
    required this.value,
  });
}

class _CharacterDateEntries {
  final _CharacterDateEntry lastModified;
  final _CharacterDateEntry lastAccessed;
  final _CharacterDateEntry createdAt;

  const _CharacterDateEntries({
    required this.lastModified,
    required this.lastAccessed,
    required this.createdAt,
  });

  factory _CharacterDateEntries.fromSeed(int seed) {
    final normalizedSeed = seed.abs();
    final now = DateTime.now();
    final createdAt = now.subtract(
      Duration(days: 180 + (normalizedSeed % 250), hours: 3 + (normalizedSeed % 9)),
    );
    final lastModified = now.subtract(
      Duration(days: 1 + (normalizedSeed % 15), hours: 3 + (normalizedSeed % 7)),
    );
    final lastAccessed = now.subtract(
      Duration(hours: 4 + (normalizedSeed % 18), minutes: 8 + (normalizedSeed % 40)),
    );

    return _CharacterDateEntries(
      lastModified: _CharacterDateEntry(
        label: 'Ultima modificacao',
        value: lastModified,
      ),
      lastAccessed: _CharacterDateEntry(
        label: 'Ultimo acesso',
        value: lastAccessed,
      ),
      createdAt: _CharacterDateEntry(
        label: 'Criado em',
        value: createdAt,
      ),
    );
  }

  _CharacterDateEntry forType(_CharacterDateType type) {
    return switch (type) {
      _CharacterDateType.lastModified => lastModified,
      _CharacterDateType.lastAccessed => lastAccessed,
      _CharacterDateType.createdAt => createdAt,
    };
  }
}

class _ZodiacSignData {
  final String name;
  final String symbol;
  final String description;

  const _ZodiacSignData({
    required this.name,
    required this.symbol,
    required this.description,
  });
}
