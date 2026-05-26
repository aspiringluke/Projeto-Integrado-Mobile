part of '../character_fields.dart';

class CharacterTimeField extends StatelessWidget {
  final Color accentColor;
  final CharacterDateEntry dateEntry;
  final VoidCallback onTapClock;

  const CharacterTimeField({
    super.key,
    required this.accentColor,
    required this.dateEntry,
    required this.onTapClock,
  });

  @override
  Widget build(BuildContext context) {
    const circleDiameter = 38.0;
    const fieldHeight = 38.0;
    const pillLeftInset = 8.0;

    return SizedBox(
      height: fieldHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            left: pillLeftInset,
            child: _CharacterPillSurface(
              radius: fieldHeight / 2,
              blurSigma: 9,
              padding: const EdgeInsets.only(left: 40, right: 31),
              fillColor: accentColor.withValues(alpha: 0.16),
              borderColor: Colors.white.withValues(alpha: 0.84),
              borderWidth: 0.75,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.64),
                  accentColor.withValues(alpha: 0.18),
                  _lightenCharacterAccent(
                    accentColor,
                    0.24,
                  ).withValues(alpha: 0.12),
                ],
                stops: const [0.0, 0.48, 1.0],
              ),
              child: Text(
                '${dateEntry.label}: ${formatDateTime(dateEntry.value)}, ${formatRelativePhrase(dateEntry.value)}.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF2C262C),
                  fontSize: 10.5,
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
                  _lightenCharacterAccent(
                    accentColor,
                    0.18,
                  ).withValues(alpha: 0.52),
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
}

class MiniGlassButton extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final VoidCallback onTap;
  final Color? fillColor;

  const MiniGlassButton({
    super.key,
    required this.accentColor,
    required this.icon,
    required this.onTap,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedFillColor = fillColor ?? accentColor.withValues(alpha: 0.22);

    return GlassCircleButton(
      diameter: 34,
      onTap: onTap,
      blurSigma: 8,
      fillColor: resolvedFillColor,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.58),
          accentColor.withValues(alpha: 0.22),
          _lightenCharacterAccent(accentColor, 0.22).withValues(alpha: 0.18),
        ],
      ),
      borderColor: Colors.white.withValues(alpha: 0.8),
      boxShadow: [
        BoxShadow(
          color: accentColor.withValues(alpha: 0.14),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 9,
          offset: const Offset(0, 3),
        ),
      ],
      child: Icon(icon, color: const Color(0xFF544959), size: 17),
    );
  }
}

class _CharacterPillSurface extends StatelessWidget {
  final Widget child;
  final double radius;
  final double? width;
  final double? height;
  final double blurSigma;
  final EdgeInsetsGeometry padding;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final Gradient? gradient;
  final AlignmentGeometry alignment;

  const _CharacterPillSurface({
    required this.child,
    required this.radius,
    this.width,
    this.height,
    this.blurSigma = 0,
    this.padding = EdgeInsets.zero,
    this.fillColor = const Color(0x6BFFFFFF),
    this.borderColor = const Color(0xAAFFFFFF),
    this.borderWidth = 0.8,
    this.gradient,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor,
        gradient:
            gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.66),
                Color.alphaBlend(
                  const Color(0xFFF6EEF3).withValues(alpha: 0.32),
                  fillColor,
                ),
                Color.alphaBlend(
                  const Color(0xFFE3D8E0).withValues(alpha: 0.18),
                  fillColor,
                ),
              ],
              stops: const [0.0, 0.52, 1.0],
            ),
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
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.03),
            Colors.transparent,
          ],
          stops: const [0.0, 0.22, 0.52],
        ),
      ),
      child: child,
    );

    return content;
  }
}
