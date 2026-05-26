import 'dart:ui';

import 'package:projeto_integrado_mobile/src/features/notas/data/services/i_folder_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/content_stats.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';

class FakeFolderService implements IFolderService {
  final Map<int, Folder> _folders = <int, Folder>{};
  int _nextId = 1;

  @override
  Future<(bool, int?, String?)> createNewFolder(
    String title,
    String color,
    int? parentFolderId, [
    Object? metadata,
  ]) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return (false, null, 'O título da pasta não pode ser vazio');
    }
    final typedMetadata = metadata as NoteMetadata?;
    final id = _nextId++;
    _folders[id] = Folder(
      id: id,
      title: trimmedTitle,
      color: Color(int.parse(color)),
      parentFolderId: parentFolderId,
      metadata: typedMetadata ??
          const NoteMetadata(
            tagGroups: <NoteTagGroup>[],
            linkTarget: NoteLinkTarget(),
          ),
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      lastAccessed: DateTime.now(),
    );
    return (true, id, null);
  }

  @override
  Future<(bool, String)> updateFolder(int id, String newTitle, String newColor) async {
    final folder = _folders[id];
    if (folder == null) {
      return (false, 'Pasta não encontrada');
    }
    _folders[id] = folder.copyWith(
      title: newTitle,
      color: Color(int.parse(newColor)),
      lastModified: DateTime.now(),
    );
    return (true, 'OK');
  }

  @override
  Future<(bool, String)> updateFolderMetadata(int id, String metadataJson) async {
    if (!_folders.containsKey(id)) {
      return (false, 'Pasta não encontrada');
    }
    return (true, 'OK');
  }

  @override
  Future<(bool, Folder?, String?)> getFolder(int id) async {
    final folder = _folders[id];
    if (folder == null) {
      return (false, null, 'Pasta não encontrada');
    }
    return (true, folder, null);
  }

  @override
  Future<(bool, List<Folder>?, String?)> listFolders(int? parentFolderId) async {
    final folders = _folders.values.where((folder) {
      if (parentFolderId == null) {
        return folder.parentFolderId == null;
      }
      return folder.parentFolderId == parentFolderId;
    }).toList(growable: false);
    return (true, folders, null);
  }

  @override
  Future<(bool, String)> deleteFolder(int id) async {
    if (!_folders.containsKey(id)) {
      return (false, 'Pasta não encontrada');
    }
    _folders.remove(id);
    return (true, 'OK');
  }

  @override
  Future<(bool, String)> deleteFolderContents(int id) async {
    return (true, 'OK');
  }

  @override
  Future<(bool, String)> touchFolder(int id) async {
    final folder = _folders[id];
    if (folder == null) {
      return (false, 'Pasta não encontrada');
    }
    _folders[id] = folder.copyWith(lastAccessed: DateTime.now());
    return (true, 'OK');
  }

  @override
  Future<(bool, bool, String?)> hasChildFolders(int id) async {
    final hasChild = _folders.values.any((folder) => folder.parentFolderId == id);
    return (true, hasChild, null);
  }

  @override
  Future<(bool, int, String?)> countNotesInFolderTree(int id) async {
    return (true, 0, null);
  }

  @override
  Future<(bool, ContentStats?, String?)> getFolderTreeStats(int id) async {
    return (true, null, null);
  }

  @override
  Future<(bool, FolderPreviewData?, String?)> getFolderTreePreview(int id) async {
    return (true, const FolderPreviewData(items: []), null);
  }

  @override
  Future<(bool, String)> moveFolderToFolder(int id, int? newParentFolderId) async {
    final folder = _folders[id];
    if (folder == null) {
      return (false, 'Pasta não encontrada');
    }
    _folders[id] = folder.copyWith(
      parentFolderId: newParentFolderId,
      lastModified: DateTime.now(),
    );
    return (true, 'OK');
  }
}
