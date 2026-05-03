import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/note_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note.dart';

class NoteController extends ChangeNotifier {
  final NoteRepository repository;

  NoteController({required this.repository});

  bool _isLoading = false;
  String? _errorMessage;
  List<Note> _notes = const [];
  int? _currentFolderId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Note> get notes => List.unmodifiable(_notes);
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
    _setLoading(true);
    _setError(null);
    _currentFolderId = folderId;

    final result = await repository.listNotes(folderId);
    _setLoading(false);

    if (!result.$1) {
      _notes = const [];
      _setError(result.$3 ?? 'Falha ao listar notas');
      return (false, _errorMessage);
    }

    _notes = result.$2 ?? const [];
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

    final result = await repository.createNewNote(
      title.trim(),
      description.trim(),
      folderId,
      color,
    );

    if (!result.$1) {
      _setError(result.$2);
      return (false, result.$2);
    }

    return await loadNotes(folderId: folderId ?? _currentFolderId);
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

    return await loadNotes(folderId: _currentFolderId);
  }

  Future<(bool, String?)> deleteNote(int noteId) async {
    _setError(null);
    final result = await repository.deleteNote(noteId);

    if (!result.$1) {
      _setError(result.$2);
      return (false, result.$2);
    }

    return await loadNotes(folderId: _currentFolderId);
  }
}
