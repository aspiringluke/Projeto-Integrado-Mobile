import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';

abstract interface class IFolderService
{
    Future<(bool, String)> createNewFolder(String title, String color, int? parentFolderId);
    Future<(bool, String)> updateFolder(int id, String newTitle, String newColor);
    Future<(bool, String)> moveFolderToFolder(int id, int? newParentFolderId);
    Future<(bool, bool, String?)> hasChildFolders(int id);
    Future<(bool, Folder?, String?)> getFolder(int id);
    Future<(bool, List<Folder>?, String?)> listFolders(int? parentFolderId); 
    Future<(bool, String)> deleteFolder(int id);
}
