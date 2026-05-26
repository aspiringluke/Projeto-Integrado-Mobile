import 'package:flutter/material.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/data/repositories/chatbot_repository.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/data/services/chatbot_service.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/pages/widgets/chat_composer_bar.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/pages/widgets/chat_message_bubble.dart';
import 'package:projeto_integrado_mobile/src/features/chatbot/viewmodels/chatbot_viewmodel.dart';
import 'package:projeto_integrado_mobile/src/shared/widgets/main_header.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatbotViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ChatbotViewModel(
      repository: ChatbotRepository(
        service: ChatbotService(),
      ),
    );
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.carregarConversas();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _enviarMensagem() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _viewModel.enviarMensagem(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/FUNDO.png', fit: BoxFit.cover),
          ),
          Column(
            children: [
              MainHeader(
                asSliver: false,
                title: 'Assistente Criativo',
                subtitle: 'Converse com seu copiloto de ideias',
                surroundSubtitleWithDots: true,
                titleFontSize: 22,
                titleLetterSpacing: 1.2,
                onBackPressed: () => Navigator.of(context).pop(),
              ),
              Padding(
  padding: const EdgeInsets.only(
    right: 12,
    top: 8,
  ),
  child: Align(
    alignment: Alignment.centerRight,
    child: IconButton(
      icon: const Icon(Icons.history),
      onPressed: () async {

        await _viewModel.carregarConversas();

        showModalBottomSheet(
          context: context,
          builder: (_) {

              return Column(
      children: [

        ListTile(
          leading: const Icon(
            Icons.add_circle_outline,
          ),

          title: const Text(
            "Nova conversa",
          ),

          onTap: () {
            Navigator.pop(context);
            _viewModel.novaConversa();
          },
        ),

        const Divider(),

        Expanded(
          child: _viewModel.conversas.isEmpty
          ? const Center(
              child: Text(
                "Nenhuma conversa encontrada",
              ),
            )
          : ListView.builder(
              itemCount: _viewModel.conversas.length,

              itemBuilder: (context,index){

                final conversa =
                    _viewModel.conversas[index];

                return ListTile(
                  leading: const Icon(
                    Icons.chat_bubble_outline,
                  ),

                  title: Text(
                    conversa["titulo"]
                    ?? "Sem título",
                  ),
                  trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),

                            onPressed: () async {

                              final confirmar =
                                  await showDialog(
                                context: context,
                                builder: (_) =>
                                    AlertDialog(
                                  title: const Text(
                                    "Excluir conversa",
                                  ),

                                  content: const Text(
                                    "Deseja excluir esta conversa?",
                                  ),

                                  actions: [

                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                          false,
                                        );
                                      },
                                      child: const Text(
                                        "Cancelar",
                                      ),
                                    ),

                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                          true,
                                        );
                                      },
                                      child: const Text(
                                        "Excluir",
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if(confirmar == true){

                                await _viewModel
                                    .excluirConversa(
                                  conversa["idConversa"],
                                );

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Conversa excluída",
                                    ),
                                  ),
                                );

                              }

                            },
                          ),

                  onTap: () async {

                    Navigator.pop(context);

                    await _viewModel
                        .abrirConversa(
                      conversa["idConversa"],
                    );
                  },
                );
              },
            ),
    ),
  ],
);
          },
        );
      },
    ),
  ),
),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.38),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.54),
                    ),
                  ),
                  child: _viewModel.mensagens.isEmpty
                      ? const Center(
                          child: Text(
                            'Comece a conversa com uma ideia.',
                            style: TextStyle(
                              color: Color(0xFF5E4E5A),
                              fontSize: 15,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                          itemCount: _viewModel.mensagens.length,
                          itemBuilder: (context, index) {
                            final isUser = index.isEven;
                            return ChatMessageBubble(
                              text: _viewModel.mensagens[index],
                              isUser: isUser,
                            );
                          },
                        ),
                ),
              ),
              ChatComposerBar(
                controller: _controller,
                onSend: () {
                  _enviarMensagem();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
