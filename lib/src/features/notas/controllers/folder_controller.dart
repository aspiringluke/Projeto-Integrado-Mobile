import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/folder_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/content_stats.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';
import 'package:projeto_integrado_mobile/src/features/shared/story_registry.dart';

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
    _folders = await _syncProtectedProjectFolders(_folders);
    _syncFoldersToRegistry(_folders);
    notifyListeners();
    return (true, null);
  }

  Future<(bool, String?)> createFolder(
    String title,
    Color color, {
    int? parentFolderId,
    NoteMetadata? metadata,
  }) async {
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

    if (!result.$1 || result.$2 == null) {
      final message = result.$3 ?? 'Falha ao criar pasta';
      _setError(message);
      return (false, message);
    }

    if (metadata != null) {
      await repository.updateFolderMetadata(
        result.$2!,
        _normalizeFolderMetadata(metadata).toJsonString(),
      );
    }

    return await loadFolders(
      parentFolderId: parentFolderId ?? _currentParentFolderId,
    );
  }

  Future<(bool, String?)> updateFolder(
    int id, {
    String? title,
    Color? color,
    NoteMetadata? metadata,
  }) async {
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

    if (metadata != null) {
      await repository.updateFolderMetadata(
        id,
        _normalizeFolderMetadata(metadata).toJsonString(),
      );
    }

    final refreshed = await repository.getFolder(id);
    if (refreshed.$1 && refreshed.$2 != null) {
      _syncFoldersToRegistry(<Folder>[refreshed.$2!]);
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

    StoryRegistry.instance.removeFolder(id);
    return await loadFolders(parentFolderId: _currentParentFolderId);
  }

  Future<(bool, String?)> deleteFolderContents(int id) async {
    _setError(null);
    final result = await repository.deleteFolderContents(id);

    if (!result.$1) {
      _setError(result.$2);
      return (false, result.$2);
    }

    return await loadFolders(parentFolderId: _currentParentFolderId);
  }

  Future<(bool, String?)> moveFolderToFolder(
    int folderId,
    int? newParentFolderId,
  ) async {
    _setError(null);
    final result = await repository.moveFolderToFolder(
      folderId,
      newParentFolderId,
    );

    if (!result.$1) {
      _setError(result.$2);
      return (false, result.$2);
    }

    final refreshed = await repository.getFolder(folderId);
    if (refreshed.$1 && refreshed.$2 != null) {
      _syncFoldersToRegistry(<Folder>[refreshed.$2!]);
    }

    return await loadFolders(parentFolderId: _currentParentFolderId);
  }

  Future<(bool, String?)> touchFolder(int id) async {
    _setError(null);
    final result = await repository.touchFolder(id);

    if (!result.$1) {
      _setError(result.$2);
      return (false, result.$2);
    }

    return (true, null);
  }

  Future<(bool, String?)> setFolderPinned({
    required int folderId,
    required bool pinned,
  }) async {
    _setError(null);
    final result = await repository.getFolder(folderId);
    if (!result.$1 || result.$2 == null) {
      final message = result.$3 ?? 'Pasta não encontrada';
      _setError(message);
      return (false, message);
    }

    final folder = result.$2!;
    final updatedMetadata = folder.metadata.copyWith(pinned: pinned);
    final updateResult = await repository.updateFolderMetadata(
      folderId,
      _normalizeFolderMetadata(updatedMetadata).toJsonString(),
    );

    if (!updateResult.$1) {
      _setError(updateResult.$2);
      return (false, updateResult.$2);
    }

    final refreshed = await repository.getFolder(folderId);
    if (refreshed.$1 && refreshed.$2 != null) {
      StoryRegistry.instance.registerFolder(
        id: refreshed.$2!.id ?? folderId,
        title: refreshed.$2!.title,
        accentColor: refreshed.$2!.color,
      );
    }

    return await loadFolders(parentFolderId: _currentParentFolderId);
  }

  Future<(bool, int, String?)> countNotesInFolderTree(int id) {
    return repository.countNotesInFolderTree(id);
  }

  Future<(bool, ContentStats?, String?)> getFolderTreeStats(int id) {
    return repository.getFolderTreeStats(id);
  }

  Future<(bool, FolderPreviewData?, String?)> getFolderTreePreview(int id) {
    return repository.getFolderTreePreview(id);
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

  NoteMetadata _normalizeFolderMetadata(NoteMetadata metadata) {
    return metadata.copyWith(linkTarget: const NoteLinkTarget());
  }

  Future<List<Folder>> _syncProtectedProjectFolders(
    List<Folder> folders,
  ) async {
    final normalizedProjectTitles = StoryRegistry.instance.projects
        .map((project) => project.title.trim().toLowerCase())
        .where((title) => title.isNotEmpty)
        .toSet();
    if (normalizedProjectTitles.isEmpty) {
      return folders;
    }

    final updatedFolders = folders.toList(growable: false);
    var didUpdate = false;

    for (var index = 0; index < updatedFolders.length; index += 1) {
      final folder = updatedFolders[index];
      final folderId = folder.id;
      if (folderId == null || folderId <= 0) continue;
      if (folder.parentFolderId != null) continue;

      final normalizedTitle = folder.title.trim().toLowerCase();
      final isProjectRoot = normalizedProjectTitles.contains(normalizedTitle);
      if (!isProjectRoot) continue;

      final currentProjectRootTitle =
          folder.metadata.projectRootTitle?.trim().toLowerCase();
      if (currentProjectRootTitle == normalizedTitle) continue;

      final updatedMetadata = folder.metadata.copyWith(
        projectRootTitle: folder.title.trim(),
      );
      final updateResult = await repository.updateFolderMetadata(
        folderId,
        updatedMetadata.toJsonString(),
      );
      if (!updateResult.$1) continue;

      updatedFolders[index] = folder.copyWith(metadata: updatedMetadata);
      didUpdate = true;
    }

    if (!didUpdate) {
      return folders;
    }

    return updatedFolders;
  }

  void _syncFoldersToRegistry(Iterable<Folder> folders) {
    for (final folder in folders) {
      final folderId = folder.id;
      if (folderId == null || folderId <= 0) continue;
      StoryRegistry.instance.registerFolder(
        id: folderId,
        title: folder.title,
        accentColor: folder.color,
      );
    }
  }
}
