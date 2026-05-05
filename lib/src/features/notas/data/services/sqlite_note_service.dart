import 'dart:ui';

import 'package:sqlite3/sqlite3.dart';
import 'package:projeto_integrado_mobile/src/app/database/db.dart';

import 'package:projeto_integrado_mobile/src/features/notas/data/services/i_note_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note.dart';

class Sqlitefolderservice implements INoteService
{
    @override
    Future<(bool, int?, String?)> createNewNoteWithId(
        String titulo,
        String descricao,
        int? idPasta,
        String color,
    ) async {
        final conn = await getConnection();
        try {
            conn.execute("""
                INSERT INTO Nota(titulo, descricao, pastas_idPasta, cor) VALUES (?,?,?,?)
            """, [titulo, descricao, idPasta, color]);

            final inserted = conn.select("SELECT last_insert_rowid() AS id");
            final insertedId = inserted.first["id"] as int?;

            return (true, insertedId, null);
        } catch (e) {
            return (false, null, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    Future<(bool, String)> createNewNote(String titulo, String descricao, int? idPasta, String color) async {
        final conn = await getConnection();
        try {
            conn.execute("""
                INSERT INTO Nota(titulo, descricao, pastas_idPasta, cor) VALUES (?,?,?,?)
            """, [titulo, descricao, idPasta, color]);
            
            return (true, "Nota criada com sucesso");
        } catch(e) {
            return (false, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    Future<(bool, String)> deleteNote(int id) async {
        final conn = await getConnection();
        try {
            conn.execute("""
                DELETE FROM Nota WHERE idNota = ?
            """, [id]);
            
            return (true, "Nota $id excluída");
        } catch(e) {
            return (false, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    Future<(bool, Note?, String?)> getNote(int id) async {
        final conn = await getConnection();
        try {
            final result = conn.select("""
                SELECT idNota, titulo, descricao, pastas_idPasta, cor FROM Nota
                WHERE idNota = ?
            """, [id]);

            final note = result.firstOrNull;

            return result.isEmpty
                   ? (true, null, null)
                   : (true,Note(
                        id: note!["idNota"],
                        title: note["titulo"],
                        text: note["descricao"],
                        color: Color(int.parse(note["cor"])),
                        idPasta: note["pastas_idPasta"]
                     ), null);
        } catch(e) {
            return (false, null, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    Future<(bool, List<Note>?, String?)> listNotes(int? idPasta) async {
        final conn = await getConnection();
        try {
            final ResultSet results;
            if(idPasta == null)
            {
                results = conn.select("""
                    SELECT idNota, titulo, descricao, cor, pastas_idPasta FROM Nota
                    WHERE pastas_idPasta IS NULL
                """);
            }
            else
            {
                results = conn.select("""
                    SELECT idNota, titulo, descricao, cor, pastas_idPasta FROM Nota
                    WHERE pastas_idPasta = ?
                """, [idPasta]);
            }
            
            return results.isEmpty
                    ? (true, null, null)
                    : (true, results.map(
                        (row) => Note(
                            id: row["idNota"],
                            title: row["titulo"],
                            text: row["descricao"],
                            color: Color(int.parse(row["cor"])),
                            idPasta: row["pastas_idPasta"]
                        )
                      ).toList(), null);
        } catch(e) {
            return (false, null, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    Future<(bool, String)> updateNote(int id, String newTitulo, String newDescricao, int? idPasta, String color) async {
        final conn = await getConnection();
        try {
            if(idPasta == null)
            {
                conn.execute("""
                    UPDATE Nota SET titulo = ?, descricao = ?, cor = ?, pastas_idPasta = NULL WHERE idNota = ?
                """, [newTitulo, newDescricao, color, id]);
            }
            else
            {
                conn.execute("""
                    UPDATE Nota SET titulo = ?, descricao = ?, cor = ?, pastas_idPasta = ? WHERE idNota = ?
                """, [newTitulo, newDescricao, color, idPasta, id]);
            }
            return (true, "Nota $id atualizada");
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
