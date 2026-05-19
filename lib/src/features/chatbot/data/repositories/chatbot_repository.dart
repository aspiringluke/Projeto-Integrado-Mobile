import 'package:projeto_integrado_mobile/src/features/chatbot/data/services/chatbot_service.dart';

class ChatbotRepository
{
    final ChatbotService service;

    ChatbotRepository({
        required this.service
    });

    Future<(bool, String)> enviarMensagem(List<String> context, String msg) async
    {
        if(msg.trim().isEmpty)
        {
            return (false, "Mensagem vazia");
        }

        return await service.enviarMensagem(context, msg);
    }
}