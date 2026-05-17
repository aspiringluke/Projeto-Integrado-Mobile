import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/data/services/i_chatbot_service.dart';

class ChatbotService implements IChatbotService
{
  @override
  Future<(bool, String)> enviarMensagem(List<String> context, String msg) async {
    final client = MistralClient.fromEnvironment();

    // preparar o contexto
    List<ChatMessage> mensagens = [];
    bool isUserMessage = true;
    for(String i in context)
    {
        mensagens.add(
            isUserMessage
            ? ChatMessage.user(i)
            : ChatMessage.assistant(i)
        );

        isUserMessage = !isUserMessage;
    }
    mensagens.add(ChatMessage.user(msg));

    try{
        final response = await client.chat.create(
            request: ChatCompletionRequest(
                model: "mistral-small-latest",
                messages: mensagens,
            )
        );
        return (true, response.text.toString());
    } catch(e) {
        final cleanError = e.toString().replaceFirst("Exception: ", "");
        return (false, cleanError);
    } finally {
        client.close();
    }
  }
}
