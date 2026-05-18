import 'package:flutter/material.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/data/repositories/chatbot_repository.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/data/services/chatbot_service.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/viewmodels/chatbot_viewmodel.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {

  final TextEditingController controller = TextEditingController();

late ChatbotViewModel viewModel;

@override
void initState() {
  super.initState();

  viewModel = ChatbotViewModel(
    repository: ChatbotRepository(
      service: ChatbotService(),
    ),
  );

  viewModel.addListener(() {
    setState(() {});
  });
}

Future<void> enviarMensagem() async {
  await viewModel.enviarMensagem(
    controller.text,
  );

  controller.clear();
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assistente Criativo"),
      ),

      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              itemCount: viewModel.mensagens.length,
              itemBuilder: (context,index){

                return ListTile(
                  title: Text(
                    viewModel.mensagens[index],
                  ),
                );

              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),

            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Digite uma ideia...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: enviarMensagem,
                  icon: const Icon(Icons.send),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }
}