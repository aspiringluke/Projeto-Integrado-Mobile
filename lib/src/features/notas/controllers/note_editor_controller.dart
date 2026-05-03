import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/note_repository.dart';

class NoteEditorController extends ChangeNotifier {
  final NoteRepository repository;
  final int noteId;

  NoteEditorController({
    required this.repository,
    required this.noteId,
  });

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  String _title = '';
  String _description = '';
  Color _color = const Color(0xFF8B7D8B);
  int? _folderId;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String get title => _title;
  String get description => _description;
  Color get color => _color;

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
