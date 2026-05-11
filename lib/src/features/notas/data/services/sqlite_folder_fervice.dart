import 'dart:ui';

import 'package:projeto_integrado_mobile/src/app/database/db.dart';

import 'package:projeto_integrado_mobile/src/features/notas/data/services/i_folder_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/content_stats.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';

class SqliteFolderService implements IFolderService {
  @override
  Future<(bool, int?, String?)> createNewFolder(
    String title,
    String color,
    int? parentFolderId,
  ) async {
    final conn = await getConnection();
    final now = _nowIso();
    try {
      conn.execute(
        """
                INSERT INTO Pastas(
                  titulo,
                  cor,
                  pastas_idPasta,
                  metadata,
                  createdAt,
                  lastModified,
                  lastAccessed
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
        [
          title,
          color,
          parentFolderId,
          NoteMetadata.empty().toJsonString(),
          now,
          now,
          now,
        ],
      );

      final inserted = conn.select("SELECT last_insert_rowid() AS id");
      final insertedId = inserted.first["id"] as int?;

      return (true, insertedId, "Pasta criada com sucesso");
    } catch (e) {
      return (false, null, cleanError(e));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, String)> deleteFolder(int id) async {
    final conn = await getConnection();
    try {
      conn.execute(
        """
                WITH RECURSIVE folder_tree(id) AS (
                    SELECT idPasta FROM Pastas WHERE idPasta = ?
                    UNION ALL
                    SELECT p.idPasta
                    FROM Pastas p
                    INNER JOIN folder_tree ft ON p.pastas_idPasta = ft.id
                )
                DELETE FROM Nota
                WHERE pastas_idPasta IN (SELECT id FROM folder_tree)
            """,
        [id],
      );

      conn.execute(
        """
                WITH RECURSIVE folder_tree(id) AS (
                    SELECT idPasta FROM Pastas WHERE idPasta = ?
                    UNION ALL
                    SELECT p.idPasta
                    FROM Pastas p
                    INNER JOIN folder_tree ft ON p.pastas_idPasta = ft.id
                )
                DELETE FROM Pastas
                WHERE idPasta IN (SELECT id FROM folder_tree)
            """,
        [id],
      );

      return (true, "Pasta $id excluÃ­da");
    } catch (e) {
      return (false, cleanError(e));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, bool, String?)> hasChildFolders(int id) async {
    final conn = await getConnection();
    try {
      final result = conn.select(
        """
                SELECT 1
                FROM Pastas
                WHERE pastas_idPasta = ?
                LIMIT 1
            """,
        [id],
      );

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
      final result = conn.select(
        """
                SELECT
                  idPasta,
                  titulo,
                  cor,
                  pastas_idPasta,
                  metadata,
                  createdAt,
                  lastModified,
                  lastAccessed
                FROM Pastas
                WHERE idPasta = ?
            """,
        [id],
      );

      return result.isEmpty
          ? (true, null, null)
          : (
              true,
              Folder(
                id: result.first["idPasta"],
                title: result.first["titulo"],
                color: Color(int.parse(result.first["cor"])),
                parentFolderId: result.first["pastas_idPasta"],
                metadata: NoteMetadata.fromJsonString(
                  result.first["metadata"] as String?,
                ),
                createdAt: _parseDate(result.first["createdAt"]),
                lastModified: _parseDate(result.first["lastModified"]),
                lastAccessed: _parseDate(result.first["lastAccessed"]),
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
  Future<(bool, List<Folder>?, String?)> listFolders(
    int? parentFolderId,
  ) async {
    final conn = await getConnection();
    try {
      final results = parentFolderId == null
          ? conn.select("""
                    SELECT
                      idPasta,
                      titulo,
                      cor,
                      pastas_idPasta,
                      metadata,
                      createdAt,
                      lastModified,
                      lastAccessed
                    FROM Pastas
                    WHERE pastas_idPasta IS NULL
                  """)
          : conn.select(
              """
                    SELECT
                      idPasta,
                      titulo,
                      cor,
                      pastas_idPasta,
                      metadata,
                      createdAt,
                      lastModified,
                      lastAccessed
                    FROM Pastas
                    WHERE pastas_idPasta = ?
                  """,
              [parentFolderId],
            );

      return results.isEmpty
          ? (true, null, null)
          : (
              true,
              results
                  .map(
                    (row) => Folder(
                      id: row["idPasta"],
                      title: row["titulo"],
                      color: Color(int.parse(row["cor"])),
                      parentFolderId: row["pastas_idPasta"],
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
  Future<(bool, String)> updateFolder(
    int id,
    String newTitle,
    String newColor,
  ) async {
    final conn = await getConnection();
    try {
      conn.execute(
        """
                UPDATE Pastas
                SET titulo = ?, cor = ?, lastModified = ?
                WHERE idPasta = ?
            """,
        [newTitle, newColor, _nowIso(), id],
      );

      return (true, "Pasta $id atualizada");
    } catch (e) {
      return (false, cleanError(e));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, String)> updateFolderMetadata(
    int id,
    String metadataJson,
  ) async {
    final conn = await getConnection();
    try {
      conn.execute(
        """
                UPDATE Pastas
                SET metadata = ?, lastModified = ?
                WHERE idPasta = ?
            """,
        [metadataJson, _nowIso(), id],
      );

      return (true, "Pasta $id atualizada");
    } catch (e) {
      return (false, cleanError(e));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, String)> moveFolderToFolder(
    int id,
    int? newParentFolderId,
  ) async {
    final conn = await getConnection();
    try {
      conn.execute(
        """
                UPDATE Pastas
                SET pastas_idPasta = ?, lastModified = ?
                WHERE idPasta = ?
            """,
        [newParentFolderId, _nowIso(), id],
      );

      return (true, "Pasta $id movida");
    } catch (e) {
      return (false, cleanError(e));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, String)> touchFolder(int id) async {
    final conn = await getConnection();
    try {
      conn.execute(
        """
                UPDATE Pastas SET lastAccessed = ? WHERE idPasta = ?
            """,
        [_nowIso(), id],
      );
      return (true, "Pasta $id acessada");
    } catch (e) {
      return (false, cleanError(e));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, int, String?)> countNotesInFolderTree(int id) async {
    final conn = await getConnection();
    try {
      final result = conn.select(
        """
                WITH RECURSIVE folder_tree(id) AS (
                    SELECT idPasta FROM Pastas WHERE idPasta = ?
                    UNION ALL
                    SELECT p.idPasta
                    FROM Pastas p
                    INNER JOIN folder_tree ft ON p.pastas_idPasta = ft.id
                )
                SELECT COUNT(*) AS count
                FROM Nota
                WHERE pastas_idPasta IN (SELECT id FROM folder_tree)
            """,
        [id],
      );

      final count = result.firstOrNull?["count"] as int? ?? 0;
      return (true, count, null);
    } catch (e) {
      return (false, 0, cleanError(e));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, ContentStats?, String?)> getFolderTreeStats(int id) async {
    final conn = await getConnection();
    try {
      final results = conn.select(
        """
                WITH RECURSIVE folder_tree(id) AS (
                    SELECT idPasta FROM Pastas WHERE idPasta = ?
                    UNION ALL
                    SELECT p.idPasta
                    FROM Pastas p
                    INNER JOIN folder_tree ft ON p.pastas_idPasta = ft.id
                )
                SELECT descricao
                FROM Nota
                WHERE pastas_idPasta IN (SELECT id FROM folder_tree)
            """,
        [id],
      );

      final stats = results.fold(
        const ContentStats.zero(),
        (ContentStats previous, row) =>
            previous + ContentStats.fromText(row["descricao"] as String? ?? ''),
      );
      return (true, stats, null);
    } catch (e) {
      return (false, null, cleanError(e));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, FolderPreviewData?, String?)> getFolderTreePreview(
    int id,
  ) async {
    final conn = await getConnection();
    try {
      final results = conn.select(
        """
                SELECT kind, title
                FROM (
                    SELECT
                      'note' AS kind,
                      n.titulo AS title,
                      n.lastModified AS modified,
                      n.idNota AS itemId
                    FROM Nota n
                    WHERE n.pastas_idPasta = ?
                    UNION ALL
                    SELECT
                      'folder' AS kind,
                      p.titulo AS title,
                      p.lastModified AS modified,
                      p.idPasta AS itemId
                    FROM Pastas p
                    WHERE p.pastas_idPasta = ?
                )
                ORDER BY datetime(modified) DESC, itemId DESC
                LIMIT 3
            """,
        [id, id],
      );

      if (results.isEmpty) {
        return (true, null, null);
      }

      return (
        true,
        FolderPreviewData(
          items: results
              .map(
                (row) => FolderPreviewItem(
                  kind: (row["kind"] as String? ?? '') == 'folder'
                      ? FolderPreviewItemKind.folder
                      : FolderPreviewItemKind.note,
                  title: row["title"] as String? ?? '',
                ),
              )
              .where((item) => item.title.trim().isNotEmpty)
              .toList(growable: false),
        ),
        null,
      );
    } catch (e) {
      return (false, null, cleanError(e));
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
