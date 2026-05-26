import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/data/ai_mention_context_builder.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/data/repositories/chatbot_repository.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/data/repositories/conversas_repository.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/data/services/conversas_service.dart';

class ChatbotViewModel extends ChangeNotifier {
  final ChatbotRepository repository;
  final AiMentionContextBuilder mentionContextBuilder;

  late ConversasRepository conversasRepository;

  ChatbotViewModel({
    required this.repository,
    AiMentionContextBuilder? mentionContextBuilder,
  }) : mentionContextBuilder =
           mentionContextBuilder ?? AiMentionContextBuilder() {
    conversasRepository = ConversasRepository(service: ConversasService());
  }

  List<String> mensagens = [];

  int? conversaId;

  List<Map<String, dynamic>> conversas = [];

  Future<void> enviarMensagem(String msg) async {
    if (msg.trim().isEmpty) return;

    mensagens.add(msg);

    notifyListeners();

    List<String> contexto = List.from(mensagens);

    contexto.removeLast();

    final messageWithMentionContext = await mentionContextBuilder
        .buildPromptWithMentionContext(msg);

    final resposta = await repository.enviarMensagem(
      contexto,
      messageWithMentionContext,
    );

    final respostaTexto = resposta.$1 ? resposta.$2 : "Erro: ${resposta.$2}";

    mensagens.add(respostaTexto);

    final mensagensJson = gerarMensagensJson();

    if (conversaId == null) {
      conversaId = await conversasRepository.criarConversa(mensagensJson, msg);
    } else {
      await conversasRepository.atualizarConversa(conversaId!, mensagensJson);
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> gerarMensagensJson() {
    List<Map<String, dynamic>> lista = [];

    for (int i = 0; i < mensagens.length; i++) {
      lista.add({
        "sender": i % 2 == 0 ? "user" : "assistant",

        "message": mensagens[i],
      });
    }

    return lista;
  }

  Future<void> carregarConversas() async {
    conversas = await conversasRepository.listarConversas();

    notifyListeners();
  }

  Future<void> abrirConversa(int id) async {
    final conversa = await conversasRepository.verConversa(id);

    conversaId = id;

    mensagens.clear();

    final lista = jsonDecode(conversa["mensagens"]);

    for (var msg in lista) {
      mensagens.add(msg["message"]);
    }

    notifyListeners();
  }

  void novaConversa() {
    conversaId = null;

    mensagens.clear();

    notifyListeners();
  }

  Future excluirConversa(int id) async {
    await conversasRepository.excluirConversa(id);

    conversas.removeWhere((c) => c["idConversa"] == id);

    notifyListeners();
  }
}
