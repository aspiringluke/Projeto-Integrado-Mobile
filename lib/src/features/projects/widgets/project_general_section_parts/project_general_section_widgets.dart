part of '../project_general_section.dart';

class _SectionSurface extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final String label;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget? trailing;
  final WidgetBuilder childBuilder;

  const _SectionSurface({
    required this.accentColor,
    required this.icon,
    required this.label,
    required this.isExpanded,
    required this.onToggle,
    required this.childBuilder,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.46),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onToggle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SectionTitle(
                            icon: icon,
                            label: label,
                            accentColor: accentColor,
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: 8),
                          trailing!,
                        ],
                        const SizedBox(width: 6),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 23,
                            color: _darken(accentColor, 0.18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: isExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: childBuilder(context),
                      )
                    : const SizedBox(width: double.infinity),
                secondChild: const SizedBox(width: double.infinity),
                crossFadeState: isExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 180),
                sizeCurve: Curves.easeOutCubic,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;

  const _SectionTitle({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _darken(accentColor, 0.18)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF2C262C),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _FeaturedCharacterPreviewRow extends StatelessWidget {
  final Color accentColor;
  final List<CharacterListItem> characters;

  const _FeaturedCharacterPreviewRow({
    required this.accentColor,
    required this.characters,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var index = 0; index < projectShowcaseCharacterLimit; index += 1)
          _FeaturedCharacterAvatar(
            character: index < characters.length ? characters[index] : null,
            accentColor: accentColor,
            size: 38,
          ),
      ],
    );
  }
}

class _FeaturedCharacterChoiceChip extends StatelessWidget {
  final CharacterListItem character;
  final Color accentColor;
  final bool selected;
  final bool disabled;
  final bool automaticPreview;
  final VoidCallback onTap;

  const _FeaturedCharacterChoiceChip({
    required this.character,
    required this.accentColor,
    required this.selected,
    required this.disabled,
    required this.automaticPreview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = character.data.accent;
    final borderColor = selected
        ? effectiveAccent.withValues(alpha: 0.72)
        : automaticPreview
        ? accentColor.withValues(alpha: 0.42)
        : Colors.white.withValues(alpha: 0.82);

    return Opacity(
      opacity: disabled ? 0.46 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: disabled ? null : onTap,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 190),
            padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
            decoration: BoxDecoration(
              color: selected
                  ? effectiveAccent.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.52),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor, width: selected ? 1 : 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FeaturedCharacterAvatar(
                  character: character,
                  accentColor: effectiveAccent,
                  size: 28,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    character.data.name.trim().isEmpty
                        ? 'Sem nome'
                        : character.data.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF2C262C),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 5),
                  Icon(Icons.check_rounded, size: 15, color: effectiveAccent),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedCharacterAvatar extends StatelessWidget {
  final CharacterListItem? character;
  final Color accentColor;
  final double size;

  const _FeaturedCharacterAvatar({
    required this.character,
    required this.accentColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final image = character?.data.profileImage;
    final color = character?.data.avatarColor ?? accentColor;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.92),
            accentColor.withValues(alpha: 0.62),
            Colors.white.withValues(alpha: 0.42),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
      ),
      child: ClipOval(
        child: image?.bytes == null
            ? Icon(
                Icons.person_rounded,
                size: size * 0.56,
                color: const Color(0xFF171419).withValues(alpha: 0.72),
              )
            : ProjectImageTransformView(
                imageBytes: image!.bytes!,
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

Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}
