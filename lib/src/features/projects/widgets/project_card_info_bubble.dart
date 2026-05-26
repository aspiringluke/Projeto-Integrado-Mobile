part of 'project_card.dart';

Future<void> _showAnchoredInfoBubble({
  required BuildContext context,
  required Rect anchorRect,
  required Widget child,
  double width = 180,
}) {
  return showAnchoredInfoBubbleDialog(
    context: context,
    anchorRect: anchorRect,
    child: child,
    width: width,
    estimatedHeight: 130,
    bubbleBuilder:
        (
          context, {
          required showAbove,
          required pointerLeft,
          required arrowSize,
          required child,
        }) {
          return AnchoredInfoBubbleFrame(
            showAbove: showAbove,
            pointerLeft: pointerLeft,
            arrowSize: arrowSize,
            borderRadius: BorderRadius.circular(20),
            blurSigma: 12,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8FC).withValues(alpha: 0.78),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  const Color(0xFFFFF6FB).withValues(alpha: 0.84),
                  const Color(0xFFF2DCE8).withValues(alpha: 0.72),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.92),
                width: 0.9,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB96B92).withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.14),
                  Colors.white.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.24, 0.62],
              ),
            ),
            arrowColor: const Color(0xFFFFF7FB).withValues(alpha: 0.88),
            child: child,
          );
        },
  );
}

class _ProjectInfoButton extends StatelessWidget {
  final List<CharacterListItem> characters;
  final ValueChanged<CharacterListItem>? onCharacterTap;

  const _ProjectInfoButton({required this.characters, this.onCharacterTap});

  static const double _thumbnailSize = 44;
  static const double _thumbnailGap = 6;

  @override
  Widget build(BuildContext context) {
    if (characters.isEmpty) {
      return const SizedBox(
        height: 52,
        child: Align(
          alignment: Alignment.centerLeft,
          child: _DottedCircle(diameter: _thumbnailSize),
        ),
      );
    }

    final visibleCharacters = characters
        .take(projectShowcaseCharacterLimit)
        .toList(growable: false);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: _thumbnailGap,
          runSpacing: 8,
          children: [
            for (final character in visibleCharacters)
              Tooltip(
                message: character.data.name.trim().isEmpty
                    ? 'Abrir personagem'
                    : character.data.name,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onCharacterTap == null
                        ? null
                        : () => onCharacterTap!(character),
                    child: _ProjectCharacterThumbnail(
                      character: character,
                      size: _thumbnailSize,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCharacterThumbnail extends StatelessWidget {
  final CharacterListItem character;
  final double size;

  const _ProjectCharacterThumbnail({
    required this.character,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final image = character.data.profileImage;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            character.data.avatarColor.withValues(alpha: 0.95),
            character.data.accent.withValues(alpha: 0.78),
            Colors.white.withValues(alpha: 0.36),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.96),
          width: 1.35,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.72),
          width: 0.75,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.02),
            Colors.transparent,
          ],
          stops: const [0.0, 0.32, 0.72],
        ),
      ),
      child: ClipOval(
        child: image.bytes == null
            ? Icon(
                Icons.person_rounded,
                size: size * 0.56,
                color: const Color(0xFF171419).withValues(alpha: 0.7),
              )
            : ProjectImageTransformView(
                imageBytes: image.bytes!,
                imageWidth: image.width ?? size,
                imageHeight: image.height ?? size,
                scale: image.scale,
                offsetX: image.offsetX,
                offsetY: image.offsetY,
                viewportWidth: size,
                viewportHeight: size,
              ),
      ),
    );
  }
}

class _ProjectCharacterNamePill extends StatelessWidget {
  final CharacterListItem character;

  const _ProjectCharacterNamePill({required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.fromLTRB(5, 4, 9, 4),
      decoration: BoxDecoration(
        color: character.data.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: character.data.accent.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ProjectCharacterThumbnail(character: character, size: 24),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              character.data.name.trim().isEmpty
                  ? 'Sem nome'
                  : character.data.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF3E313A),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedCircle extends StatelessWidget {
  final double diameter;

  const _DottedCircle({required this.diameter});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: _DottedCirclePainter(
          color: const Color(0xFFB0B0B0),
          strokeWidth: 2.8,
        ),
      ),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _DottedCirclePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final dashLength = 5.0;
    final gapLength = 4.0;
    final dashAngle = dashLength / radius;
    final gapAngle = gapLength / radius;

    for (
      var startAngle = 0.0;
      startAngle < 2 * 3.1415926535897932;
      startAngle += dashAngle + gapAngle
    ) {
      canvas.drawArc(rect, startAngle, dashAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
