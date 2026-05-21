import 'dart:ui';

import 'package:projeto_integrado_mobile/src/app/database/db.dart';
import 'package:projeto_integrado_mobile/src/features/characters/data/services/i_character_service.dart';
import 'package:projeto_integrado_mobile/src/features/characters/models/characters_models.dart';

class SqliteCharacterService implements ICharacterService {
  @override
  Future<(bool, CharacterListItem?, String?)> createCharacter(
    CharacterListItem character,
  ) async {
    final conn = await getConnection();
    final now = _nowIso();

    try {
      conn.execute(
        '''
        INSERT INTO Personagem (
          nome,
          corDestaque,
          payload,
          projeto_idProjeto,
          fixado,
          ordemNaoFixada,
          createdAt,
          lastModified,
          lastAccessed
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          character.data.name,
          character.data.accent.toARGB32().toString(),
          encodeCharacterPayload(character.data),
          character.projectId,
          character.isPinned ? 1 : 0,
          character.unpinnedIndex,
          now,
          now,
          now,
        ],
      );

      final inserted = conn.select('SELECT last_insert_rowid() AS id');
      final insertedId = inserted.first['id'] as int?;
      if (insertedId == null) {
        return (
          false,
          null,
          'Falha ao recuperar o identificador do personagem',
        );
      }

      return getCharacter(insertedId);
    } catch (error) {
      return (false, null, _cleanError(error));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, CharacterListItem?, String?)> getCharacter(int id) async {
    final conn = await getConnection();

    try {
      final result = conn.select(
        '''
        SELECT
          p.idPersonagem,
          p.nome,
          p.corDestaque,
          p.payload,
          p.projeto_idProjeto,
          p.fixado,
          p.ordemNaoFixada,
          p.createdAt,
          p.lastModified,
          p.lastAccessed,
          proj.titulo AS projetoTitulo
        FROM Personagem p
        LEFT JOIN Projeto proj
          ON proj.idProjeto = p.projeto_idProjeto
        WHERE p.idPersonagem = ?
        ''',
        [id],
      );

      if (result.isEmpty) {
        return (true, null, null);
      }

      return (true, _mapCharacter(result.first), null);
    } catch (error) {
      return (false, null, _cleanError(error));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, List<CharacterListItem>?, String?)> listAllCharacters() async {
    final conn = await getConnection();

    try {
      final result = conn.select('''
        SELECT
          p.idPersonagem,
          p.nome,
          p.corDestaque,
          p.payload,
          p.projeto_idProjeto,
          p.fixado,
          p.ordemNaoFixada,
          p.createdAt,
          p.lastModified,
          p.lastAccessed,
          proj.titulo AS projetoTitulo
        FROM Personagem p
        LEFT JOIN Projeto proj
          ON proj.idProjeto = p.projeto_idProjeto
        ORDER BY p.fixado DESC, p.ordemNaoFixada ASC, p.idPersonagem ASC
        ''');

      if (result.isEmpty) {
        return (true, null, null);
      }

      return (true, result.map(_mapCharacter).toList(growable: false), null);
    } catch (error) {
      return (false, null, _cleanError(error));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, List<CharacterListItem>?, String?)> listCharactersForProject(
    int projectId,
  ) async {
    final conn = await getConnection();

    try {
      final result = conn.select(
        '''
        SELECT
          p.idPersonagem,
          p.nome,
          p.corDestaque,
          p.payload,
          p.projeto_idProjeto,
          p.fixado,
          p.ordemNaoFixada,
          p.createdAt,
          p.lastModified,
          p.lastAccessed,
          proj.titulo AS projetoTitulo
        FROM Personagem p
        LEFT JOIN Projeto proj
          ON proj.idProjeto = p.projeto_idProjeto
        WHERE p.projeto_idProjeto = ?
        ORDER BY p.fixado DESC, p.ordemNaoFixada ASC, p.idPersonagem ASC
        ''',
        [projectId],
      );

      if (result.isEmpty) {
        return (true, null, null);
      }

      return (true, result.map(_mapCharacter).toList(growable: false), null);
    } catch (error) {
      return (false, null, _cleanError(error));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, String)> touchCharacter(int id) async {
    final conn = await getConnection();

    try {
      conn.execute(
        'UPDATE Personagem SET lastAccessed = ? WHERE idPersonagem = ?',
        [_nowIso(), id],
      );
      return (true, 'Personagem $id acessado');
    } catch (error) {
      return (false, _cleanError(error));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, String)> updateCharacter(CharacterListItem character) async {
    if (character.id == null) {
      return (false, 'Personagem sem identificador');
    }

    final conn = await getConnection();

    try {
      conn.execute(
        '''
        UPDATE Personagem
        SET
          nome = ?,
          corDestaque = ?,
          payload = ?,
          projeto_idProjeto = ?,
          fixado = ?,
          ordemNaoFixada = ?,
          lastModified = ?,
          lastAccessed = ?
        WHERE idPersonagem = ?
        ''',
        [
          character.data.name,
          character.data.accent.toARGB32().toString(),
          encodeCharacterPayload(character.data),
          character.projectId,
          character.isPinned ? 1 : 0,
          character.unpinnedIndex,
          _nowIso(),
          character.lastAccessed.toIso8601String(),
          character.id,
        ],
      );

      return (true, 'Personagem ${character.id} atualizado');
    } catch (error) {
      return (false, _cleanError(error));
    } finally {
      conn.close();
    }
  }

  @override
  Future<(bool, String)> deleteCharacter(int id) async {
    final conn = await getConnection();

    try {
      conn.execute('DELETE FROM Personagem WHERE idPersonagem = ?', [id]);
      return (true, 'Personagem $id excluido');
    } catch (error) {
      return (false, _cleanError(error));
    } finally {
      conn.close();
    }
  }

  CharacterListItem _mapCharacter(Map<String, Object?> row) {
    final payload = decodeCharacterPayload(row['payload'] as String?);
    final accent = Color(
      _parseColor(row['corDestaque']) ?? payload.accent.toARGB32(),
    );
    final normalizedPayload = payload.copyWith(
      name: (row['nome'] as String?)?.trim().isNotEmpty == true
          ? row['nome'] as String
          : payload.name,
      accent: accent,
    );

    return CharacterListItem(
      id: row['idPersonagem'] as int?,
      projectId: row['projeto_idProjeto'] as int? ?? 0,
      projectTitle: row['projetoTitulo'] as String?,
      data: normalizedPayload,
      isPinned: (row['fixado'] as int? ?? 0) == 1,
      unpinnedIndex: row['ordemNaoFixada'] as int? ?? 0,
      createdAt: _parseDate(row['createdAt']),
      lastModified: _parseDate(row['lastModified']),
      lastAccessed: _parseDate(row['lastAccessed']),
    );
  }

  String _cleanError(Object error) {
    return error.toString().replaceAll('Exception: ', '');
  }
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
