import 'package:projeto_integrado_mobile/src/app/database/db.dart';

import 'package:projeto_integrado_mobile/src/features/notas/data/services/i_note_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note.dart';

class Sqlitefolderservice implements INoteService
{
    @override
    (bool, String) createNewNote(String text, int? idPasta) {
        final conn = getConnection();
        try {
            conn.execute("""
                INSERT INTO Nota VALUES (?,?)
            """, [text, idPasta]);
            
            return (true, "Nota criada com sucesso");
        } catch(e) {
            return (false, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    (bool, String) deleteNote(int id) {
        final conn = getConnection();
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
    (bool, Note?, String?) getNote(int id) {
        final conn = getConnection();
        try {
            final result = conn.select("""
                SELECT text, pastas_idPasta FROM Nota WHERE idNota = ?
            """, [id]);
            
            return result.isEmpty
                   ? (true, null, null)
                   : (true, Note(id: result.first["idNota"], text: result.first["text"]), null);
        } catch(e) {
            return (false, null, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    (bool, List<Note>?, String?) listNotes() {
        final conn = getConnection();
        try {
            final results = conn.select("""
                SELECT idNota, text FROM Nota
            """);
            
            return results.isEmpty
                    ? (true, null, null)
                    : (true, results.map(
                        (row) => Note(id: row["idNota"], text: row["text"])
                      ).toList(), null);
        } catch(e) {
            return (false, null, cleanError(e));
        } finally {
            conn.close();
        }
    }

    @override
    (bool, String) updateNote(int id, String newText, int? idPasta) {
        final conn = getConnection();
        try {
            if(idPasta == null)
            {
                conn.execute("""
                    UPDATE Nota SET text = ? WHERE idNota = ?
                """, [newText, id]);
            }
            else
            {
                conn.execute("""
                    UPDATE Nota SET text = ?, pastas_idPasta = ? WHERE idNota = ?
                """, [newText, idPasta, id]);
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