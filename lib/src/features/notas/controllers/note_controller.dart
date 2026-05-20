import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/folder_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/note_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note.dart';
import 'package:projeto_integrado_mobile/src/features/shared/story_registry.dart';

class NoteController extends ChangeNotifier {
  final NoteRepository repository;
  final FolderRepository folderRepository;

  NoteController({required this.repository, FolderRepository? folderRepository})
    : folderRepository = folderRepository ?? FolderRepository();

  bool _isLoading = false;
  String? _errorMessage;
  final List<Note> _notes = <Note>[];
  late final UnmodifiableListView<Note> _notesView = UnmodifiableListView<Note>(
    _notes,
  );
  int? _currentFolderId;
  int _loadRequestToken = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Note> get notes => _notesView;
  int? get currentFolderId => _currentFolderId;

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    if (_errorMessage == value) return;
    _errorMessage = value;
    notifyListeners();
  }

  Future<(bool, String?)> loadNotes({int? folderId}) async {
    final requestToken = ++_loadRequestToken;
    _setLoading(true);
    _setError(null);
    _currentFolderId = folderId;

    final result = await repository.listNotes(folderId);
    if (requestToken != _loadRequestToken) {
      return (true, null);
    }

    _setLoading(false);

    if (!result.$1) {
      _notes.clear();
      _setError(result.$3 ?? 'Falha ao listar notas');
      return (false, _errorMessage);
    }

    _notes
      ..clear()
      ..addAll(result.$2 ?? const <Note>[]);
    await _syncNoteMentions(_notes);
    if (requestToken != _loadRequestToken) {
      return (true, null);
    }
    notifyListeners();
    return (true, null);
  }

  Future<(bool, String?)> createNote({
    required String title,
    required String description,
    int? folderId,
    Color color = const Color(0xFF8B7D8B),
  }) async {
    if (title.trim().isEmpty) {
      const message = 'O título da nota não pode ser vazio';
      _setError(message);
      return (false, message);
    }

    _setError(null);
    final metadata = await _resolveDraftMetadata(folderId ?? _currentFolderId);
    final targetFolderId = await _resolveTargetFolderId(
      metadata.linkTarget.projectTitle,
      fallbackFolderId: folderId ?? _currentFolderId,
      fallbackColor: color,
    );

    final result = await repository.createNewNote(
      title.trim(),
      description.trim(),
      targetFolderId,
      color,
      metadata: metadata,
    );

    if (!result.$1) {
      _setError(result.$2);
      return (false, result.$2);
    }

    return await loadNotes(folderId: targetFolderId);
  }

  Future<(bool, int?, String?)> createDraftNote({
    int? folderId,
    Color color = const Color(0xFF8B7D8B),
  }) async {
    _setError(null);
    final metadata = await _resolveDraftMetadata(folderId ?? _currentFolderId);
    final targetFolderId = await _resolveTargetFolderId(
      metadata.linkTarget.projectTitle,
      fallbackFolderId: folderId ?? _currentFolderId,
      fallbackColor: color,
    );
    final result = await repository.createNewNoteWithId(
      'Sem título',
      '',
      targetFolderId,
      color,
      metadata: metadata,
    );

    if (!result.$1) {
      _setError(result.$3);
      return (false, null, result.$3);
    }

    await loadNotes(folderId: targetFolderId);
    return result;
  }

  Future<(bool, String?)> moveNoteToFolder({
    required int noteId,
    required int? folderId,
  }) async {
    _setError(null);
    final result = await repository.moveNoteToFolder(noteId, folderId);

    if (!result.$1) {
      _setError(result.$2);
      return (false, result.$2);
    }

    StoryRegistry.instance.removeNote(noteId);
    return await loadNotes(folderId: _currentFolderId);
  }

  Future<(bool, String?)> deleteNote(int noteId) async {
    _setError(null);
    final result = await repository.deleteNote(noteId);

    if (!result.$1) {
      _setError(result.$2);
      return (false, result.$2);
    }

    StoryRegistry.instance.removeNote(noteId);
    return await loadNotes(folderId: _currentFolderId);
  }

  Future<(bool, String?)> touchNote(int noteId) async {
    _setError(null);
    final result = await repository.touchNote(noteId);

    if (!result.$1) {
      _setError(result.$2);
      return (false, result.$2);
    }

    return (true, null);
  }

  Future<(bool, String?)> setNotePinned({
    required int noteId,
    required bool pinned,
  }) async {
    _setError(null);
    final result = await repository.getNote(noteId);
    if (!result.$1 || result.$2 == null) {
      final message = result.$3 ?? 'Nota não encontrada';
      _setError(message);
      return (false, message);
    }

    final note = result.$2!;
    final updatedMetadata = note.metadata.copyWith(pinned: pinned);
    final updateResult = await repository.updateNote(
      noteId,
      note.title,
      note.text,
      note.idPasta,
      note.color,
      metadata: updatedMetadata,
    );

    if (!updateResult.$1) {
      _setError(updateResult.$2);
      return (false, updateResult.$2);
    }

    return await loadNotes(folderId: _currentFolderId);
  }

  Future<void> _syncNoteMentions(List<Note> notes) async {
    final result = await repository.listNoteRegistryRefs();
    if (result.$1 && result.$2 != null) {
      StoryRegistry.instance.syncNotes(
        result.$2!.map(
          (note) => RegisteredNoteRef(
            id: note.id,
            title: note.title,
            accentColor: note.color,
          ),
        ),
      );
      return;
    }

    StoryRegistry.instance.syncNotes(
      notes
          .where((note) => note.id != null)
          .map(
            (note) => RegisteredNoteRef(
              id: note.id!,
              title: note.title,
              accentColor: note.color,
            ),
          ),
    );
  }

  Future<NoteMetadata> _resolveDraftMetadata(int? folderId) async {
    final projectTitle = await _resolveProjectTitleFromFolder(folderId);
    if (projectTitle == null || projectTitle.isEmpty) {
      return NoteMetadata.empty();
    }

    return NoteMetadata(
      tagGroups: const <NoteTagGroup>[],
      linkTarget: NoteLinkTarget(projectTitle: projectTitle),
    );
  }

  Future<String?> _resolveProjectTitleFromFolder(int? folderId) async {
    if (folderId == null) return null;

    Folder? current;
    int? currentId = folderId;
    final knownProjectTitles = StoryRegistry.instance.projects
        .map((project) => project.title.trim().toLowerCase())
        .where((title) => title.isNotEmpty)
        .toSet();

    while (currentId != null) {
      final result = await folderRepository.getFolder(currentId);
      if (!result.$1 || result.$2 == null) {
        return null;
      }

      current = result.$2!;
      final currentTitle = current.title.trim();
      final normalizedTitle = currentTitle.toLowerCase();
      final projectRootTitle = current.metadata.projectRootTitle
          ?.trim()
          .toLowerCase();
      final isKnownProjectRoot =
          (projectRootTitle != null &&
              projectRootTitle.isNotEmpty &&
              knownProjectTitles.contains(projectRootTitle)) ||
          (current.parentFolderId == null &&
              knownProjectTitles.contains(normalizedTitle));
      if (normalizedTitle.isNotEmpty &&
          normalizedTitle != 'sem vínculo' &&
          isKnownProjectRoot) {
        return currentTitle;
      }
      currentId = current.parentFolderId;
    }

    final rootTitle = current?.title.trim() ?? '';
    if (rootTitle.isEmpty || rootTitle.toLowerCase() == 'sem vínculo') {
      return null;
    }

    return rootTitle;
  }

  Future<int?> _resolveTargetFolderId(
    String? projectTitle, {
    required int? fallbackFolderId,
    required Color fallbackColor,
  }) async {
    final normalizedProjectTitle = projectTitle?.trim();
    if (normalizedProjectTitle == null || normalizedProjectTitle.isEmpty) {
      return fallbackFolderId;
    }

    var accentColor = fallbackColor;
    for (final project in StoryRegistry.instance.projects) {
      if (project.title.trim().toLowerCase() ==
          normalizedProjectTitle.toLowerCase()) {
        accentColor = project.accentColor;
        break;
      }
    }

    final folder = await folderRepository.ensureRootFolder(
      title: normalizedProjectTitle,
      color: accentColor,
    );
    if (folder?.id == null || folder!.id! <= 0) {
      return fallbackFolderId;
    }

    StoryRegistry.instance.registerFolder(
      id: folder.id!,
      title: folder.title,
      accentColor: folder.color,
    );
    return folder.id;
  }
}
