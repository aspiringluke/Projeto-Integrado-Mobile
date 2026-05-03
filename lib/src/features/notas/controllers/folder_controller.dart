import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/folder_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';

class FolderController extends ChangeNotifier {
  final FolderRepository repository;

  FolderController({required this.repository});

  bool _isLoading = false;
  String? _errorMessage;
  List<Folder> _folders = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Folder> get folders => List.unmodifiable(_folders);

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    if (_errorMessage == message) return;
    _errorMessage = message;
    notifyListeners();
  }

  (bool, String?) loadFolders() {
    _setLoading(true);
    _setError(null);

    final result = repository.listFolders();

    _setLoading(false);

    if (!result.$1) {
      _setError(result.$3 ?? "Falha ao listar pastas");
      return (false, _errorMessage);
    }

    _folders = result.$2 ?? const [];
    notifyListeners();
    return (true, null);
  }

  (bool, String?) createFolder(String title, Color color) {
    if (title.trim().isEmpty) {
      const message = "O título da pasta não pode ser vazio";
      _setError(message);
      return (false, message);
    }

    _setError(null);
    final result = repository.createNewFolder(title.trim(), color);

    if (!result.$1) {
      _setError(result.$2);
      return (false, result.$2);
    }

    return loadFolders();
  }

  (bool, String?) updateFolder(int id, {String? title, Color? color}) {
    if (title != null && title.trim().isEmpty) {
      const message = "O título da pasta não pode ser vazio";
      _setError(message);
      return (false, message);
    }

    _setError(null);
    final result = repository.updateFolder(id, title?.trim(), color);

    if (!result.$1) {
      _setError(result.$2);
      return (false, result.$2);
    }

    return loadFolders();
  }

  (bool, Folder?, String?) getFolder(int id) {
    _setError(null);
    final result = repository.getFolder(id);

    if (!result.$1) {
      _setError(result.$3);
      return (false, null, result.$3);
    }

    return result;
  }

  (bool, String?) deleteFolder(int id) {
    _setError(null);
    final result = repository.deleteFolder(id);

    if (!result.$1) {
      _setError(result.$2);
      return (false, result.$2);
    }

    return loadFolders();
  }
}
