import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/content_stats.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';

abstract interface class IFolderService {
  Future<(bool, int?, String?)> createNewFolder(String title, String color, int? parentFolderId, [NoteMetadata? metadata]);
  Future<(bool, String)> updateFolder(int id, String newTitle, String newColor);
  Future<(bool, String)> updateFolderMetadata(int id, String metadataJson);
  Future<(bool, String)> moveFolderToFolder(int id, int? newParentFolderId);
  Future<(bool, bool, String?)> hasChildFolders(int id);
  Future<(bool, Folder?, String?)> getFolder(int id);
  Future<(bool, List<Folder>?, String?)> listFolders(int? parentFolderId);
  Future<(bool, String)> deleteFolder(int id);
  Future<(bool, String)> deleteFolderContents(int id);
  Future<(bool, String)> touchFolder(int id);
  Future<(bool, int, String?)> countNotesInFolderTree(int id);
  Future<(bool, ContentStats?, String?)> getFolderTreeStats(int id);
  Future<(bool, FolderPreviewData?, String?)> getFolderTreePreview(int id);
}
