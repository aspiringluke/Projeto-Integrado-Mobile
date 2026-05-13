import 'dart:ui';

import 'package:projeto_integrado_mobile/src/app/database/db.dart';
import 'package:projeto_integrado_mobile/src/features/tags/data/services/i_tag_group_service.dart';
import 'package:projeto_integrado_mobile/src/features/tags/models/tag_group_model.dart';
import 'package:projeto_integrado_mobile/src/features/tags/models/tag_model.dart';

class TagGroupService implements ITagGroupService {
  @override
  Future<(bool, TagGroupModel?, String?)> ensureGroup({
    required String title,
    required Color color,
  }) async {
    final sanitizedTitle = sanitizeTagLabel(title);
    if (sanitizedTitle.isEmpty) {
      return (false, null, 'Título de grupo inválido');
    }

    final conn = await getConnection();
    try {
      final existing = conn.select(
        '''
        SELECT idGrupoTag, descricao, cor
        FROM GrupoTag
        WHERE LOWER(TRIM(descricao)) = LOWER(TRIM(?))
        LIMIT 1
        ''',
        [sanitizedTitle],
      );

      if (existing.isNotEmpty) {
        final row = existing.first;
        final id = row['idGrupoTag'] as int?;
        final currentColor = row['cor'] as String?;
        final colorString = color.toARGB32().toString();

        if (id != null && currentColor != colorString) {
          conn.execute(
            '''
            UPDATE GrupoTag
            SET cor = ?
            WHERE idGrupoTag = ?
            ''',
            [colorString, id],
          );
        }

        return (
          true,
          TagGroupModel(
            id: id,
            title: row['descricao'] as String? ?? sanitizedTitle,
            color: Color(int.tryParse(currentColor ?? '') ?? color.toARGB32()),
            tags: const <TagModel>[],
          ),
          null,
        );
      }

      conn.execute(
        '''
        INSERT INTO GrupoTag (descricao, cor)
        VALUES (?, ?)
        ''',
        [sanitizedTitle, color.toARGB32().toString()],
      );

      final inserted = conn.select('SELECT last_insert_rowid() AS id');
      final insertedId = inserted.first['id'] as int?;
      return (
        true,
        TagGroupModel(
          id: insertedId,
          title: sanitizedTitle,
          color: color,
          tags: const <TagModel>[],
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
  Future<(bool, List<TagGroupModel>?, String?)> listGroups() async {
    final conn = await getConnection();
    try {
      final rows = conn.select(
        '''
        SELECT idGrupoTag, descricao, cor
        FROM GrupoTag
        ORDER BY idGrupoTag ASC
        ''',
      );

      final groups = rows
          .map(
            (row) => TagGroupModel(
              id: row['idGrupoTag'] as int?,
              title: row['descricao'] as String? ?? '',
              color: Color(
                int.tryParse(row['cor'] as String? ?? '') ?? 0xFFDF6EB8,
              ),
              tags: const <TagModel>[],
            ),
          )
          .where((group) => group.title.trim().isNotEmpty)
          .toList(growable: false);

      return (true, groups, null);
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
