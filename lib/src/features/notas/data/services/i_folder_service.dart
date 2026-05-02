import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';

abstract interface class IFolderService
{
    (bool, String) createNewFolder(String title);
    (bool, String) updateFolder(int id, String newTitle);
    (bool, Folder?, String?) getFolder(int id);
    (bool, List<Folder>?, String?) listFolders(); 
    (bool, String) deleteFolder(int id);
}