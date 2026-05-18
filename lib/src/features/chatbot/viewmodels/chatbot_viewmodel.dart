import 'package:flutter/material.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/data/repositories/chatbot_repository.dart';

class ChatbotViewModel extends ChangeNotifier {

  final ChatbotRepository repository;

  ChatbotViewModel({
    required this.repository,
  });

  List<String> mensagens = [];

  Future<void> enviarMensagem(String msg) async {
    if (msg.trim().isEmpty) return;

    mensagens.add(msg);
    notifyListeners();

    List<String> contexto = List.from(mensagens);
    contexto.removeLast();
    final resposta = await repository.enviarMensagem(
      contexto,
      msg,
    );

    mensagens.add(
      resposta.$1
        ? resposta.$2
        : "Erro: ${resposta.$2}",
    );

    notifyListeners();
  }
}