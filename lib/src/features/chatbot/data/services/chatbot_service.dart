/// Service responsável por aplicar técnicas de Inteligência Artificial
/// no gerenciamento de personagens.
class ChatbotService {
  
  /// Metodologia: Processamento de Linguagem Natural (NLP)
  /// Objetivo: Gerar uma sinopse criativa baseada no nome e alcunha do personagem.
  Future<String> gerarSinopseComIA(String nome, String alias) async {
    
    // Simulação de chamada de API de IA (como Google Gemini ou OpenAI)
    // Na implementação real, enviaríamos um prompt para o modelo.
    await Future.delayed(const Duration(seconds: 1)); 

    return "A IA analisou o perfil e determinou: $nome, também conhecido como '$alias', "
           "é um herói cuja história é marcada por desafios épicos e uma determinação inabalável.";
  }
}
