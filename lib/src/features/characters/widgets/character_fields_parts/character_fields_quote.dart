part of '../character_fields.dart';

class CharacterQuoteStrip extends StatelessWidget {
  final Color accentColor;
  final TextEditingController controller;
  final bool isEditing;
  final String hintText;
  final bool showHintText;
  final String? tooltipText;

  const CharacterQuoteStrip({
    super.key,
    required this.accentColor,
    required this.controller,
    required this.isEditing,
    this.hintText = 'Frase de efeito do personagem',
    this.showHintText = true,
    this.tooltipText,
  });

  @override
  Widget build(BuildContext context) {
    final tooltipTheme = Theme.of(context).copyWith(
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF181419),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11.2,
          height: 1.35,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        waitDuration: Duration.zero,
        showDuration: const Duration(seconds: 8),
        preferBelow: false,
      ),
    );

    return _CharacterPillSurface(
      radius: 999,
      padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
      fillColor: Colors.white.withValues(alpha: 0.34),
      borderColor: Colors.white.withValues(alpha: 0.68),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.56),
          accentColor.withValues(alpha: 0.12),
          _lightenCharacterAccent(accentColor, 0.22).withValues(alpha: 0.08),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border(
                right: BorderSide(
                  color: accentColor.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
            ),
            child: const Icon(
              Icons.chat_bubble_rounded,
              size: 18,
              color: Color(0xFF171419),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isEditing
                ? TextField(
                    controller: controller,
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                    minLines: 1,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: showHintText ? hintText : null,
                      prefixText: '"',
                      suffixText: '"',
                      prefixStyle: TextStyle(
                        color: Colors.black.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                      suffixStyle: TextStyle(
                        color: Colors.black.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : CharacterMarkdownText(
                    data: '"${controller.text}"',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
          if ((tooltipText ?? '').trim().isNotEmpty) ...[
            const SizedBox(width: 8),
            Theme(
              data: tooltipTheme,
              child: Tooltip(
                message: tooltipText!,
                triggerMode: TooltipTriggerMode.tap,
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Colors.black.withValues(alpha: 0.42),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
