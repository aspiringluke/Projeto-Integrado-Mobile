part of '../character_card.dart';

class _CharacterHeader extends StatelessWidget {
  final CharacterCardData data;
  final bool isExpanded;
  final Radius bottomRadius;
  final VoidCallback onOpenCharacterPage;
  final VoidCallback onOpenCharacterProfileViewer;
  final VoidCallback onToggleExpand;
  final VoidCallback? onDelete;

  const _CharacterHeader({
    required this.data,
    required this.isExpanded,
    required this.bottomRadius,
    required this.onOpenCharacterPage,
    required this.onOpenCharacterProfileViewer,
    required this.onToggleExpand,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(16),
          bottom: bottomRadius,
        ),
        border: Border(
          bottom: BorderSide(
            color: isExpanded
                ? Colors.white.withValues(alpha: 0.22)
                : Colors.transparent,
            width: 0.7,
          ),
        ),
      ),
      child: SizedBox(
        height: characterProfileTileHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(16),
                    bottom: bottomRadius,
                  ),
                  gradient: _buildCharacterHeaderGradient(
                    data.accent,
                    data.avatarColor,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: CharacterAvatarTile(
                accent: data.accent,
                avatarColor: data.avatarColor,
                profileImage: data.profileImage,
                isExpanded: isExpanded,
                onTap: data.profileImage.bytes == null
                    ? null
                    : onOpenCharacterProfileViewer,
              ),
            ),
            Positioned.fill(
              left: characterProfileTileWidth,
              right: 98,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onOpenCharacterPage,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isExpanded
                                  ? const Color(0xFFF9F6FA)
                                  : const Color(0xFFF7F4F8),
                              fontSize: 18.5,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.52),
                                  blurRadius: 14,
                                  offset: const Offset(0, 3),
                                ),
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.28),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            data.alias,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.86),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.16),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 26,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(16),
                      bottom: Radius.circular(bottomRadius.x),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onDelete != null) ...[
                      GlassCircleButton(
                        diameter: 34,
                        onTap: onDelete,
                        tooltip: 'Excluir personagem',
                        fillColor: Colors.white.withValues(alpha: 0.18),
                        borderColor: Colors.white.withValues(alpha: 0.78),
                        borderWidth: 0.9,
                        blurSigma: 9,
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white.withValues(alpha: 0.95),
                          size: 18,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.24),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    GlassCircleButton(
                      diameter: 34,
                      onTap: onToggleExpand,
                      tooltip: isExpanded ? 'Recolher' : 'Expandir',
                      fillColor: Colors.white.withValues(alpha: 0.18),
                      borderColor: Colors.white.withValues(alpha: 0.78),
                      borderWidth: 0.9,
                      blurSigma: 9,
                      child: AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white.withValues(alpha: 0.95),
                          size: 25,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.24),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZodiacTraitPill extends StatelessWidget {
  final String label;

  const _ZodiacTraitPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4EEF3).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.82),
          width: 0.7,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.6),
            fontSize: 10.5,
            fontStyle: FontStyle.italic,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _HeightUnitOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _HeightUnitOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.42),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C262C),
                    ),
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? const Color(0xFFDF6EB8)
                      : const Color(0xFF544959),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterBirthdayWheel extends StatelessWidget {
  final String label;
  final FixedExtentScrollController controller;
  final ValueChanged<int> onSelectedItemChanged;
  final List<Widget> children;

  const _CharacterBirthdayWheel({
    required this.label,
    required this.controller,
    required this.onSelectedItemChanged,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.32),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.58),
                    width: 0.8,
                  ),
                ),
                child: CupertinoTheme(
                  data: const CupertinoThemeData(brightness: Brightness.light),
                  child: CupertinoPicker(
                    scrollController: controller,
                    itemExtent: 36,
                    diameterRatio: 1.25,
                    useMagnifier: true,
                    magnification: 1.06,
                    selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                      background: const Color(0x1CFFFFFF),
                    ),
                    onSelectedItemChanged: onSelectedItemChanged,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
    estimatedHeight: 110,
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
            borderRadius: BorderRadius.circular(18),
            blurSigma: 10,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.86),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            arrowColor: Colors.white.withValues(alpha: 0.9),
            child: child,
          );
        },
  );
}

LinearGradient _buildCharacterShellGradient(
  Color accentColor, {
  required bool isExpanded,
}) {
  final leading = Color.alphaBlend(
    accentColor.withValues(alpha: isExpanded ? 0.16 : 0.08),
    Colors.white.withValues(alpha: 0.84),
  );
  final center = Colors.white.withValues(alpha: isExpanded ? 0.82 : 0.76);
  final trailing = Color.alphaBlend(
    _lightenCharacterColor(
      accentColor,
      0.22,
    ).withValues(alpha: isExpanded ? 0.18 : 0.1),
    const Color(0xFFF8F2F6).withValues(alpha: 0.82),
  );

  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [leading, center, trailing],
    stops: const [0.0, 0.48, 1.0],
  );
}

LinearGradient _buildCharacterHeaderGradient(Color accent, Color avatarColor) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.alphaBlend(
        accent.withValues(alpha: 0.78),
        const Color(0xFF8A7485).withValues(alpha: 0.88),
      ),
      Color.alphaBlend(
        avatarColor.withValues(alpha: 0.2),
        Colors.white.withValues(alpha: 0.18),
      ),
      Color.alphaBlend(
        _lightenCharacterColor(accent, 0.18).withValues(alpha: 0.92),
        Colors.white.withValues(alpha: 0.16),
      ),
    ],
    stops: const [0.0, 0.58, 1.0],
  );
}

LinearGradient _buildCharacterDetailsGradient(Color accentColor) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      accentColor.withValues(alpha: 0.12),
      Colors.white.withValues(alpha: 0.5),
      const Color(0xFFF6F1F4).withValues(alpha: 0.36),
    ],
    stops: const [0.0, 0.46, 1.0],
  );
}

Color _lightenCharacterColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}
