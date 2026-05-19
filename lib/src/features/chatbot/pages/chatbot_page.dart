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
