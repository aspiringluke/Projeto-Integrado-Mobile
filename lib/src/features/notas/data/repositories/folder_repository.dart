import 'dart:ui';

import 'package:projeto_integrado_mobile/src/features/notas/data/services/i_folder_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/services/sqlite_folder_fervice.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';

class FolderRepository
{
    final IFolderService service;

    FolderRepository({
        IFolderService? service,
    }) : service = service ?? SqliteFolderService();

    (bool, String) createNewFolder(String title, Color color)
    {
        return service.createNewFolder(title, color.toARGB32().toString());
    }

    (bool, String) updateFolder(int id, String? title, Color? color)
    {
        final result = getFolder(id);

        if(result.$1 == false)
        {
            return (false, result.$3 ?? "Erro ao buscar pasta");
        }

        if(result.$2 == null)
        {
            return (false, "Pasta não encontrada");
        }

        final oldValues = result.$2!;

        return service.updateFolder(
            id,
            title ?? oldValues.title,
            (color ?? oldValues.color).toARGB32().toString(),
        );
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
