import 'dart:ui';

import 'package:projeto_integrado_mobile/src/app/database/db.dart';

import 'package:projeto_integrado_mobile/src/features/notas/data/services/i_folder_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';

class SqliteFolderService implements IFolderService
{
    @override
    (bool, String) createNewFolder(String title, String color) {
        final conn = getConnection();
        try {
            conn.execute("""
                INSERT INTO Pastas(titulo, cor) VALUES (?, ?)
            """, [title, color]);
            
            return (true, "Pasta criada com sucesso");
        } catch(e) {
            return (false, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    (bool, String) deleteFolder(int id) {
        final conn = getConnection();
        try {
            conn.execute("""
                DELETE FROM Pastas WHERE idPasta = ?
            """, [id]);
            
            return (true, "Pasta $id excluída");
        } catch(e) {
            return (false, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    (bool, Folder?, String?) getFolder(int id) {
        final conn = getConnection();
        try {
            final result = conn.select("""
                SELECT idPasta, titulo, cor FROM Pastas WHERE idPasta = ?
            """, [id]);
            
            return result.isEmpty
                   ? (true, null, null)
                   : (true, Folder(
                        id: result.first["idPasta"],
                        title: result.first["titulo"],
                        color: Color(int.parse(result.first["cor"])),
                     ), null);
        } catch(e) {
            return (false, null, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    (bool, List<Folder>?, String?) listFolders() {
        final conn = getConnection();
        try {
            final results = conn.select("""
                SELECT idPasta, titulo, cor FROM Pastas
            """);
            
            return results.isEmpty
                    ? (true, null, null)
                    : (true, results.map(
                        (row) => Folder(
                            id: row["idPasta"],
                            title: row["titulo"],
                            color: Color(int.parse(row["cor"])),
                        )
                      ).toList(), null);
        } catch(e) {
            return (false, null, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    (bool, String) updateFolder(int id, String newTitle, String newColor) {
        final conn = getConnection();
        try {
            conn.execute("""
                UPDATE Pastas SET titulo = ?, cor = ? WHERE idPasta = ?
            """, [newTitle, newColor, id]);
            
            return (true, "Pasta $id atualizada");
        } catch(e) {
            return (false, cleanError(e));
        } finally {
            conn.close();
        }
    }
    
    String cleanError(Object error)
    {
        return error.toString().replaceAll("Exception: ", "");
    }
}
