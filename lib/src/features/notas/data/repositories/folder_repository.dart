import 'package:projeto_integrado_mobile/src/features/notas/data/services/i_folder_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';

abstract interface class FolderRepository
{
    final IFolderService service;

    FolderRepository({
        required this.service
    });

    bool createNewFolder(String title)
    {
        return service.createNewFolder(title);
    }

    bool updateFolder(int id)
    {
        return service.updateFolder(id);
    }

    Folder getFolder(int id)
    {
        final folder = service.getFolder(id);
        // TODO: Erro caso não encontre
        // TODO: Não esquece de mudar isso aqui
        return Folder(title: folder[0].toString());
    }
    List<Folder> listFolders()
    {
        final folders = service.listFolders();
        // TODO: Erro caso esteja vazio
        // TODO: Não esquece de mudar isso aqui
        return folders.map(
            (row) => Folder(
                title: row[0].toString()
            )
        ).toList();
    }

    bool deleteFolder(int id)
    {
        return service.deleteFolder(id);
    }
}