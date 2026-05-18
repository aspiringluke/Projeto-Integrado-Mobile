import 'package:flutter/material.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/data/repositories/chatbot_repository.dart';

class ChatbotViewModel extends ChangeNotifier {

  final ChatbotRepository repository;

  ChatbotViewModel({
    required this.repository,
  });

  List<String> mensagens = [];

  Future<void> enviarMensagem(String msg) async {

    print("1 - método iniciou");

    if (msg.trim().isEmpty) return;

    mensagens.add(msg);

    notifyListeners();

    List<String> contexto = List.from(mensagens);
    contexto.removeLast();

    print("2 - chamando repository");

    final resposta = await repository.enviarMensagem(
      contexto,
      msg,
    );

    print("3 - resposta recebida");
    print("Sucesso: ${resposta.$1}");
    print("Texto: ${resposta.$2}");

    mensagens.add(
      resposta.$1
        ? resposta.$2
        : "Erro: ${resposta.$2}",
    );

    notifyListeners();
  }
}