part of '../character_fields.dart';

class CharacterMarkdownText extends StatelessWidget {
  final String data;
  final TextStyle style;

  const CharacterMarkdownText({
    super.key,
    required this.data,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final sanitizedData = sanitizeCharacterMarkdown(data);
    final normalizedData = sanitizedData.trim().isEmpty ? ' ' : sanitizedData;
    final styleSheet = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: style,
      pPadding: EdgeInsets.zero,
      blockSpacing: 0,
      listIndent: 18,
      listBullet: style,
      listBulletPadding: const EdgeInsets.only(right: 6),
      strong: style.copyWith(
        fontWeight: FontWeight.w700,
        fontStyle: style.fontStyle,
      ),
      em: style.copyWith(fontStyle: FontStyle.italic),
      code: style.copyWith(
        fontFamily: 'monospace',
        backgroundColor: Colors.transparent,
      ),
      blockquote: style,
      blockquotePadding: EdgeInsets.zero,
      blockquoteDecoration: const BoxDecoration(),
    );

    return MarkdownBody(
      data: normalizedData,
      shrinkWrap: true,
      softLineBreak: true,
      styleSheet: styleSheet,
    );
  }
}
