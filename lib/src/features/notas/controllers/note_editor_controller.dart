import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/note_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';

class NoteEditorController extends ChangeNotifier {
  final NoteRepository repository;
  final int noteId;

  NoteEditorController({required this.repository, required this.noteId});

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
  List<NoteTagGroup> get tagGroups => _metadata.tagGroups;
  NoteLinkTarget get linkTarget => _metadata.linkTarget;

  void _setError(String? value) {
    if (_errorMessage == value) return;
    _errorMessage = value;
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
    notifyListeners();
  }

  void addTagGroup({required String title, required Color color}) {
    final sanitizedTitle = title.trim();
    if (sanitizedTitle.isEmpty) return;

    _metadata = _metadata.copyWith(
      tagGroups: <NoteTagGroup>[
        ..._metadata.tagGroups,
        NoteTagGroup(
          title: sanitizedTitle,
          color: color,
          tags: const <NoteTagItem>[],
        ),
      ],
    );
    notifyListeners();
  }

  void addTagToGroup({required int groupIndex, required String tagLabel}) {
    if (groupIndex < 0 || groupIndex >= _metadata.tagGroups.length) return;

    final sanitizedLabel = tagLabel.trim();
    if (sanitizedLabel.isEmpty) return;

    final groups = _metadata.tagGroups.toList(growable: true);
    final group = groups[groupIndex];
    final hasTag = group.tags.any(
      (tag) => tag.label.toLowerCase() == sanitizedLabel.toLowerCase(),
    );
    if (hasTag) return;

    groups[groupIndex] = NoteTagGroup(
      title: group.title,
      color: group.color,
      tags: <NoteTagItem>[
        ...group.tags,
        NoteTagItem(label: sanitizedLabel),
      ],
    );
    _metadata = _metadata.copyWith(tagGroups: groups);
    notifyListeners();
  }

  void removeTagGroup(int groupIndex) {
    if (groupIndex < 0 || groupIndex >= _metadata.tagGroups.length) return;
    final groups = _metadata.tagGroups.toList(growable: true)
      ..removeAt(groupIndex);
    _metadata = _metadata.copyWith(tagGroups: groups);
    notifyListeners();
  }

  void removeTagFromGroup({required int groupIndex, required int tagIndex}) {
    if (groupIndex < 0 || groupIndex >= _metadata.tagGroups.length) return;
    final group = _metadata.tagGroups[groupIndex];
    if (tagIndex < 0 || tagIndex >= group.tags.length) return;

    final groups = _metadata.tagGroups.toList(growable: true);
    final tags = group.tags.toList(growable: true)..removeAt(tagIndex);
    groups[groupIndex] = NoteTagGroup(
      title: group.title,
      color: group.color,
      tags: tags,
    );
    _metadata = _metadata.copyWith(tagGroups: groups);
    notifyListeners();
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

    final result = await repository.updateNote(
      noteId,
      _title.trim().isEmpty ? 'Sem título' : _title.trim(),
      _description,
      _folderId,
      _color,
      metadata: _metadata,
    );

    _isSaving = false;

    if (!result.$1) {
      _setError(result.$2);
      notifyListeners();
      return (false, result.$2);
    }

    notifyListeners();
    return (true, null);
  }
}
