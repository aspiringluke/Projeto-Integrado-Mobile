import 'dart:ui';

import 'package:projeto_integrado_mobile/src/features/notas/data/services/i_folder_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/services/sqlite_folder_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/content_stats.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';
import 'package:projeto_integrado_mobile/src/features/shared/story_registry.dart';

class FolderRepository {
  final IFolderService service;

  FolderRepository({IFolderService? service})
    : service = service ?? SqliteFolderService();

  Future<(bool, int?, String?)> createNewFolder(
    String title,
    Color color,
    int? parentFolderId, [
    NoteMetadata? metadata,
  ]) {
    return service.createNewFolder(
      title,
      color.toARGB32().toString(),
      parentFolderId,
      metadata,
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
    return _deleteFolderWithProtection(id);
  }

  Future<(bool, String)> deleteFolderIgnoringProtection(int id) {
    return service.deleteFolder(id);
  }

  Future<(bool, String)> deleteFolderContents(int id) {
    return service.deleteFolderContents(id);
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
      final folderTitle = folder.title.trim().toLowerCase();
      final projectRootTitle = folder.metadata.projectRootTitle
          ?.trim()
          .toLowerCase();
      final characterRootName = folder.metadata.characterRootName
          ?.trim()
          .toLowerCase();
      if (folderTitle == normalizedTitle ||
          projectRootTitle == normalizedTitle ||
          characterRootName == normalizedTitle) {
        return folder;
      }
    }

    return null;
  }

  Future<Folder?> findCharacterRootFolder({
    required String characterName,
    String? projectTitle,
  }) async {
    final result = await listFolders(null);
    if (!result.$1 || result.$2 == null) {
      return null;
    }

    final normalizedName = characterName.trim().toLowerCase();
    final normalizedProject = projectTitle?.trim().toLowerCase();
    if (normalizedName.isEmpty) {
      return null;
    }

    for (final folder in result.$2!) {
      final characterRootName = folder.metadata.characterRootName
          ?.trim()
          .toLowerCase();
      if (characterRootName != normalizedName) {
        continue;
      }

      final folderProjectTitle = folder.metadata.linkTarget.projectTitle
          ?.trim()
          .toLowerCase();
      if (normalizedProject == null ||
          normalizedProject.isEmpty ||
          folderProjectTitle == normalizedProject) {
        return folder;
      }
    }

    for (final folder in result.$2!) {
      if (folder.parentFolderId != null || folder.metadata.isProjectRoot) {
        continue;
      }

      if (folder.title.trim().toLowerCase() == normalizedName) {
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
      if (existing.id != null &&
          (existing.metadata.projectRootTitle?.trim().toLowerCase() !=
                  title.trim().toLowerCase() ||
              !existing.metadata.protectedFolder)) {
        await updateFolderMetadata(
          existing.id!,
          existing.metadata
              .copyWith(projectRootTitle: title.trim(), protectedFolder: true)
              .toJsonString(),
        );
      }
      await _ensureDefaultProjectFolders(existing.id!, title.trim(), color);
      return existing;
    }

    final created = await createNewFolder(
      title,
      color,
      null,
      NoteMetadata(
        tagGroups: const <NoteTagGroup>[],
        linkTarget: const NoteLinkTarget(),
        projectRootTitle: title.trim(),
        protectedFolder: true,
      ),
    );
    if (!created.$1 || created.$2 == null) {
      return null;
    }

    final root = await findRootFolderByTitle(title);
    if (root?.id != null) {
      await _ensureDefaultProjectFolders(root!.id!, title.trim(), color);
    }
    return root;
  }

  Future<Folder?> ensureCharacterRootFolder({
    required String characterName,
    required Color color,
    String? projectTitle,
  }) async {
    final normalizedName = characterName.trim();
    if (normalizedName.isEmpty) {
      return null;
    }

    int? projectFolderId;
    final normalizedProjectTitle = projectTitle?.trim();
    if (normalizedProjectTitle != null && normalizedProjectTitle.isNotEmpty) {
      final ensuredProjectFolder = await ensureRootFolder(
        title: normalizedProjectTitle,
        color: color,
      );
      projectFolderId = ensuredProjectFolder?.id;
      if (projectFolderId == null) {
        return null;
      }
    }

    int? charactersFolderId = projectFolderId;
    if (projectFolderId != null) {
      final ensuredCharactersFolder = await _ensureChildFolder(
        parentFolderId: projectFolderId,
        title: 'Personagens',
        color: color,
        metadata: NoteMetadata(
          tagGroups: const <NoteTagGroup>[],
          linkTarget: NoteLinkTarget(projectTitle: normalizedProjectTitle),
          protectedFolder: true,
        ),
      );
      charactersFolderId = ensuredCharactersFolder?.id;
      if (charactersFolderId == null) {
        return null;
      }
    }

    final existing =
        await _findCharacterFolderUnderParent(
          parentFolderId: charactersFolderId,
          characterName: normalizedName,
        ) ??
        await _findCharacterFolderUnderParent(
          parentFolderId: projectFolderId,
          characterName: normalizedName,
        ) ??
        await findCharacterRootFolder(
          characterName: normalizedName,
          projectTitle: normalizedProjectTitle,
        );
    if (existing != null) {
      final existingId = existing.id;
      if (existingId != null) {
        final metadata = existing.metadata.copyWith(
          characterRootName: normalizedName,
          protectedFolder: true,
          linkTarget: NoteLinkTarget(
            projectTitle:
                normalizedProjectTitle == null || normalizedProjectTitle.isEmpty
                ? existing.metadata.linkTarget.projectTitle
                : normalizedProjectTitle,
            characterName: normalizedName,
          ),
        );
        await updateFolderMetadata(existingId, metadata.toJsonString());
        if (charactersFolderId != null &&
            existing.parentFolderId != charactersFolderId) {
          await moveFolderToFolder(existingId, charactersFolderId);
        }
        final refreshed = await getFolder(existingId);
        if (refreshed.$1 && refreshed.$2 != null) {
          return refreshed.$2;
        }
      }
      return existing;
    }

    final created = await createNewFolder(
      normalizedName,
      color,
      charactersFolderId,
      NoteMetadata(
        tagGroups: const <NoteTagGroup>[],
        linkTarget: NoteLinkTarget(
          projectTitle: normalizedProjectTitle,
          characterName: normalizedName,
        ),
        characterRootName: normalizedName,
        protectedFolder: true,
      ),
    );
    if (!created.$1 || created.$2 == null) {
      return null;
    }

    final fetched = await getFolder(created.$2!);
    return fetched.$2;
  }

  Future<void> _ensureDefaultProjectFolders(
    int rootFolderId,
    String projectTitle,
    Color color,
  ) async {
    await _ensureChildFolder(
      parentFolderId: rootFolderId,
      title: 'Personagens',
      color: color,
      metadata: NoteMetadata(
        tagGroups: const <NoteTagGroup>[],
        linkTarget: NoteLinkTarget(projectTitle: projectTitle),
        protectedFolder: true,
      ),
    );
    await _ensureChildFolder(
      parentFolderId: rootFolderId,
      title: 'Enredo',
      color: color,
      metadata: NoteMetadata(
        tagGroups: const <NoteTagGroup>[],
        linkTarget: NoteLinkTarget(projectTitle: projectTitle),
        protectedFolder: true,
      ),
    );
    await _ensureChildFolder(
      parentFolderId: rootFolderId,
      title: 'Mundo',
      color: color,
      metadata: NoteMetadata(
        tagGroups: const <NoteTagGroup>[],
        linkTarget: NoteLinkTarget(projectTitle: projectTitle),
        protectedFolder: true,
      ),
    );
  }

  Future<Folder?> _ensureChildFolder({
    required int parentFolderId,
    required String title,
    required Color color,
    required NoteMetadata metadata,
  }) async {
    final existing = await _findFolderByTitleUnderParent(parentFolderId, title);
    if (existing != null) {
      if (existing.id != null) {
        await updateFolderMetadata(existing.id!, metadata.toJsonString());
      }
      return existing;
    }

    final created = await createNewFolder(
      title,
      color,
      parentFolderId,
      metadata,
    );
    if (!created.$1 || created.$2 == null) {
      return null;
    }

    final fetched = await getFolder(created.$2!);
    return fetched.$2;
  }

  Future<Folder?> _findFolderByTitleUnderParent(
    int parentFolderId,
    String title,
  ) async {
    final result = await listFolders(parentFolderId);
    if (!result.$1 || result.$2 == null) {
      return null;
    }

    final normalizedTitle = title.trim().toLowerCase();
    for (final folder in result.$2!) {
      final folderTitle = folder.title.trim().toLowerCase();
      if (folderTitle == normalizedTitle) {
        return folder;
      }
    }

    return null;
  }

  Future<Folder?> _findCharacterFolderUnderParent({
    required int? parentFolderId,
    required String characterName,
  }) async {
    if (parentFolderId == null) {
      return null;
    }

    final result = await listFolders(parentFolderId);
    if (!result.$1 || result.$2 == null) {
      return null;
    }

    final normalizedName = characterName.trim().toLowerCase();
    for (final folder in result.$2!) {
      final folderTitle = folder.title.trim().toLowerCase();
      final characterRootName = folder.metadata.characterRootName
          ?.trim()
          .toLowerCase();
      if (folderTitle == normalizedName ||
          characterRootName == normalizedName) {
        return folder;
      }
    }

    return null;
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

  Future<(bool, String)> _deleteFolderWithProtection(int id) async {
    final current = await getFolder(id);
    if (current.$1 == false) {
      return (false, current.$3 ?? "Erro ao buscar pasta");
    }

    final folder = current.$2;
    if (folder == null) {
      return (false, "Pasta não encontrada");
    }

    if (_isProtectedFolder(folder)) {
      return (
        false,
        "Esta pasta de projeto não pode ser excluída. Apague o conteúdo da pasta em vez disso.",
      );
    }

    return await service.deleteFolder(id);
  }

  bool _isProtectedFolder(Folder folder) {
    if (folder.metadata.isProtectedRoot) {
      return true;
    }

    if (folder.parentFolderId != null) {
      return false;
    }

    final normalizedTitle = folder.title.trim().toLowerCase();
    if (normalizedTitle.isEmpty) {
      return false;
    }

    return StoryRegistry.instance.projects.any(
          (project) => project.title.trim().toLowerCase() == normalizedTitle,
        ) ||
        StoryRegistry.instance.characters.any(
          (character) => character.name.trim().toLowerCase() == normalizedTitle,
        );
  }
}
