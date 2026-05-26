import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/folder_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/note_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';
import 'package:projeto_integrado_mobile/src/features/shared/story_registry.dart';
import 'package:projeto_integrado_mobile/src/features/tags/controllers/tag_group_controller.dart';

class NoteEditorController extends ChangeNotifier {
  final NoteRepository repository;
  final FolderRepository folderRepository;
  final int noteId;
  final TagGroupController _tagGroupController = TagGroupController();

  NoteEditorController({
    required this.repository,
    FolderRepository? folderRepository,
    required this.noteId,
  }) : folderRepository = folderRepository ?? FolderRepository() {
    _tagGroupController.addListener(_syncMetadataTagGroups);
  }

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  String _title = '';
  String _description = '';
  Color _color = const Color(0xFF8B7D8B);
  int? _folderId;
  NoteMetadata _metadata = NoteMetadata.empty();

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get title => _title;
  String get description => _description;
  Color get color => _color;
  NoteMetadata get metadata => _metadata;
  List<NoteTagGroup> get tagGroups => _tagGroupController.groups;
  NoteLinkTarget get linkTarget => _metadata.linkTarget;

  @override
  void dispose() {
    _tagGroupController.removeListener(_syncMetadataTagGroups);
    _tagGroupController.dispose();
    super.dispose();
  }

  void _setError(String? value) {
    if (_errorMessage == value) return;
    _errorMessage = value;
    notifyListeners();
  }

  void _syncMetadataTagGroups() {
    _metadata = _metadata.copyWith(tagGroups: _tagGroupController.groups);
    notifyListeners();
  }

  Future<(bool, String?)> loadNote() async {
    _isLoading = true;
    _setError(null);
    notifyListeners();

    final result = await repository.getNote(noteId);
    _isLoading = false;

    if (!result.$1) {
      _setError(result.$3 ?? 'Falha ao carregar nota');
      notifyListeners();
      return (false, _errorMessage);
    }

    final note = result.$2;
    if (note == null) {
      _setError('Nota não encontrada');
      notifyListeners();
      return (false, _errorMessage);
    }

    _title = note.title;
    _description = note.text;
    _color = note.color;
    _folderId = note.idPasta;
    _metadata = note.metadata;
    _tagGroupController.setGroups(_metadata.tagGroups);
    if ((_metadata.linkTarget.projectTitle == null ||
            _metadata.linkTarget.projectTitle!.trim().isEmpty) &&
        (_metadata.linkTarget.characterName == null ||
            _metadata.linkTarget.characterName!.trim().isEmpty)) {
      final linkTarget = await _resolveLinkTargetFromFolder(_folderId);
      if ((linkTarget.projectTitle != null &&
              linkTarget.projectTitle!.isNotEmpty) ||
          (linkTarget.characterName != null &&
              linkTarget.characterName!.isNotEmpty)) {
        _metadata = _metadata.copyWith(linkTarget: linkTarget);
      }
    }
    if (note.id != null) {
      StoryRegistry.instance.registerNote(
        id: note.id!,
        title: note.title,
        accentColor: note.color,
      );
    }
    await repository.touchNote(noteId);
    notifyListeners();
    return (true, null);
  }

  void setTitle(String value) {
    _title = value;
  }

  void setDescription(String value) {
    _description = value;
  }

  void setColor(Color value) {
    if (_color == value) return;
    _color = value;
    notifyListeners();
  }

  void replaceMetadata(NoteMetadata metadata) {
    _metadata = metadata;
    _tagGroupController.setGroups(metadata.tagGroups);
  }

  void addTagGroup({required String title, required Color color}) {
    _tagGroupController.addGroup(title: title, color: color);
  }

  void updateTagGroup({
    required int groupIndex,
    required String title,
    required Color color,
  }) {
    _tagGroupController.updateGroup(
      groupIndex: groupIndex,
      title: title,
      color: color,
    );
  }

  void addTagToGroup({required int groupIndex, required String tagLabel}) {
    _tagGroupController.addTagToGroup(
      groupIndex: groupIndex,
      tagLabel: tagLabel,
    );
  }

  void removeTagGroup(int groupIndex) {
    _tagGroupController.removeGroup(groupIndex);
  }

  void removeTagFromGroup({required int groupIndex, required int tagIndex}) {
    _tagGroupController.removeTagFromGroup(
      groupIndex: groupIndex,
      tagIndex: tagIndex,
    );
  }

  void updateTag({
    required int groupIndex,
    required int tagIndex,
    required String label,
  }) {
    _tagGroupController.updateTag(
      groupIndex: groupIndex,
      tagIndex: tagIndex,
      label: label,
    );
  }

  void setProjectLink(String? projectTitle) {
    _metadata = _metadata.copyWith(
      linkTarget: NoteLinkTarget(
        projectTitle: (projectTitle == null || projectTitle.trim().isEmpty)
            ? null
            : projectTitle.trim(),
        characterName: _metadata.linkTarget.characterName,
      ),
    );
    notifyListeners();
  }

  void clearProjectLink() {
    _metadata = _metadata.copyWith(linkTarget: const NoteLinkTarget());
    notifyListeners();
  }

  void setCharacterLink({
    required String? characterName,
    String? projectTitle,
  }) {
    _metadata = _metadata.copyWith(
      linkTarget: NoteLinkTarget(
        projectTitle: (projectTitle == null || projectTitle.trim().isEmpty)
            ? _metadata.linkTarget.projectTitle
            : projectTitle.trim(),
        characterName: (characterName == null || characterName.trim().isEmpty)
            ? null
            : characterName.trim(),
      ),
    );
    notifyListeners();
  }

  void clearCharacterLink() {
    _metadata = _metadata.copyWith(
      linkTarget: NoteLinkTarget(
        projectTitle: _metadata.linkTarget.projectTitle,
      ),
    );
    notifyListeners();
  }

  Future<(bool, String?)> save() async {
    _isSaving = true;
    _setError(null);
    notifyListeners();

    final resolvedLinkTarget = await _resolveLinkTargetFromFolder(_folderId);
    if ((_metadata.linkTarget.projectTitle == null ||
            _metadata.linkTarget.projectTitle!.trim().isEmpty) &&
        (_metadata.linkTarget.characterName == null ||
            _metadata.linkTarget.characterName!.trim().isEmpty) &&
        ((resolvedLinkTarget.projectTitle != null &&
                resolvedLinkTarget.projectTitle!.isNotEmpty) ||
            (resolvedLinkTarget.characterName != null &&
                resolvedLinkTarget.characterName!.isNotEmpty))) {
      _metadata = _metadata.copyWith(linkTarget: resolvedLinkTarget);
    }

    final targetFolderId = _folderId;
    _folderId = targetFolderId;

    final result = await repository.saveNote(
      id: noteId,
      titulo: _title.trim().isEmpty ? 'Sem título' : _title.trim(),
      descricao: _description,
      idPasta: targetFolderId,
      color: _color,
      metadata: _metadata,
    );

    _isSaving = false;

    if (!result.$1) {
      _setError(result.$2);
      notifyListeners();
      return (false, result.$2);
    }

    StoryRegistry.instance.registerNote(
      id: noteId,
      title: _title.trim().isEmpty ? 'Sem título' : _title.trim(),
      accentColor: _color,
    );
    notifyListeners();
    return (true, null);
  }

  // ignore: unused_element
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
      if (normalizedTitle.isNotEmpty &&
          normalizedTitle != 'sem vínculo' &&
          knownProjectTitles.contains(normalizedTitle)) {
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

  Future<NoteLinkTarget> _resolveLinkTargetFromFolder(int? folderId) async {
    if (folderId == null) return const NoteLinkTarget();

    Folder? current;
    int? currentId = folderId;
    final knownProjectTitles = StoryRegistry.instance.projects
        .map((project) => project.title.trim().toLowerCase())
        .where((title) => title.isNotEmpty)
        .toSet();

    while (currentId != null) {
      final result = await folderRepository.getFolder(currentId);
      if (!result.$1 || result.$2 == null) {
        return const NoteLinkTarget();
      }

      current = result.$2!;
      final characterRootName = current.metadata.characterRootName?.trim();
      if (characterRootName != null && characterRootName.isNotEmpty) {
        return NoteLinkTarget(
          projectTitle: current.metadata.linkTarget.projectTitle?.trim(),
          characterName: characterRootName,
        );
      }

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
        return NoteLinkTarget(projectTitle: currentTitle);
      }
      currentId = current.parentFolderId;
    }

    final rootTitle = current?.title.trim() ?? '';
    if (rootTitle.isEmpty || rootTitle.toLowerCase() == 'sem vínculo') {
      return const NoteLinkTarget();
    }

    return NoteLinkTarget(projectTitle: rootTitle);
  }
}
