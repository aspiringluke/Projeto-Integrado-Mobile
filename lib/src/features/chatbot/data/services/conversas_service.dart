import 'dart:convert';

import 'package:projeto_integrado_mobile/src/app/database/db.dart';

class ConversasService {

  Future<int> criarConversa(
    List<Map<String, dynamic>> mensagens,
    String titulo,
  ) async {

    final conn = await getConnection();

    final jsonMensagens =
        jsonEncode(mensagens);

    conn.execute(
      '''
      INSERT INTO Conversa
      (mensagens, titulo)
      VALUES (?, ?)
      ''',
      [
        jsonMensagens,
        titulo,
      ],
    );

    final resultado =
      conn.select(
        '''
        SELECT last_insert_rowid()
        AS id
        '''
      );

    conn.close();

    return
      resultado
      .first['id'] as int;
  }

  Future atualizarConversa(
    int id,
    List<Map<String,dynamic>>
    mensagens,
  ) async {

    final conn =
        await getConnection();

    final jsonMensagens =
        jsonEncode(
          mensagens,
        );

    conn.execute(
      '''
      UPDATE Conversa
      SET mensagens=?
      WHERE idConversa=?
      ''',
      [
        jsonMensagens,
        id,
      ],
    );

    conn.close();
  }
  Future excluirConversa(
  id,
) async {

  final conn =
      await getConnection();

  conn.execute(
    '''
    DELETE FROM Conversa
    WHERE idConversa = ?
    ''',
    [id],
  );

  conn.close();
}

  Future<List<Map<String,dynamic>>>
  listarConversas()
  async {

    final conn =
        await getConnection();

    final resultado =
      conn.select(
        '''
        SELECT *
        FROM Conversa
        ORDER BY idConversa DESC
        '''
      );

    conn.close();

    return resultado
      .map(
        (e)=>e
      )
      .toList();
  }

  Future<Map<String,dynamic>>
  verConversa(
      int id
  ) async {

    final conn =
        await getConnection();

    final resultado =
      conn.select(
        '''
        SELECT *
        FROM Conversa
        WHERE idConversa=?
        ''',
        [id],
      );

    conn.close();

    return resultado.first;
  }

}