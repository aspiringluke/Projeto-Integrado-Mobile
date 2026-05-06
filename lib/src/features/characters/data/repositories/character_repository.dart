import '../services/character_ai_service.dart';

class CharacterRepository {
  final CharacterAIService _aiService;

  // Construtor que recebe o service de IA (Injeção de Dependência)
  CharacterRepository(this._aiService);

  Future<String> obterAnaliseDePersonagem(String texto) async {
    // O repository chama o método de IA que o teu colega pediu
    return await _aiService.inferirPersonalidade(texto);
  }
}
