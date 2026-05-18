import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatMessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleGradient = isUser
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDD7CB6), Color(0xFFBE66A1)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xF8FFFFFF), Color(0xF4F3EEF4)],
          );

    final foregroundColor = isUser ? Colors.white : const Color(0xFF3B2F3A);
    final cleanedText = _stripHtmlTags(text);

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: bubbleGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.09),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isUser
                ? const Color(0x26FFFFFF)
                : const Color(0x66FFFFFF),
          ),
        ),
        child: MarkdownBody(
          data: cleanedText,
          selectable: false,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              color: foregroundColor,
              fontSize: 15,
              height: 1.28,
            ),
            strong: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
            em: TextStyle(
              color: foregroundColor,
              fontStyle: FontStyle.italic,
            ),
            code: TextStyle(
              color: foregroundColor,
              fontSize: 14,
              backgroundColor: isUser
                  ? Colors.white.withValues(alpha: 0.18)
                  : const Color(0xFFCBBEC9).withValues(alpha: 0.45),
            ),
            listBullet: TextStyle(color: foregroundColor),
          ),
        ),
      ),
    );
  }

  String _stripHtmlTags(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>', multiLine: true, dotAll: true), '')
        .trim();
  }
}
