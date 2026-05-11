import 'dart:ui';

import 'package:projeto_integrado_mobile/src/features/notas/data/services/i_folder_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/services/sqlite_folder_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/content_stats.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';

class FolderRepository {
  final IFolderService service;

  FolderRepository({IFolderService? service})
    : service = service ?? SqliteFolderService();

  Future<(bool, int?, String?)> createNewFolder(
    String title,
    Color color,
    int? parentFolderId,
  ) {
    return service.createNewFolder(
      title,
      color.toARGB32().toString(),
      parentFolderId,
    );
  }

  Future<(bool, String)> updateFolder(
    int id,
    String? title,
    Color? color,
  ) async {
    final result = await getFolder(id);

    if (result.$1 == false) {
      return (false, result.$3 ?? "Erro ao buscar pasta");
    }

    if (result.$2 == null) {
      return (false, "Pasta não encontrada");
    }

    final oldValues = result.$2!;

    return await service.updateFolder(
      id,
      title ?? oldValues.title,
      (color ?? oldValues.color).toARGB32().toString(),
    );
  }

  Future<(bool, String)> updateFolderMetadata(int id, String metadataJson) {
    return service.updateFolderMetadata(id, metadataJson);
  }

  Future<(bool, Folder?, String?)> getFolder(int id) {
    return service.getFolder(id);
  }

  Future<(bool, List<Folder>?, String?)> listFolders(int? parentFolderId) {
    return service.listFolders(parentFolderId);
  }

  Future<(bool, String)> deleteFolder(int id) {
    return service.deleteFolder(id);
  }

  Future<(bool, String)> touchFolder(int id) {
    return service.touchFolder(id);
  }

  Future<(bool, int, String?)> countNotesInFolderTree(int id) {
    return service.countNotesInFolderTree(id);
  }

  Future<(bool, ContentStats?, String?)> getFolderTreeStats(int id) {
    return service.getFolderTreeStats(id);
  }

  Future<(bool, FolderPreviewData?, String?)> getFolderTreePreview(int id) {
    return service.getFolderTreePreview(id);
  }

  Future<Folder?> findRootFolderByTitle(String title) async {
    final result = await listFolders(null);
    if (!result.$1 || result.$2 == null) {
      return null;
    }

    final normalizedTitle = title.trim().toLowerCase();
    for (final folder in result.$2!) {
      if (folder.title.trim().toLowerCase() == normalizedTitle) {
        return folder;
      }
    }

    return null;
  }

  Future<Folder?> ensureRootFolder({
    required String title,
    required Color color,
  }) async {
    final existing = await findRootFolderByTitle(title);
    if (existing != null) {
      return existing;
    }

    final created = await createNewFolder(title, color, null);
    if (!created.$1 || created.$2 == null) {
      return null;
    }

    return await findRootFolderByTitle(title);
  }

  Future<(bool, String)> moveFolderToFolder(int id, int? parentFolderId) async {
    final current = await getFolder(id);
    if (current.$1 == false) {
      return (false, current.$3 ?? "Erro ao buscar pasta");
    }

    if (current.$2 == null) {
      return (false, "Pasta não encontrada");
    }

    if (parentFolderId == id) {
      return (false, "Uma pasta não pode conter ela mesma");
    }

    return await service.moveFolderToFolder(id, parentFolderId);
  }

  Future<(bool, bool, String?)> hasChildFolders(int id) =>
      service.hasChildFolders(id);
}
