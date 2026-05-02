import 'package:projeto_integrado_mobile/src/features/notas/data/services/i_folder_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';

abstract interface class FolderRepository
{
    final IFolderService service;

    FolderRepository({
        required this.service
    });

    (bool, String) createNewFolder(String title)
    {
        return service.createNewFolder(title);
    }

    (bool, String) updateFolder(int id, String title)
    {
        return service.updateFolder(id, title);
    }

    (bool, Folder?, String?) getFolder(int id)
    {
        return service.getFolder(id);
    }

    (bool, List<Folder>?, String?) listFolders()
    {
        return service.listFolders();
    }

    (bool, String) deleteFolder(int id)
    {
        return service.deleteFolder(id);
    }
}