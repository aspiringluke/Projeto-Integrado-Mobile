import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/data/repositories/chatbot_repository.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/data/repositories/conversas_repository.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/data/services/conversas_service.dart';

class ChatbotViewModel extends ChangeNotifier {

  final ChatbotRepository repository;

  late ConversasRepository conversasRepository;

  ChatbotViewModel({
    required this.repository,
  }) {

    conversasRepository =
      ConversasRepository(
        service:
          ConversasService(),
      );
  }

  List<String> mensagens = [];

  int? conversaId;

  List<Map<String,dynamic>>
  conversas = [];

  Future<void>
  enviarMensagem(
      String msg
  ) async {

    if (
      msg.trim().isEmpty
    ) return;

    mensagens.add(msg);

    notifyListeners();

    List<String>
    contexto =
        List.from(
          mensagens
        );

    contexto.removeLast();

    final resposta =
      await repository
      .enviarMensagem(
        contexto,
        msg,
      );

    final respostaTexto =
      resposta.$1
      ? resposta.$2
      : "Erro: ${resposta.$2}";

    mensagens.add(
      respostaTexto,
    );

    final mensagensJson =
      gerarMensagensJson();

    if (
      conversaId == null
    ) {

      conversaId =
      await conversasRepository
      .criarConversa(
        mensagensJson,
        msg,
      );

    } else {

      await conversasRepository
      .atualizarConversa(
        conversaId!,
        mensagensJson,
      );

    }

    notifyListeners();
  }

  List<Map<String,dynamic>>
  gerarMensagensJson() {

    List<Map<String,dynamic>>
    lista = [];

    for (
      int i=0;
      i<mensagens.length;
      i++
    ) {

      lista.add({

        "sender":
        i % 2 == 0
        ? "user"
        : "assistant",

        "message":
        mensagens[i],

      });

    }

    return lista;
  }

  Future<void>
  carregarConversas()
  async {

    conversas =
      await conversasRepository
      .listarConversas();

    notifyListeners();
  }

  Future<void>
  abrirConversa(
      int id
  ) async {

    final conversa =
      await conversasRepository
      .verConversa(id);

    conversaId = id;

    mensagens.clear();

    final lista =
      jsonDecode(
        conversa["mensagens"]
      );

    for (
      var msg
      in lista
    ) {

      mensagens.add(
        msg["message"]
      );
    }

    notifyListeners();
  }

}