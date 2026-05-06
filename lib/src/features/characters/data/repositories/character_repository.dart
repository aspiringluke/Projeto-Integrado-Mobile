import '../services/character_ai_service.dart';

class CharacterRepository {
  final CharacterAIService _aiService;
  CharacterRepository(this._aiService);

  Future<String> obterAnaliseDePersonagem(String texto) async {
    return await _aiService.inferirPersonalidade(texto);
  }
}
