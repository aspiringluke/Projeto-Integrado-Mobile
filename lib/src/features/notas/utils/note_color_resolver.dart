import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';
import 'package:projeto_integrado_mobile/src/features/shared/story_registry.dart';

Color resolveNoteAccentColor({
  required NoteMetadata metadata,
  required Color fallbackColor,
  required StoryRegistry registry,
}) {
  final linkTarget = metadata.linkTarget;
  final projectTitle = linkTarget.projectTitle?.trim();
  final characterName = linkTarget.characterName?.trim();

  if (characterName != null && characterName.isNotEmpty) {
    for (final character in registry.characters) {
      final sameCharacter =
          character.name.toLowerCase() == characterName.toLowerCase();
      final sameProject =
          projectTitle == null ||
          projectTitle.isEmpty ||
          character.projectTitle == projectTitle;
      if (sameCharacter && sameProject) {
        return character.accentColor;
      }
    }
  }

  if (projectTitle != null && projectTitle.isNotEmpty) {
    for (final project in registry.projects) {
      if (project.title == projectTitle) {
        return project.accentColor;
      }
    }
  }

  return fallbackColor;
}
