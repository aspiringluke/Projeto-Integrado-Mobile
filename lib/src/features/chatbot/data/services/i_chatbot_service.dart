abstract interface class IChatbotService
{
    Future<(bool, String)> enviarMensagem(List<String> context, String msg);
}