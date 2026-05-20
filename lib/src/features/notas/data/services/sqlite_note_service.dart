import 'dart:ui';

import 'package:projeto_integrado_mobile/src/app/database/db.dart';
import 'package:sqlite3/common.dart';

import 'package:projeto_integrado_mobile/src/features/notas/data/services/i_note_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';

class SqliteNoteService implements INoteService {
  @override
  Future<(bool, int?, String?)> createNewNoteWithId(
    String titulo,
    String descricao,
    int? idPasta,
    String color, {
    String? metadataJson,
  }) async {
    final conn = await getConnection();
    final now = _nowIso();
    try {
      conn.execute(
        """
                INSERT INTO Nota(
                  titulo,
                  descricao,
                  pastas_idPasta,
                  cor,
                  metadata,
                  createdAt,
                  lastModified,
                  lastAccessed
                ) VALUES (?,?,?,?,?,?,?,?)
            """,
        [
          titulo,
          descricao,
          idPasta,
          color,
          metadataJson ?? NoteMetadata.empty().toJsonString(),
          now,
          now,
          now,
        ],
      );

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
  Future<(bool, String)> createNewNote(
    String titulo,
    String descricao,
    int? idPasta,
    String color, {
    String? metadataJson,
  }) async {
    final conn = await getConnection();
    final now = _nowIso();
    try {
      conn.execute(
        """
                INSERT INTO Nota(
                  titulo,
                  descricao,
                  pastas_idPasta,
                  cor,
                  metadata,
                  createdAt,
                  lastModified,
                  lastAccessed
                ) VALUES (?,?,?,?,?,?,?,?)
            """,
        [
          titulo,
          descricao,
          idPasta,
          color,
          metadataJson ?? NoteMetadata.empty().toJsonString(),
          now,
          now,
          now,
        ],
      );

      return (true, "Nota criada com sucesso");
    } catch (e) {
      return (false, cleanError(e));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, String)> deleteNote(int id) async {
    final conn = await getConnection();
    try {
      conn.execute(
        """
                DELETE FROM Nota WHERE idNota = ?
            """,
        [id],
      );

      return (true, "Nota $id excluída");
    } catch (e) {
      return (false, cleanError(e));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, Note?, String?)> getNote(int id) async {
    final conn = await getConnection();
    try {
      final result = conn.select(
        """
                SELECT
                  idNota,
                  titulo,
                  descricao,
                  pastas_idPasta,
                  cor,
                  metadata,
                  createdAt,
                  lastModified,
                  lastAccessed
                FROM Nota
                WHERE idNota = ?
            """,
        [id],
      );

      final note = result.firstOrNull;

      return result.isEmpty
          ? (true, null, null)
          : (
              true,
              Note(
                id: note!["idNota"],
                title: note["titulo"],
                text: note["descricao"],
                color: Color(int.parse(note["cor"])),
                idPasta: note["pastas_idPasta"],
                metadata: NoteMetadata.fromJsonString(
                  note["metadata"] as String?,
                ),
                createdAt: _parseDate(note["createdAt"]),
                lastModified: _parseDate(note["lastModified"]),
                lastAccessed: _parseDate(note["lastAccessed"]),
              ),
              null,
            );
    } catch (e) {
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
      if (idPasta == null) {
        results = conn.select("""
                    SELECT
                      idNota,
                      titulo,
                      descricao,
                      cor,
                      pastas_idPasta,
                      metadata,
                      createdAt,
                      lastModified,
                      lastAccessed
                    FROM Nota
                    WHERE pastas_idPasta IS NULL
                """);
      } else {
        results = conn.select(
          """
                    SELECT
                      idNota,
                      titulo,
                      descricao,
                      cor,
                      pastas_idPasta,
                      metadata,
                      createdAt,
                      lastModified,
                      lastAccessed
                    FROM Nota
                    WHERE pastas_idPasta = ?
                """,
          [idPasta],
        );
      }

      return results.isEmpty
          ? (true, null, null)
          : (
              true,
              results
                  .map(
                    (row) => Note(
                      id: row["idNota"],
                      title: row["titulo"],
                      text: row["descricao"],
                      color: Color(int.parse(row["cor"])),
                      idPasta: row["pastas_idPasta"],
                      metadata: NoteMetadata.fromJsonString(
                        row["metadata"] as String?,
                      ),
                      createdAt: _parseDate(row["createdAt"]),
                      lastModified: _parseDate(row["lastModified"]),
                      lastAccessed: _parseDate(row["lastAccessed"]),
                    ),
                  )
                  .toList(),
              null,
            );
    } catch (e) {
      return (false, null, cleanError(e));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, List<Note>?, String?)> listAllNotes() async {
    final conn = await getConnection();
    try {
      final results = conn.select("""
                    SELECT
                      idNota,
                      titulo,
                      descricao,
                      cor,
                      pastas_idPasta,
                      metadata,
                      createdAt,
                      lastModified,
                      lastAccessed
                    FROM Nota
                """);

      return results.isEmpty
          ? (true, null, null)
          : (
              true,
              results
                  .map(
                    (row) => Note(
                      id: row["idNota"],
                      title: row["titulo"],
                      text: row["descricao"],
                      color: Color(int.parse(row["cor"])),
                      idPasta: row["pastas_idPasta"],
                      metadata: NoteMetadata.fromJsonString(
                        row["metadata"] as String?,
                      ),
                      createdAt: _parseDate(row["createdAt"]),
                      lastModified: _parseDate(row["lastModified"]),
                      lastAccessed: _parseDate(row["lastAccessed"]),
                    ),
                  )
                  .toList(),
              null,
            );
    } catch (e) {
      return (false, null, cleanError(e));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, List<({Color color, int id, String title})>?, String?)>
  listNoteRegistryRefs() async {
    final conn = await getConnection();
    try {
      final results = conn.select("""
                    SELECT
                      idNota,
                      titulo,
                      cor
                    FROM Nota
                """);

      if (results.isEmpty) {
        return (true, null, null);
      }

      return (
        true,
        results
            .map(
              (row) => (
                id: row["idNota"] as int? ?? 0,
                title: row["titulo"] as String? ?? '',
                color: Color(int.parse(row["cor"] as String? ?? '0')),
              ),
            )
            .where((note) => note.id > 0 && note.title.trim().isNotEmpty)
            .toList(growable: false),
        null,
      );
    } catch (e) {
      return (false, null, cleanError(e));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, String)> updateNote(
    int id,
    String newTitulo,
    String newDescricao,
    int? idPasta,
    String color, {
    String? metadataJson,
  }) async {
    final conn = await getConnection();
    final now = _nowIso();
    try {
      if (idPasta == null) {
        conn.execute(
          """
                    UPDATE Nota
                    SET titulo = ?, descricao = ?, cor = ?, metadata = ?, pastas_idPasta = NULL, lastModified = ?
                    WHERE idNota = ?
                """,
          [
            newTitulo,
            newDescricao,
            color,
            metadataJson ?? NoteMetadata.empty().toJsonString(),
            now,
            id,
          ],
        );
      } else {
        conn.execute(
          """
                    UPDATE Nota
                    SET titulo = ?, descricao = ?, cor = ?, metadata = ?, pastas_idPasta = ?, lastModified = ?
                    WHERE idNota = ?
                """,
          [
            newTitulo,
            newDescricao,
            color,
            metadataJson ?? NoteMetadata.empty().toJsonString(),
            idPasta,
            now,
            id,
          ],
        );
      }
      return (true, "Nota $id atualizada");
    } catch (e) {
      return (false, cleanError(e));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, String)> touchNote(int id) async {
    final conn = await getConnection();
    try {
      conn.execute(
        """
                UPDATE Nota SET lastAccessed = ? WHERE idNota = ?
            """,
        [_nowIso(), id],
      );
      return (true, "Nota $id acessada");
    } catch (e) {
      return (false, cleanError(e));
    } finally {
      conn.close();
    }
  }

  String cleanError(Object error) {
    return error.toString().replaceAll("Exception: ", "");
  }
}

DateTime _parseDate(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  return DateTime.now();
}

String _nowIso() => DateTime.now().toIso8601String();
