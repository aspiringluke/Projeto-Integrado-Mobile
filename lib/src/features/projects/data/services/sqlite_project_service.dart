import 'dart:convert';
import 'dart:ui';

import 'package:projeto_integrado_mobile/src/app/database/db.dart';
import 'package:projeto_integrado_mobile/src/features/projects/data/services/i_project_service.dart';
import 'package:projeto_integrado_mobile/src/features/projects/models/project_image_data.dart';
import 'package:projeto_integrado_mobile/src/features/projects/models/project_record.dart';
import 'package:projeto_integrado_mobile/src/features/projects/models/project_tag_data.dart';

class SqliteProjectService implements IProjectService {
  @override
  Future<(bool, ProjectRecord?, String?)> createProject(
    ProjectRecord project,
  ) async {
    final conn = await getConnection();
    final now = _nowIso();

    try {
      conn.execute(
        '''
        INSERT INTO Projeto (
          titulo,
          sintese,
          corCapa,
          corDestaque,
          imagemCapa,
          imagemDestaque,
          tagsJson,
          fixado,
          ordemNaoFixada,
          modoVisualizacaoPersonagens,
          colunasGradePersonagens,
          createdAt,
          lastModified,
          lastAccessed
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          project.title,
          project.synopsis,
          project.coverColor.toARGB32().toString(),
          project.accentColor.toARGB32().toString(),
          _encodeImage(project.coverImage),
          _encodeImage(project.accentImage),
          _encodeTags(project.tags),
          project.isPinned ? 1 : 0,
          project.unpinnedIndex,
          project.characterDisplayMode,
          project.characterGridColumns,
          now,
          now,
          now,
        ],
      );

      final inserted = conn.select('SELECT last_insert_rowid() AS id');
      final insertedId = inserted.first['id'] as int?;
      if (insertedId == null) {
        return (false, null, 'Falha ao recuperar o identificador do projeto');
      }

      return getProject(insertedId);
    } catch (error) {
      return (false, null, _cleanError(error));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, ProjectRecord?, String?)> getProject(int id) async {
    final conn = await getConnection();

    try {
      final result = conn.select(
        '''
        SELECT
          idProjeto,
          titulo,
          sintese,
          corCapa,
          corDestaque,
          imagemCapa,
          imagemDestaque,
          tagsJson,
          fixado,
          ordemNaoFixada,
          modoVisualizacaoPersonagens,
          colunasGradePersonagens,
          createdAt,
          lastModified,
          lastAccessed
        FROM Projeto
        WHERE idProjeto = ?
        ''',
        [id],
      );

      if (result.isEmpty) {
        return (true, null, null);
      }

      return (true, _mapProject(result.first), null);
    } catch (error) {
      return (false, null, _cleanError(error));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, List<ProjectRecord>?, String?)> listProjects() async {
    final conn = await getConnection();

    try {
      final result = conn.select(
        '''
        SELECT
          idProjeto,
          titulo,
          sintese,
          corCapa,
          corDestaque,
          imagemCapa,
          imagemDestaque,
          tagsJson,
          fixado,
          ordemNaoFixada,
          modoVisualizacaoPersonagens,
          colunasGradePersonagens,
          createdAt,
          lastModified,
          lastAccessed
        FROM Projeto
        ORDER BY fixado DESC, ordemNaoFixada ASC, idProjeto ASC
        ''',
      );

      if (result.isEmpty) {
        return (true, null, null);
      }

      return (
        true,
        result.map(_mapProject).toList(growable: false),
        null,
      );
    } catch (error) {
      return (false, null, _cleanError(error));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, String)> touchProject(int id) async {
    final conn = await getConnection();

    try {
      conn.execute(
        'UPDATE Projeto SET lastAccessed = ? WHERE idProjeto = ?',
        [_nowIso(), id],
      );
      return (true, 'Projeto $id acessado');
    } catch (error) {
      return (false, _cleanError(error));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, String)> updateProject(ProjectRecord project) async {
    if (project.id == null) {
      return (false, 'Projeto sem identificador');
    }

    final conn = await getConnection();

    try {
      conn.execute(
        '''
        UPDATE Projeto
        SET
          titulo = ?,
          sintese = ?,
          corCapa = ?,
          corDestaque = ?,
          imagemCapa = ?,
          imagemDestaque = ?,
          tagsJson = ?,
          fixado = ?,
          ordemNaoFixada = ?,
          modoVisualizacaoPersonagens = ?,
          colunasGradePersonagens = ?,
          lastModified = ?,
          lastAccessed = ?
        WHERE idProjeto = ?
        ''',
        [
          project.title,
          project.synopsis,
          project.coverColor.toARGB32().toString(),
          project.accentColor.toARGB32().toString(),
          _encodeImage(project.coverImage),
          _encodeImage(project.accentImage),
          _encodeTags(project.tags),
          project.isPinned ? 1 : 0,
          project.unpinnedIndex,
          project.characterDisplayMode,
          project.characterGridColumns,
          _nowIso(),
          project.lastAccessed.toIso8601String(),
          project.id,
        ],
      );

      return (true, 'Projeto ${project.id} atualizado');
    } catch (error) {
      return (false, _cleanError(error));
    } finally {
      conn.close();
    }
  }

  ProjectRecord _mapProject(Map<String, Object?> row) {
    return ProjectRecord(
      id: row['idProjeto'] as int?,
      title: row['titulo'] as String? ?? '',
      synopsis: row['sintese'] as String? ?? '',
      tags: _decodeTags(row['tagsJson'] as String?),
      coverColor: Color(_parseColor(row['corCapa']) ?? 0xFFDF6EB8),
      accentColor: Color(_parseColor(row['corDestaque']) ?? 0xFFDF6EB8),
      coverImage: _decodeImage(row['imagemCapa'] as String?),
      accentImage: _decodeImage(row['imagemDestaque'] as String?),
      isPinned: (row['fixado'] as int? ?? 0) == 1,
      unpinnedIndex: row['ordemNaoFixada'] as int? ?? 0,
      characterDisplayMode:
          (row['modoVisualizacaoPersonagens'] as String?)?.trim().isNotEmpty ==
              true
          ? row['modoVisualizacaoPersonagens'] as String
          : 'list',
      characterGridColumns: row['colunasGradePersonagens'] as int? ?? 3,
      createdAt: _parseDate(row['createdAt']),
      lastModified: _parseDate(row['lastModified']),
      lastAccessed: _parseDate(row['lastAccessed']),
    );
  }

  String _cleanError(Object error) {
    return error.toString().replaceAll('Exception: ', '');
  }
}

String _encodeImage(ProjectImageData image) {
  return jsonEncode(image.toJson());
}

ProjectImageData _decodeImage(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return const ProjectImageData();
  }

  final decoded = jsonDecode(raw);
  if (decoded is Map<String, Object?>) {
    return ProjectImageData.fromJson(decoded);
  }

  if (decoded is Map) {
    return ProjectImageData.fromJson(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  return const ProjectImageData();
}

String _encodeTags(List<ProjectTagData> tags) {
  return jsonEncode(
    tags.map((tag) => tag.toJson()).toList(growable: false),
  );
}

List<ProjectTagData> _decodeTags(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return const <ProjectTagData>[];
  }

  final decoded = jsonDecode(raw);
  if (decoded is! List) {
    return const <ProjectTagData>[];
  }

  return decoded
      .whereType<Map>()
      .map(
        (entry) => ProjectTagData.fromJson(
          entry.map((key, value) => MapEntry(key.toString(), value)),
        ),
      )
      .where((tag) => tag.label.trim().isNotEmpty)
      .toList(growable: false);
}

int? _parseColor(Object? value) {
  if (value is int) {
    return value;
  }

  if (value is String) {
    return int.tryParse(value);
  }

  return null;
}

DateTime _parseDate(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  return DateTime.now();
}

String _nowIso() => DateTime.now().toIso8601String();
