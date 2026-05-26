part of '../project_card.dart';

class _TimeField extends StatelessWidget {
  final Color accentColor;
  final _ProjectDateEntry dateEntry;
  final VoidCallback onTapClock;

  const _TimeField({
    required this.accentColor,
    required this.dateEntry,
    required this.onTapClock,
  });

  @override
  Widget build(BuildContext context) {
    const circleDiameter = 38.0;
    const fieldHeight = 50.0;
    const pillLeftInset = 8.0;

    return SizedBox(
      height: fieldHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            left: pillLeftInset,
            child: _GlassSurface(
              radius: fieldHeight / 2,
              blurSigma: 9,
              padding: const EdgeInsets.only(left: 40, right: 31),
              fillColor: accentColor.withValues(alpha: 0.16),
              borderColor: Colors.white.withValues(alpha: 0.84),
              borderWidth: 0.75,
              alignment: Alignment.centerLeft,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.64),
                  accentColor.withValues(alpha: 0.18),
                  _lighten(accentColor, 0.24).withValues(alpha: 0.12),
                ],
                stops: [0.0, 0.48, 1.0],
              ),
              child: Text(
                _formatDateLabel(dateEntry),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF2C262C),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: GlassCircleButton(
              diameter: circleDiameter,
              onTap: onTapClock,
              blurSigma: 8,
              fillColor: accentColor.withValues(alpha: 0.42),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.7),
                  _lighten(accentColor, 0.18).withValues(alpha: 0.52),
                  accentColor.withValues(alpha: 0.42),
                ],
              ),
              borderColor: Colors.white.withValues(alpha: 0.84),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.12),
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              child: const Icon(
                Icons.history_rounded,
                size: 19,
                color: Color(0xFF171419),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateLabel(_ProjectDateEntry entry) {
    return '${entry.label}: ${_formatRelativePhrase(entry.value)}\n${_formatDate(entry.value)}';
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString().padLeft(4, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  String _formatRelativePhrase(DateTime value) {
    final difference = DateTime.now().difference(value);

    if (difference.inMinutes < 1) return 'h\u00E1 menos de 1 minuto';
    if (difference.inMinutes < 60) {
      return 'h\u00E1 ${_pluralize(difference.inMinutes, 'minuto', 'minutos')}';
    }
    if (difference.inHours < 24) {
      return 'h\u00E1 ${_pluralize(difference.inHours, 'hora', 'horas')}';
    }
    if (difference.inDays < 7) {
      return 'h\u00E1 ${_pluralize(difference.inDays, 'dia', 'dias')}';
    }
    if (difference.inDays < 30) {
      return 'h\u00E1 ${_pluralize((difference.inDays / 7).floor(), 'semana', 'semanas')}';
    }
    if (difference.inDays < 365) {
      return 'h\u00E1 ${_pluralize((difference.inDays / 30).floor(), 'm\u00EAs', 'meses')}';
    }
    return 'h\u00E1 ${_pluralize((difference.inDays / 365).floor(), 'ano', 'anos')}';
  }

  String _pluralize(int value, String singular, String plural) {
    final normalizedValue = value < 1 ? 1 : value;
    return normalizedValue == 1 ? '1 $singular' : '$normalizedValue $plural';
  }
}

class _ProjectMarkdownText extends StatelessWidget {
  final String data;
  final TextStyle style;

  const _ProjectMarkdownText({required this.data, required this.style});

  @override
  Widget build(BuildContext context) {
    final sanitizedData = _sanitizeProjectMarkdown(data);
    final normalizedData = sanitizedData.trim().isEmpty ? ' ' : sanitizedData;
    final styleSheet = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: style,
      pPadding: EdgeInsets.zero,
      blockSpacing: 0,
      listIndent: 18,
      listBullet: style,
      listBulletPadding: const EdgeInsets.only(right: 6),
      strong: style.copyWith(fontWeight: FontWeight.w700),
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

String _sanitizeProjectMarkdown(String data) {
  final withoutHtml = data.replaceAll(RegExp(r'<[^>]*>'), '');
  final rawLines = withoutHtml.split('\n');
  final sanitizedLines = <String>[];
  final atxHeadingPattern = RegExp(r'^\s{0,3}#{1,6}\s*');
  final setextHeadingPattern = RegExp(r'^\s{0,3}(=+|-+)\s*$');

  for (final line in rawLines) {
    final normalizedLine = line.replaceFirst(atxHeadingPattern, '');

    if (setextHeadingPattern.hasMatch(normalizedLine) &&
        sanitizedLines.isNotEmpty &&
        sanitizedLines.last.trim().isNotEmpty) {
      continue;
    }

    sanitizedLines.add(normalizedLine);
  }

  return sanitizedLines.join('\n');
}

class _GlassSurface extends StatelessWidget {
  final Widget? child;
  final double radius;
  final double blurSigma;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final Gradient? gradient;

  const _GlassSurface({
    this.child,
    required this.radius,
    this.blurSigma = 8,
    this.padding = const EdgeInsets.all(0),
    this.alignment = Alignment.center,
    required this.fillColor,
    required this.borderColor,
    this.borderWidth = 0.8,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient =
        gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(Colors.white.withValues(alpha: 0.14), fillColor),
            fillColor,
            Color.alphaBlend(Colors.black.withValues(alpha: 0.03), fillColor),
          ],
          stops: const [0.0, 0.52, 1.0],
        );
    final surface = Container(
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor,
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.10),
            Colors.white.withValues(alpha: 0.03),
            Colors.transparent,
          ],
          stops: const [0.0, 0.22, 0.52],
        ),
      ),
      child: child,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: surface,
      ),
    );
  }
}
