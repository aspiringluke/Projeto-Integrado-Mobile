import 'dart:ui';

import 'package:projeto_integrado_mobile/src/app/database/db.dart';
import 'package:projeto_integrado_mobile/src/features/tags/data/services/i_tag_service.dart';
import 'package:projeto_integrado_mobile/src/features/tags/models/tag_model.dart';

class TagService implements ITagService {
  @override
  Future<(bool, TagModel?, String?)> upsertTag({
    required String label,
    required Color color,
    int? groupId,
  }) async {
    final sanitizedLabel = sanitizeTagLabel(label);
    if (sanitizedLabel.isEmpty) {
      return (false, null, 'Tag inválida');
    }

    final conn = await getConnection();
    try {
      final existing = conn.select(
        groupId == null
            ? '''
              SELECT idTag, descricao, cor, grupoTag_idGrupoTag
              FROM Tags
              WHERE LOWER(TRIM(descricao)) = LOWER(TRIM(?))
                AND grupoTag_idGrupoTag IS NULL
              LIMIT 1
              '''
            : '''
              SELECT idTag, descricao, cor, grupoTag_idGrupoTag
              FROM Tags
              WHERE LOWER(TRIM(descricao)) = LOWER(TRIM(?))
                AND grupoTag_idGrupoTag = ?
              LIMIT 1
              ''',
        groupId == null ? [sanitizedLabel] : [sanitizedLabel, groupId],
      );

      if (existing.isNotEmpty) {
        final row = existing.first;
        final id = row['idTag'] as int?;
        final currentColor = row['cor'] as String?;
        final colorString = color.toARGB32().toString();

        if (id != null && currentColor != colorString) {
          conn.execute(
            '''
            UPDATE Tags
            SET cor = ?
            WHERE idTag = ?
            ''',
            [colorString, id],
          );
        }

        return (
          true,
          TagModel(
            id: id,
            label: row['descricao'] as String? ?? sanitizedLabel,
            color: Color(int.tryParse(currentColor ?? '') ?? color.toARGB32()),
            groupId: row['grupoTag_idGrupoTag'] as int?,
          ),
          null,
        );
      }

      conn.execute(
        '''
        INSERT INTO Tags (descricao, cor, grupoTag_idGrupoTag)
        VALUES (?, ?, ?)
        ''',
        [sanitizedLabel, color.toARGB32().toString(), groupId],
      );

      final inserted = conn.select('SELECT last_insert_rowid() AS id');
      final insertedId = inserted.first['id'] as int?;
      return (
        true,
        TagModel(
          id: insertedId,
          label: sanitizedLabel,
          color: color,
          groupId: groupId,
        ),
        null,
      );
    } catch (error) {
      return (false, null, _cleanError(error));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, List<TagModel>?, String?)> listTags({int? groupId}) async {
    final conn = await getConnection();
    try {
      final rows = conn.select(
        groupId == null
            ? '''
              SELECT idTag, descricao, cor, grupoTag_idGrupoTag
              FROM Tags
              ORDER BY idTag ASC
              '''
            : '''
              SELECT idTag, descricao, cor, grupoTag_idGrupoTag
              FROM Tags
              WHERE grupoTag_idGrupoTag = ?
              ORDER BY idTag ASC
              ''',
        groupId == null ? const <Object?>[] : [groupId],
      );

      final tags = rows
          .map(
            (row) => TagModel(
              id: row['idTag'] as int?,
              label: row['descricao'] as String? ?? '',
              color: Color(
                int.tryParse(row['cor'] as String? ?? '') ?? 0xFFDF6EB8,
              ),
              groupId: row['grupoTag_idGrupoTag'] as int?,
            ),
          )
          .where((tag) => tag.label.trim().isNotEmpty)
          .toList(growable: false);

      return (true, tags, null);
    } catch (error) {
      return (false, null, _cleanError(error));
    } finally {
      conn.close();
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceAll('Exception: ', '');
  }
}
