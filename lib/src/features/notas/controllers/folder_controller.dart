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
  int? _currentParentFolderId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Folder> get folders => List.unmodifiable(_folders);
  int? get currentParentFolderId => _currentParentFolderId;

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

  Future<(bool, String?)> loadFolders({int? parentFolderId}) async {
    _setLoading(true);
    _setError(null);
    _currentParentFolderId = parentFolderId;

    final result = await repository.listFolders(parentFolderId);

    _setLoading(false);

    if (!result.$1) {
      _setError(result.$3 ?? "Falha ao listar pastas");
      return (false, _errorMessage);
    }

    _folders = result.$2 ?? const [];
    notifyListeners();
    return (true, null);
  }

  Future<(bool, String?)> createFolder(String title, Color color, {int? parentFolderId}) async {
    if (title.trim().isEmpty) {
      const message = "O título da pasta não pode ser vazio";
      _setError(message);
      return (false, message);
    }

    _setError(null);
    final result = await repository.createNewFolder(
      title.trim(),
      color,
      parentFolderId ?? _currentParentFolderId,
    );

    if (!result.$1) {
      _setError(result.$2);
      return (false, result.$2);
    }

    return await loadFolders(parentFolderId: parentFolderId ?? _currentParentFolderId);
  }

  Future<(bool, String?)> updateFolder(int id, {String? title, Color? color}) async {
    if (title != null && title.trim().isEmpty) {
      const message = "O título da pasta não pode ser vazio";
      _setError(message);
      return (false, message);
    }

    _setError(null);
    final result = await repository.updateFolder(id, title?.trim(), color);

    if (!result.$1) {
      _setError(result.$2);
      return (false, result.$2);
    }

    return await loadFolders(parentFolderId: _currentParentFolderId);
  }

  Future<(bool, Folder?, String?)> getFolder(int id) async {
    _setError(null);
    final result = await repository.getFolder(id);

    if (!result.$1) {
      _setError(result.$3);
      return (false, null, result.$3);
    }

    return result;
  }

  Future<(bool, String?)> deleteFolder(int id) async {
    _setError(null);
    final result = await repository.deleteFolder(id);

    if (!result.$1) {
      _setError(result.$2);
      return (false, result.$2);
    }

    return await loadFolders(parentFolderId: _currentParentFolderId);
  }

  Future<(bool, String?)> moveFolderToFolder(int folderId, int? newParentFolderId) async {
    _setError(null);
    final result = await repository.moveFolderToFolder(folderId, newParentFolderId);

    if (!result.$1) {
      _setError(result.$2);
      return (false, result.$2);
    }

    return await loadFolders(parentFolderId: _currentParentFolderId);
  }

  Future<(bool, bool, String?)> hasChildFolders(int id) async {
    _setError(null);
    final result = await repository.hasChildFolders(id);

    if (!result.$1) {
      _setError(result.$3);
      return (false, false, result.$3);
    }

    return result;
  }
}
