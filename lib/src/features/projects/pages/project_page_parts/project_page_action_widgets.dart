part of '../project_page.dart';

class _ProjectFooterNav extends StatelessWidget {
  final Color accentColor;
  final ProjectSectionId activeSection;
  final ValueChanged<ProjectSectionId> onSelect;

  const _ProjectFooterNav({
    required this.accentColor,
    required this.activeSection,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    const items = <(ProjectSectionId, String, IconData)>[
      (ProjectSectionId.configProjeto, 'Geral', Icons.tune_rounded),
      (
        ProjectSectionId.characters,
        'Personagens',
        Icons.person_outline_rounded,
      ),
      (ProjectSectionId.notes, 'Enredo', Icons.auto_stories_outlined),
      (ProjectSectionId.world, 'Mundo', Icons.public_outlined),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 66,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.7),
                    const Color(0xFFF1EDF1).withValues(alpha: 0.58),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.75),
                  width: 0.85,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  for (final item in items)
                    Expanded(
                      child: _ProjectFooterItem(
                        accentColor: accentColor,
                        label: item.$2,
                        icon: item.$3,
                        isActive: activeSection == item.$1,
                        onTap: () => onSelect(item.$1),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectFooterItem extends StatelessWidget {
  final Color accentColor;
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ProjectFooterItem({
    required this.accentColor,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: isActive ? 1 : 0.5,
                  child: Icon(
                    icon,
                    size: 25,
                    color: isActive
                        ? _darkenProjectAccent(accentColor, 0.34)
                        : const Color(0xFF1B171C),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: isActive ? 16 : 0,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectCreateFab extends StatelessWidget {
  final Color accentColor;
  final bool? isOpen;
  final VoidCallback onToggle;
  final VoidCallback onCreateCharacter;
  final VoidCallback onCreateDiagram;

  const _ProjectCreateFab({
    required this.accentColor,
    required this.isOpen,
    required this.onToggle,
    required this.onCreateCharacter,
    required this.onCreateDiagram,
  });

  @override
  Widget build(BuildContext context) {
    final open = isOpen ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IgnorePointer(
          ignoring: !open,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: open ? 1 : 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              offset: open ? Offset.zero : const Offset(0, 0.16),
              curve: Curves.easeOutCubic,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _CreateActionButton(
                    icon: Icons.account_tree_outlined,
                    tint: _lightenProjectAccent(accentColor, 0.3),
                    tooltip: 'Novo diagrama',
                    onTap: onCreateDiagram,
                  ),
                  const SizedBox(height: 10),
                  _CreateActionButton(
                    icon: Icons.person_add_alt_1_rounded,
                    tint: _lightenProjectAccent(accentColor, 0.18),
                    tooltip: 'Novo personagem',
                    onTap: onCreateCharacter,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
        AnimatedScale(
          scale: open ? 1.04 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: GlassCircleButton(
            diameter: 52,
            onTap: onToggle,
            blurSigma: 18,
            fillColor: Colors.white.withValues(alpha: 0.2),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.54),
                _lightenProjectAccent(
                  accentColor,
                  0.18,
                ).withValues(alpha: 0.34),
                accentColor.withValues(alpha: 0.42),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderColor: Colors.white.withValues(alpha: 0.72),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: open ? 0.2 : 0.14),
                blurRadius: open ? 22 : 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            child: AnimatedRotation(
              turns: open ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: const Icon(
                Icons.add_rounded,
                color: Color(0xFF171419),
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CreateActionButton extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String tooltip;
  final VoidCallback onTap;

  const _CreateActionButton({
    required this.icon,
    required this.tint,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCircleButton(
      diameter: 44,
      onTap: onTap,
      tooltip: tooltip,
      blurSigma: 16,
      fillColor: Colors.white.withValues(alpha: 0.18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.52),
          tint.withValues(alpha: 0.32),
          tint.withValues(alpha: 0.42),
        ],
        stops: const [0.0, 0.55, 1.0],
      ),
      borderColor: Colors.white.withValues(alpha: 0.72),
      borderWidth: 0.85,
      boxShadow: [
        BoxShadow(
          color: tint.withValues(alpha: 0.16),
          blurRadius: 16,
          offset: const Offset(0, 5),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 11,
          offset: const Offset(0, 4),
        ),
      ],
      child: Icon(icon, size: 21, color: const Color(0xFF171419)),
    );
  }
}

Color _lightenProjectAccent(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}

Color _darkenProjectAccent(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

CharacterDisplayMode _characterDisplayModeFromStorage(String rawValue) {
  return rawValue == CharacterDisplayMode.avatars.name
      ? CharacterDisplayMode.avatars
      : CharacterDisplayMode.list;
}

class _UnderConstructionSection extends StatelessWidget {
  final IconData icon;
  final String title;

  const _UnderConstructionSection({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 150),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.34),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.46),
                  width: 0.8,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 42, color: const Color(0xFF544959)),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C262C),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Esta seção ainda está em construção dentro do projeto.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.58),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
