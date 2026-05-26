import '../services/conversas_service.dart';

class ConversasRepository {

  final ConversasService service;

  ConversasRepository({
    required this.service,
  });

  Future<int> criarConversa(
    List<Map<String, dynamic>> mensagens,
    String titulo,
  ) {

    return service.criarConversa(
      mensagens,
      titulo,
    );
  }

  Future atualizarConversa(
    int id,
    List<Map<String, dynamic>> mensagens,
  ) {

    return service.atualizarConversa(
      id,
      mensagens,
    );
  }
  Future excluirConversa(
  id,
){

  return service
  .excluirConversa(
    id,
  );

}

  Future listarConversas() {

    return service.listarConversas();
  }

  Future verConversa(
    int id,
  ) {

    return service.verConversa(
      id,
    );
  }

}