import 'dart:ui';

import 'package:flutter/foundation.dart';

class RegisteredProjectRef {
  final String title;
  final Color accentColor;

  const RegisteredProjectRef({required this.title, required this.accentColor});
}

class RegisteredCharacterRef {
  final String projectTitle;
  final String name;
  final Color accentColor;

  const RegisteredCharacterRef({
    required this.projectTitle,
    required this.name,
    required this.accentColor,
  });
}

class StoryRegistry extends ChangeNotifier {
  StoryRegistry._();

  static final StoryRegistry instance = StoryRegistry._();

  final List<RegisteredProjectRef> _projects = <RegisteredProjectRef>[];
  final List<RegisteredCharacterRef> _characters = <RegisteredCharacterRef>[];

  List<RegisteredProjectRef> get projects => List.unmodifiable(_projects);
  List<RegisteredCharacterRef> get characters => List.unmodifiable(_characters);

  void registerProject({required String title, required Color accentColor}) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) return;

    final existingIndex = _projects.indexWhere(
      (project) => project.title == normalizedTitle,
    );
    final updated = RegisteredProjectRef(
      title: normalizedTitle,
      accentColor: accentColor,
    );

    if (existingIndex == -1) {
      _projects.add(updated);
    } else {
      _projects[existingIndex] = updated;
    }

    notifyListeners();
  }

  void renameProject(String oldTitle, String newTitle) {
    final normalizedOldTitle = oldTitle.trim();
    final normalizedNewTitle = newTitle.trim();
    if (normalizedOldTitle.isEmpty || normalizedNewTitle.isEmpty) return;

    final projectIndex = _projects.indexWhere(
      (project) => project.title == normalizedOldTitle,
    );
    if (projectIndex != -1) {
      _projects[projectIndex] = RegisteredProjectRef(
        title: normalizedNewTitle,
        accentColor: _projects[projectIndex].accentColor,
      );
    }

    for (var index = 0; index < _characters.length; index += 1) {
      final character = _characters[index];
      if (character.projectTitle == normalizedOldTitle) {
        _characters[index] = RegisteredCharacterRef(
          projectTitle: normalizedNewTitle,
          name: character.name,
          accentColor: character.accentColor,
        );
      }
    }

    notifyListeners();
  }

  void registerCharacter({
    required String projectTitle,
    required String name,
    required Color accentColor,
  }) {
    final normalizedProjectTitle = projectTitle.trim();
    final normalizedName = name.trim();
    if (normalizedProjectTitle.isEmpty || normalizedName.isEmpty) return;

    final existingIndex = _characters.indexWhere(
      (character) =>
          character.projectTitle == normalizedProjectTitle &&
          character.name.toLowerCase() == normalizedName.toLowerCase(),
    );
    final updated = RegisteredCharacterRef(
      projectTitle: normalizedProjectTitle,
      name: normalizedName,
      accentColor: accentColor,
    );

    if (existingIndex == -1) {
      _characters.add(updated);
    } else {
      _characters[existingIndex] = updated;
    }

    notifyListeners();
  }
}
