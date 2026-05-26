part of '../create_character_dialog.dart';

class CreateCharacterDraft {
  final String name;
  final String synopsis;
  final String motto;
  final String alias;
  final String formationsAndOccupations;
  final String titles;
  final int birthDay;
  final int birthMonth;
  final double weightKg;
  final double heightCm;
  final String genderTag;
  final String sexualityTag;
  final String ethnicityTag;
  final String functionTag;
  final String relevanceTag;
  final Map<String, String> notebookComplexityValues;
  final Set<CharacterProfileFieldId> visibleProfileFields;
  final Color coverColor;
  final Color accentColor;
  final ProjectImageData profileImage;

  const CreateCharacterDraft({
    required this.name,
    required this.synopsis,
    required this.motto,
    required this.alias,
    required this.formationsAndOccupations,
    required this.titles,
    required this.birthDay,
    required this.birthMonth,
    required this.weightKg,
    required this.heightCm,
    required this.genderTag,
    required this.sexualityTag,
    required this.ethnicityTag,
    required this.functionTag,
    required this.relevanceTag,
    required this.notebookComplexityValues,
    required this.visibleProfileFields,
    required this.coverColor,
    required this.accentColor,
    required this.profileImage,
  });
}
