import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';

enum MentionTargetKind { project, character, note, folder }

class RegisteredProjectRef {
  final String title;
  final Color accentColor;
  final List<String> aliases;

  const RegisteredProjectRef({
    required this.title,
    required this.accentColor,
    this.aliases = const <String>[],
  });

  bool matchesTitle(String candidate) {
    final normalizedCandidate = _normalizeStoryValue(candidate);
    if (normalizedCandidate.isEmpty) return false;
    return _normalizeStoryValue(title) == normalizedCandidate ||
        aliases.any(
          (alias) => _normalizeStoryValue(alias) == normalizedCandidate,
        );
  }
}

class RegisteredCharacterRef {
  final String projectTitle;
  final String name;
  final Color accentColor;
  final List<String> projectAliases;
  final List<String> nameAliases;

  const RegisteredCharacterRef({
    required this.projectTitle,
    required this.name,
    required this.accentColor,
    this.projectAliases = const <String>[],
    this.nameAliases = const <String>[],
  });

  bool matchesIdentity({required String projectTitle, required String name}) {
    final normalizedProjectTitle = _normalizeStoryValue(projectTitle);
    final normalizedName = _normalizeStoryValue(name);
    if (normalizedProjectTitle.isEmpty || normalizedName.isEmpty) {
      return false;
    }

    final projectMatches = <String>[
      this.projectTitle,
      ...projectAliases,
    ].any((value) => _normalizeStoryValue(value) == normalizedProjectTitle);

    final nameMatches = <String>[
      this.name,
      ...nameAliases,
    ].any((value) => _normalizeStoryValue(value) == normalizedName);

    return projectMatches && nameMatches;
  }
}

class RegisteredNoteRef {
  final int id;
  final String title;
  final Color accentColor;
  final List<String> aliases;

  const RegisteredNoteRef({
    required this.id,
    required this.title,
    required this.accentColor,
    this.aliases = const <String>[],
  });

  bool matchesTitle(String candidate) {
    final normalizedCandidate = _normalizeStoryValue(candidate);
    if (normalizedCandidate.isEmpty) return false;
    return <String>[
      title,
      ...aliases,
    ].any((value) => _normalizeStoryValue(value) == normalizedCandidate);
  }
}

class RegisteredFolderRef {
  final int id;
  final String title;
  final Color accentColor;
  final List<String> aliases;

  const RegisteredFolderRef({
    required this.id,
    required this.title,
    required this.accentColor,
    this.aliases = const <String>[],
  });

  bool matchesTitle(String candidate) {
    final normalizedCandidate = _normalizeStoryValue(candidate);
    if (normalizedCandidate.isEmpty) return false;
    return <String>[
      title,
      ...aliases,
    ].any((value) => _normalizeStoryValue(value) == normalizedCandidate);
  }
}

class MentionTargetRef {
  final MentionTargetKind kind;
  final String label;
  final String uri;
  final Color accentColor;
  final String? projectTitle;
  final String? characterName;
  final int? noteId;
  final List<String> searchTerms;
  final List<String> normalizedSearchTerms;

  const MentionTargetRef({
    required this.kind,
    required this.label,
    required this.uri,
    required this.accentColor,
    this.projectTitle,
    this.characterName,
    this.noteId,
    this.searchTerms = const <String>[],
    this.normalizedSearchTerms = const <String>[],
  });
}

class StoryRegistry extends ChangeNotifier {
  StoryRegistry._();

  static final StoryRegistry instance = StoryRegistry._();

  late final List<RegisteredProjectRef> _projects = <RegisteredProjectRef>[];
  late final List<RegisteredCharacterRef> _characters =
      <RegisteredCharacterRef>[];
  late final List<RegisteredNoteRef> _notes = <RegisteredNoteRef>[];
  late final List<RegisteredFolderRef> _folders = <RegisteredFolderRef>[];
  late final List<MentionTargetRef> _mentionTargets = <MentionTargetRef>[];
  final Map<String, MentionTargetRef> _mentionTargetsByUri =
      <String, MentionTargetRef>{};

  late final UnmodifiableListView<RegisteredProjectRef> _projectView =
      UnmodifiableListView<RegisteredProjectRef>(_projects);
  late final UnmodifiableListView<RegisteredCharacterRef> _characterView =
      UnmodifiableListView<RegisteredCharacterRef>(_characters);
  late final UnmodifiableListView<RegisteredNoteRef> _noteView =
      UnmodifiableListView<RegisteredNoteRef>(_notes);
  late final UnmodifiableListView<RegisteredFolderRef> _folderView =
      UnmodifiableListView<RegisteredFolderRef>(_folders);
  late final UnmodifiableListView<MentionTargetRef> _mentionTargetView =
      UnmodifiableListView<MentionTargetRef>(_mentionTargets);

  List<RegisteredProjectRef> get projects => _projectView;
  List<RegisteredCharacterRef> get characters => _characterView;
  List<RegisteredNoteRef> get notes => _noteView;
  List<RegisteredFolderRef> get folders => _folderView;
  List<MentionTargetRef> get mentionTargets => _mentionTargetView;

  void registerProject({required String title, required Color accentColor}) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) return;

    final existingIndex = _projects.indexWhere(
      (project) => project.matchesTitle(normalizedTitle),
    );
    final previousAliases = existingIndex == -1
        ? const <String>[]
        : _projects[existingIndex].aliases;
    final nextAliases = _mergeAliases(previousAliases, [
      if (existingIndex != -1) _projects[existingIndex].title,
      if (existingIndex != -1) ..._projects[existingIndex].aliases,
    ]);
    final updated = RegisteredProjectRef(
      title: normalizedTitle,
      accentColor: accentColor,
      aliases: nextAliases,
    );

    if (existingIndex == -1) {
      _projects.add(updated);
    } else {
      _projects[existingIndex] = updated;
    }

    _rebuildMentionTargets();
    notifyListeners();
  }

  void renameProject(String oldTitle, String newTitle) {
    final normalizedOldTitle = oldTitle.trim();
    final normalizedNewTitle = newTitle.trim();
    if (normalizedOldTitle.isEmpty || normalizedNewTitle.isEmpty) return;

    final projectIndex = _projects.indexWhere(
      (project) => project.matchesTitle(normalizedOldTitle),
    );
    if (projectIndex != -1) {
      final currentProject = _projects[projectIndex];
      _projects[projectIndex] = RegisteredProjectRef(
        title: normalizedNewTitle,
        accentColor: currentProject.accentColor,
        aliases: _mergeAliases(currentProject.aliases, [
          currentProject.title,
          ...currentProject.aliases,
        ]),
      );
    }

    for (var index = 0; index < _characters.length; index += 1) {
      final character = _characters[index];
      if (_matchesAnyTitle(normalizedOldTitle, [
        character.projectTitle,
        ...character.projectAliases,
      ])) {
        _characters[index] = RegisteredCharacterRef(
          projectTitle: normalizedNewTitle,
          name: character.name,
          accentColor: character.accentColor,
          projectAliases: _mergeAliases(character.projectAliases, [
            character.projectTitle,
            ...character.projectAliases,
          ]),
          nameAliases: character.nameAliases,
        );
      }
    }

    _rebuildMentionTargets();
    notifyListeners();
  }

  void removeProject(String title) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) return;

    _projects.removeWhere((project) => project.matchesTitle(normalizedTitle));
    _characters.removeWhere(
      (character) => _matchesAnyTitle(normalizedTitle, [
        character.projectTitle,
        ...character.projectAliases,
      ]),
    );

    _rebuildMentionTargets();
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
      (character) => character.matchesIdentity(
        projectTitle: normalizedProjectTitle,
        name: normalizedName,
      ),
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

    _rebuildMentionTargets();
    notifyListeners();
  }

  void syncProjects(Iterable<RegisteredProjectRef> projects) {
    _projects
      ..clear()
      ..addAll(projects);

    _rebuildMentionTargets();
    notifyListeners();
  }

  void syncNotes(Iterable<RegisteredNoteRef> notes) {
    final previousById = <int, RegisteredNoteRef>{
      for (final note in _notes) note.id: note,
    };
    _notes
      ..clear()
      ..addAll(
        notes.where((note) => note.id > 0 && note.title.trim().isNotEmpty).map((
          note,
        ) {
          final previous = previousById[note.id];
          if (previous == null) {
            return note;
          }

          final titleChanged = previous.title != note.title;
          return RegisteredNoteRef(
            id: note.id,
            title: note.title,
            accentColor: note.accentColor,
            aliases: _mergeAliases(previous.aliases, [
              if (titleChanged) previous.title,
              ...note.aliases,
            ]),
          );
        }),
      );

    _rebuildMentionTargets();
    notifyListeners();
  }

  void upsertFolders(Iterable<RegisteredFolderRef> folders) {
    var didChange = false;

    for (final folder in folders) {
      if (folder.id <= 0 || folder.title.trim().isEmpty) {
        continue;
      }

      final existingIndex = _folders.indexWhere(
        (current) => current.id == folder.id,
      );
      if (existingIndex == -1) {
        _folders.add(folder);
        didChange = true;
        continue;
      }

      final current = _folders[existingIndex];
      final titleChanged = current.title != folder.title;
      final nextAliases = _mergeAliases(current.aliases, [
        if (titleChanged) current.title,
        ...folder.aliases,
      ]);
      if (current.title == folder.title &&
          current.accentColor == folder.accentColor &&
          _sameStringList(current.aliases, nextAliases)) {
        continue;
      }

      _folders[existingIndex] = RegisteredFolderRef(
        id: folder.id,
        title: folder.title,
        accentColor: folder.accentColor,
        aliases: nextAliases,
      );
      didChange = true;
    }

    if (!didChange) {
      return;
    }

    _rebuildMentionTargets();
    notifyListeners();
  }

  void syncCharacters(Iterable<RegisteredCharacterRef> characters) {
    _characters
      ..clear()
      ..addAll(characters);

    _rebuildMentionTargets();
    notifyListeners();
  }

  void syncProjectsAndCharacters({
    required Iterable<RegisteredProjectRef> projects,
    required Iterable<RegisteredCharacterRef> characters,
  }) {
    _projects
      ..clear()
      ..addAll(projects);
    _characters
      ..clear()
      ..addAll(characters);

    _rebuildMentionTargets();
    notifyListeners();
  }

  void updateCharacter({
    required String projectTitle,
    required String oldName,
    required String newName,
    required Color accentColor,
  }) {
    final normalizedProjectTitle = projectTitle.trim();
    final normalizedOldName = oldName.trim();
    final normalizedNewName = newName.trim();

    if (normalizedProjectTitle.isEmpty ||
        normalizedOldName.isEmpty ||
        normalizedNewName.isEmpty) {
      return;
    }

    final existingIndex = _characters.indexWhere(
      (character) => character.matchesIdentity(
        projectTitle: normalizedProjectTitle,
        name: normalizedOldName,
      ),
    );

    if (existingIndex == -1) {
      registerCharacter(
        projectTitle: normalizedProjectTitle,
        name: normalizedNewName,
        accentColor: accentColor,
      );
      return;
    }

    final currentCharacter = _characters[existingIndex];
    _characters[existingIndex] = RegisteredCharacterRef(
      projectTitle: currentCharacter.projectTitle,
      name: normalizedNewName,
      accentColor: accentColor,
      projectAliases: _mergeAliases(currentCharacter.projectAliases, [
        currentCharacter.projectTitle,
        ...currentCharacter.projectAliases,
      ]),
      nameAliases: _mergeAliases(currentCharacter.nameAliases, [
        currentCharacter.name,
        ...currentCharacter.nameAliases,
      ]),
    );

    _rebuildMentionTargets();
    notifyListeners();
  }

  void removeCharacter({required String projectTitle, required String name}) {
    final normalizedProjectTitle = projectTitle.trim();
    final normalizedName = name.trim();
    if (normalizedProjectTitle.isEmpty || normalizedName.isEmpty) return;

    _characters.removeWhere(
      (character) => character.matchesIdentity(
        projectTitle: normalizedProjectTitle,
        name: normalizedName,
      ),
    );

    _rebuildMentionTargets();
    notifyListeners();
  }

  void registerNote({
    required int id,
    required String title,
    required Color accentColor,
  }) {
    final normalizedTitle = title.trim();
    if (id <= 0 || normalizedTitle.isEmpty) return;

    final existingIndex = _notes.indexWhere((note) => note.id == id);
    final previousAliases = existingIndex == -1
        ? const <String>[]
        : _notes[existingIndex].aliases;
    final nextAliases = _mergeAliases(previousAliases, [
      if (existingIndex != -1) _notes[existingIndex].title,
      if (existingIndex != -1) ..._notes[existingIndex].aliases,
    ]);
    final updated = RegisteredNoteRef(
      id: id,
      title: normalizedTitle,
      accentColor: accentColor,
      aliases: nextAliases,
    );

    if (existingIndex == -1) {
      _notes.add(updated);
    } else {
      _notes[existingIndex] = updated;
    }

    _rebuildMentionTargets();
    notifyListeners();
  }

  void registerFolder({
    required int id,
    required String title,
    required Color accentColor,
  }) {
    final normalizedTitle = title.trim();
    if (id <= 0 || normalizedTitle.isEmpty) return;

    final existingIndex = _folders.indexWhere((folder) => folder.id == id);
    final previousAliases = existingIndex == -1
        ? const <String>[]
        : _folders[existingIndex].aliases;
    final nextAliases = _mergeAliases(previousAliases, [
      if (existingIndex != -1) _folders[existingIndex].title,
      if (existingIndex != -1) ..._folders[existingIndex].aliases,
    ]);
    final updated = RegisteredFolderRef(
      id: id,
      title: normalizedTitle,
      accentColor: accentColor,
      aliases: nextAliases,
    );

    if (existingIndex == -1) {
      _folders.add(updated);
    } else {
      _folders[existingIndex] = updated;
    }

    _rebuildMentionTargets();
    notifyListeners();
  }

  void removeFolder(int id) {
    final existingIndex = _folders.indexWhere((folder) => folder.id == id);
    if (existingIndex == -1) return;

    _folders.removeAt(existingIndex);
    _rebuildMentionTargets();
    notifyListeners();
  }

  void removeNote(int id) {
    final existingIndex = _notes.indexWhere((note) => note.id == id);
    if (existingIndex == -1) return;

    _notes.removeAt(existingIndex);
    _rebuildMentionTargets();
    notifyListeners();
  }

  List<MentionTargetRef> searchMentionTargets(String query, {int limit = 8}) {
    final normalizedQuery = _normalizeStoryValue(query);
    if (normalizedQuery.isEmpty) {
      return _mentionTargets.take(limit).toList(growable: false);
    }

    final matches = <MentionTargetRef>[];
    for (final target in _mentionTargets) {
      final terms = target.normalizedSearchTerms;
      final hasMatch = terms.isEmpty
          ? _normalizeStoryValue(target.label).contains(normalizedQuery)
          : terms.any((value) => value.contains(normalizedQuery));
      if (hasMatch) {
        matches.add(target);
      }
    }

    matches.sort((left, right) {
      final leftExact = _normalizeStoryValue(
        left.label,
      ).startsWith(normalizedQuery);
      final rightExact = _normalizeStoryValue(
        right.label,
      ).startsWith(normalizedQuery);
      if (leftExact != rightExact) {
        return rightExact ? 1 : -1;
      }

      return left.label.length.compareTo(right.label.length);
    });

    return matches.take(limit).toList(growable: false);
  }

  MentionTargetRef? findMentionTargetByUri(String uri) {
    final exact = _mentionTargetsByUri[uri];
    if (exact != null) {
      return exact;
    }

    final parsed = Uri.tryParse(uri);
    if (parsed == null || parsed.scheme != 'app' || parsed.host.isEmpty) {
      return null;
    }

    final kind = parsed.host;
    if (kind == 'project') {
      if (parsed.pathSegments.isEmpty) return null;
      final title = parsed.pathSegments.first;
      return _findProjectMentionTarget(title);
    }

    if (kind == 'character') {
      if (parsed.pathSegments.length < 2) return null;
      final projectTitle = parsed.pathSegments[0];
      final characterName = parsed.pathSegments[1];
      return _findCharacterMentionTarget(
        projectTitle: projectTitle,
        name: characterName,
      );
    }

    if (kind == 'note') {
      if (parsed.pathSegments.isEmpty) return null;
      final noteId = int.tryParse(parsed.pathSegments.first);
      if (noteId == null) return null;
      return _findNoteMentionTarget(noteId);
    }

    if (kind == 'folder') {
      if (parsed.pathSegments.isEmpty) return null;
      final folderId = int.tryParse(parsed.pathSegments.first);
      if (folderId == null) return null;
      return _findFolderMentionTarget(folderId);
    }

    return null;
  }

  void _rebuildMentionTargets() {
    _mentionTargets
      ..clear()
      ..addAll(
        _projects.map((project) {
          final searchTerms = <String>[project.title, ...project.aliases];
          return MentionTargetRef(
            kind: MentionTargetKind.project,
            label: project.title,
            uri: _projectMentionUri(project.title),
            accentColor: project.accentColor,
            searchTerms: searchTerms,
            normalizedSearchTerms: _normalizedTerms(searchTerms),
          );
        }),
      )
      ..addAll(
        _characters.map((character) {
          final searchTerms = <String>[
            character.name,
            character.projectTitle,
            '${character.projectTitle} ${character.name}',
            ...character.projectAliases,
            ...character.nameAliases,
          ];
          return MentionTargetRef(
            kind: MentionTargetKind.character,
            label: character.name,
            uri: _characterMentionUri(
              projectTitle: character.projectTitle,
              name: character.name,
            ),
            accentColor: character.accentColor,
            projectTitle: character.projectTitle,
            characterName: character.name,
            searchTerms: searchTerms,
            normalizedSearchTerms: _normalizedTerms(searchTerms),
          );
        }),
      );
    _mentionTargets.addAll(
      _folders.map((folder) {
        final searchTerms = <String>[folder.title, ...folder.aliases];
        return MentionTargetRef(
          kind: MentionTargetKind.folder,
          label: folder.title,
          uri: _folderMentionUri(folder.id),
          accentColor: folder.accentColor,
          searchTerms: searchTerms,
          normalizedSearchTerms: _normalizedTerms(searchTerms),
        );
      }),
    );
    _mentionTargets.addAll(
      _notes.map((note) {
        final searchTerms = <String>[note.title, ...note.aliases];
        return MentionTargetRef(
          kind: MentionTargetKind.note,
          label: note.title,
          uri: _noteMentionUri(note.id),
          accentColor: note.accentColor,
          noteId: note.id,
          searchTerms: searchTerms,
          normalizedSearchTerms: _normalizedTerms(searchTerms),
        );
      }),
    );

    _mentionTargetsByUri
      ..clear()
      ..addEntries(
        _mentionTargets.map(
          (target) => MapEntry<String, MentionTargetRef>(target.uri, target),
        ),
      );
  }

  MentionTargetRef? _findProjectMentionTarget(String title) {
    final normalizedTitle = _normalizeStoryValue(title);
    if (normalizedTitle.isEmpty) return null;

    for (final project in _projects) {
      if (_matchesAnyTitle(normalizedTitle, [
        project.title,
        ...project.aliases,
      ])) {
        return MentionTargetRef(
          kind: MentionTargetKind.project,
          label: project.title,
          uri: _projectMentionUri(project.title),
          accentColor: project.accentColor,
          searchTerms: <String>[project.title, ...project.aliases],
        );
      }
    }

    return null;
  }

  MentionTargetRef? _findCharacterMentionTarget({
    required String projectTitle,
    required String name,
  }) {
    final normalizedProjectTitle = _normalizeStoryValue(projectTitle);
    final normalizedName = _normalizeStoryValue(name);
    if (normalizedProjectTitle.isEmpty || normalizedName.isEmpty) {
      return null;
    }

    for (final character in _characters) {
      if (character.matchesIdentity(projectTitle: projectTitle, name: name)) {
        return MentionTargetRef(
          kind: MentionTargetKind.character,
          label: character.name,
          uri: _characterMentionUri(
            projectTitle: character.projectTitle,
            name: character.name,
          ),
          accentColor: character.accentColor,
          projectTitle: character.projectTitle,
          characterName: character.name,
          searchTerms: <String>[
            character.name,
            character.projectTitle,
            '${character.projectTitle} ${character.name}',
            ...character.projectAliases,
            ...character.nameAliases,
          ],
        );
      }
    }

    return null;
  }

  MentionTargetRef? _findNoteMentionTarget(int noteId) {
    for (final note in _notes) {
      if (note.id == noteId) {
        return MentionTargetRef(
          kind: MentionTargetKind.note,
          label: note.title,
          uri: _noteMentionUri(note.id),
          accentColor: note.accentColor,
          noteId: note.id,
          searchTerms: <String>[note.title, ...note.aliases],
        );
      }
    }

    return null;
  }

  MentionTargetRef? _findFolderMentionTarget(int folderId) {
    for (final folder in _folders) {
      if (folder.id == folderId) {
        return MentionTargetRef(
          kind: MentionTargetKind.folder,
          label: folder.title,
          uri: _folderMentionUri(folder.id),
          accentColor: folder.accentColor,
          searchTerms: <String>[folder.title, ...folder.aliases],
        );
      }
    }

    return null;
  }
}

String _normalizeStoryValue(String value) {
  return value.trim().toLowerCase();
}

bool _matchesAnyTitle(String candidate, Iterable<String> values) {
  final normalizedCandidate = _normalizeStoryValue(candidate);
  if (normalizedCandidate.isEmpty) return false;
  return values.any(
    (value) => _normalizeStoryValue(value) == normalizedCandidate,
  );
}

List<String> _mergeAliases(Iterable<String> existing, Iterable<String> added) {
  final seen = <String>{};
  final aliases = <String>[];

  for (final value in [...existing, ...added]) {
    final normalized = _normalizeStoryValue(value);
    if (normalized.isEmpty || !seen.add(normalized)) {
      continue;
    }
    aliases.add(value.trim());
  }

  return List<String>.unmodifiable(aliases);
}

List<String> _normalizedTerms(Iterable<String> terms) {
  final seen = <String>{};
  final normalizedTerms = <String>[];

  for (final term in terms) {
    final normalized = _normalizeStoryValue(term);
    if (normalized.isEmpty || !seen.add(normalized)) {
      continue;
    }
    normalizedTerms.add(normalized);
  }

  return List<String>.unmodifiable(normalizedTerms);
}

bool _sameStringList(List<String> left, List<String> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;

  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }

  return true;
}

String _projectMentionUri(String title) {
  return 'app://project/${Uri.encodeComponent(title.trim())}';
}

String _characterMentionUri({
  required String projectTitle,
  required String name,
}) {
  return 'app://character/${Uri.encodeComponent(projectTitle.trim())}/${Uri.encodeComponent(name.trim())}';
}

String _noteMentionUri(int noteId) {
  return 'app://note/$noteId';
}

String _folderMentionUri(int folderId) {
  return 'app://folder/$folderId';
}
