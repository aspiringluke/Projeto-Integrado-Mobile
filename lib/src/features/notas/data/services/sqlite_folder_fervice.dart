import 'dart:ui';

import 'package:projeto_integrado_mobile/src/app/database/db.dart';

import 'package:projeto_integrado_mobile/src/features/notas/data/services/i_folder_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';

class SqliteFolderService implements IFolderService
{
    @override
    Future<(bool, String)> createNewFolder(String title, String color, int? parentFolderId) async {
        final conn = await getConnection();
        try {
            conn.execute("""
                INSERT INTO Pastas(titulo, cor, pastas_idPasta) VALUES (?, ?, ?)
            """, [title, color, parentFolderId]);
            
            return (true, "Pasta criada com sucesso");
        } catch(e) {
            return (false, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    Future<(bool, String)> deleteFolder(int id) async {
        final conn = await getConnection();
        try {
            conn.execute("""
                WITH RECURSIVE folder_tree(id) AS (
                    SELECT idPasta FROM Pastas WHERE idPasta = ?
                    UNION ALL
                    SELECT p.idPasta
                    FROM Pastas p
                    INNER JOIN folder_tree ft ON p.pastas_idPasta = ft.id
                )
                DELETE FROM Nota
                WHERE pastas_idPasta IN (SELECT id FROM folder_tree)
            """, [id]);

            conn.execute("""
                WITH RECURSIVE folder_tree(id) AS (
                    SELECT idPasta FROM Pastas WHERE idPasta = ?
                    UNION ALL
                    SELECT p.idPasta
                    FROM Pastas p
                    INNER JOIN folder_tree ft ON p.pastas_idPasta = ft.id
                )
                DELETE FROM Pastas
                WHERE idPasta IN (SELECT id FROM folder_tree)
            """, [id]);
            
            return (true, "Pasta $id excluída");
        } catch(e) {
            return (false, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    Future<(bool, bool, String?)> hasChildFolders(int id) async {
        final conn = await getConnection();
        try {
            final result = conn.select("""
                SELECT 1
                FROM Pastas
                WHERE pastas_idPasta = ?
                LIMIT 1
            """, [id]);

            return (true, result.isNotEmpty, null);
        } catch (e) {
            return (false, false, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    Future<(bool, Folder?, String?)> getFolder(int id) async {
        final conn = await getConnection();
        try {
            final result = conn.select("""
                SELECT idPasta, titulo, cor, pastas_idPasta FROM Pastas WHERE idPasta = ?
            """, [id]);
            
            return result.isEmpty
                   ? (true, null, null)
                   : (true, Folder(
                        id: result.first["idPasta"],
                        title: result.first["titulo"],
                        color: Color(int.parse(result.first["cor"])),
                        parentFolderId: result.first["pastas_idPasta"],
                     ), null);
        } catch(e) {
            return (false, null, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    Future<(bool, List<Folder>?, String?)> listFolders(int? parentFolderId) async {
        final conn = await getConnection();
        try {
            final results = parentFolderId == null
                ? conn.select("""
                    SELECT idPasta, titulo, cor, pastas_idPasta FROM Pastas
                    WHERE pastas_idPasta IS NULL
                  """)
                : conn.select("""
                    SELECT idPasta, titulo, cor, pastas_idPasta FROM Pastas
                    WHERE pastas_idPasta = ?
                  """, [parentFolderId]);
            
            return results.isEmpty
                    ? (true, null, null)
                    : (true, results.map(
                        (row) => Folder(
                            id: row["idPasta"],
                            title: row["titulo"],
                            color: Color(int.parse(row["cor"])),
                            parentFolderId: row["pastas_idPasta"],
                        )
                      ).toList(), null);
        } catch(e) {
            return (false, null, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    Future<(bool, String)> updateFolder(int id, String newTitle, String newColor) async {
        final conn = await getConnection();
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

    @override
    Future<(bool, String)> moveFolderToFolder(int id, int? newParentFolderId) async {
        final conn = await getConnection();
        try {
            conn.execute("""
                UPDATE Pastas SET pastas_idPasta = ? WHERE idPasta = ?
            """, [newParentFolderId, id]);

            return (true, "Pasta $id movida");
        } catch (e) {
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
