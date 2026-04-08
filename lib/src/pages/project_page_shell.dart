part of 'project_page.dart';

class ProjectPage extends StatefulWidget {
  final String title;

  const ProjectPage({super.key, required this.title});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

enum _ProjectSectionId { home, insights, diagrams, characters, notes, world }

class _ProjectSectionMeta {
  final String label;
  final IconData icon;
  final bool isImplemented;

  const _ProjectSectionMeta({
    required this.label,
    required this.icon,
    required this.isImplemented,
  });
}

class _ProjectPageState extends State<ProjectPage> {
  static const Map<_ProjectSectionId, _ProjectSectionMeta> _sectionMeta =
      <_ProjectSectionId, _ProjectSectionMeta>{
        _ProjectSectionId.home: _ProjectSectionMeta(
          label: 'Pagina inicial',
          icon: Icons.home_outlined,
          isImplemented: false,
        ),
        _ProjectSectionId.insights: _ProjectSectionMeta(
          label: 'IA',
          icon: Icons.auto_awesome_outlined,
          isImplemented: false,
        ),
        _ProjectSectionId.diagrams: _ProjectSectionMeta(
          label: 'Mapa',
          icon: Icons.account_tree_outlined,
          isImplemented: false,
        ),
        _ProjectSectionId.characters: _ProjectSectionMeta(
          label: 'Personagens',
          icon: Icons.person_outline_rounded,
          isImplemented: true,
        ),
        _ProjectSectionId.notes: _ProjectSectionMeta(
          label: 'Enredo',
          icon: Icons.edit_note_outlined,
          isImplemented: false,
        ),
        _ProjectSectionId.world: _ProjectSectionMeta(
          label: 'Mundo',
          icon: Icons.public_outlined,
          isImplemented: false,
        ),
      };

  _ProjectSectionId _activeSection = _ProjectSectionId.characters;
  bool _isCreateMenuOpen = false;

  String get _activeSectionLabel => _sectionMeta[_activeSection]!.label;

  void _setActiveSection(_ProjectSectionId section) {
    setState(() {
      _activeSection = section;
      _isCreateMenuOpen = false;
    });
  }

  void _toggleCreateMenu() {
    setState(() {
      _isCreateMenuOpen = !_isCreateMenuOpen;
    });
  }

  void _closeCreateMenu() {
    if (!_isCreateMenuOpen) {
      return;
    }

    setState(() {
      _isCreateMenuOpen = false;
    });
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label em construcao.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _createCharacter() {
    _setActiveSection(_ProjectSectionId.characters);
    _showComingSoon('Novo personagem');
  }

  void _createDiagram() {
    _closeCreateMenu();
    _showComingSoon('Novo diagrama');
  }

  Widget _buildSectionBody() {
    return switch (_activeSection) {
      _ProjectSectionId.characters => const _CharactersSection(),
      _ => _UnderConstructionSection(
          icon: _sectionMeta[_activeSection]!.icon,
          title: _sectionMeta[_activeSection]!.label,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      bottomNavigationBar: _ProjectFooterNav(
        activeSection: _activeSection,
        onSelect: _setActiveSection,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/FUNDO.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              _ProjectHeaderBar(
                title: widget.title,
                subtitle: _activeSectionLabel,
              ),
              const FuncoesBusca(),
              Expanded(
                child: _buildSectionBody(),
              ),
            ],
          ),
          if (_isCreateMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeCreateMenu,
                child: const SizedBox.expand(),
              ),
            ),
          Positioned(
            right: 18,
            bottom: 88,
            child: _ProjectCreateFab(
              isOpen: _isCreateMenuOpen,
              onToggle: _toggleCreateMenu,
              onCreateCharacter: _createCharacter,
              onCreateDiagram: _createDiagram,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectHeaderBar extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ProjectHeaderBar({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.ralewayDots(
      color: const Color(0xFFF8EFF5),
      fontSize: 31,
      fontWeight: FontWeight.w400,
      letterSpacing: 2.8,
      height: 1,
      shadows: [
        Shadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 1.5),
        ),
      ],
    );

    return Container(
      height: 118,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF726876),
            Color(0xFFB083AA),
            Color(0xFFDF6EB8),
          ],
          stops: [0, 0.56, 1],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: 0,
                top: 10,
                child: BotaoVoltar(
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Positioned(
                right: 0,
                top: 10,
                child: BotaoConfig(
                  onPressed: () {},
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          title.toUpperCase(),
                          maxLines: 1,
                          style: titleStyle,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '...$subtitle...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFF7EEF4).withValues(alpha: 0.9),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectQuickRail extends StatelessWidget {
  final List<_ProjectSectionId> sections;
  final _ProjectSectionId activeSection;
  final _ProjectSectionId? armedSection;
  final Map<_ProjectSectionId, _ProjectSectionMeta> sectionMeta;
  final ValueChanged<_ProjectSectionId> onTapSection;
  final ValueChanged<_ProjectSectionId> onLongPressSection;

  const _ProjectQuickRail({
    required this.sections,
    required this.activeSection,
    required this.armedSection,
    required this.sectionMeta,
    required this.onTapSection,
    required this.onLongPressSection,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 62,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.48),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final section in sections)
                _QuickRailItem(
                  meta: sectionMeta[section]!,
                  isActive: activeSection == section,
                  showLabel: armedSection == section,
                  onTap: () => onTapSection(section),
                  onLongPress: () => onLongPressSection(section),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickRailItem extends StatelessWidget {
  final _ProjectSectionMeta meta;
  final bool isActive;
  final bool showLabel;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _QuickRailItem({
    required this.meta,
    required this.isActive,
    required this.showLabel,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (showLabel)
            Positioned(
              right: 54,
              top: 8,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF544959).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    meta.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: 50,
                height: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: isActive ? 1 : 0.5,
                      child: Icon(
                        meta.icon,
                        color: const Color(0xFF544959),
                        size: 25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: isActive ? 1 : 0,
                      child: Container(
                        width: 14,
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDF6EB8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingRoundButton extends StatelessWidget {
  final double diameter;
  final Color background;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _FloatingRoundButton({
    required this.diameter,
    required this.background,
    required this.icon,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: background,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.42),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: const Color(0xFF171419),
            size: diameter * 0.46,
          ),
        ),
      ),
    );
  }
}

class _ProjectBottomSheetFrame extends StatelessWidget {
  final String title;
  final Widget child;

  const _ProjectBottomSheetFrame({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.52),
                width: 0.8,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C262C),
                  ),
                ),
                const SizedBox(height: 14),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionToggleTile extends StatelessWidget {
  final _ProjectSectionMeta meta;
  final bool isSaved;
  final bool isLocked;
  final VoidCallback onTap;

  const _SectionToggleTile({
    required this.meta,
    required this.isSaved,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : onTap,
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
                Icon(meta.icon, color: const Color(0xFF544959)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    meta.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C262C),
                    ),
                  ),
                ),
                if (isLocked)
                  Text(
                    'atual',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.42),
                      fontSize: 12,
                    ),
                  )
                else
                  Icon(
                    isSaved ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                    color: isSaved ? const Color(0xFFDF6EB8) : const Color(0xFF544959),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectFooterNav extends StatelessWidget {
  final _ProjectSectionId activeSection;
  final ValueChanged<_ProjectSectionId> onSelect;

  const _ProjectFooterNav({
    required this.activeSection,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    const items = <(_ProjectSectionId, String, IconData)>[
      (_ProjectSectionId.home, 'Pagina inicial', Icons.home_rounded),
      (_ProjectSectionId.characters, 'Personagens', Icons.person_outline_rounded),
      (_ProjectSectionId.notes, 'Enredo', Icons.auto_stories_outlined),
      (_ProjectSectionId.world, 'Mundo', Icons.public_outlined),
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
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ProjectFooterItem({
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
                    color: const Color(0xFF1B171C),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: isActive ? 16 : 0,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDF6EB8),
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
  final bool? isOpen;
  final VoidCallback onToggle;
  final VoidCallback onCreateCharacter;
  final VoidCallback onCreateDiagram;

  const _ProjectCreateFab({
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
                    tint: const Color(0xFFDBD8DE),
                    tooltip: 'Novo diagrama',
                    onTap: onCreateDiagram,
                  ),
                  const SizedBox(height: 10),
                  _CreateActionButton(
                    icon: Icons.person_add_alt_1_rounded,
                    tint: const Color(0xFFF0C7DE),
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
            blurSigma: 10,
            fillColor: const Color(0xFFF3D5E3).withValues(alpha: 0.58),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.88),
                const Color(0xFFF1D1E2).withValues(alpha: 0.92),
                const Color(0xFFE8BAD3).withValues(alpha: 0.98),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderColor: Colors.white.withValues(alpha: 0.9),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDF6EB8).withValues(alpha: open ? 0.18 : 0.12),
                blurRadius: open ? 18 : 14,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
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
      blurSigma: 8,
      fillColor: tint.withValues(alpha: 0.82),
      borderColor: Colors.white.withValues(alpha: 0.88),
      borderWidth: 0.85,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      child: Icon(
        icon,
        size: 21,
        color: const Color(0xFF171419),
      ),
    );
  }
}

class _UnderConstructionSection extends StatelessWidget {
  final IconData icon;
  final String title;

  const _UnderConstructionSection({
    required this.icon,
    required this.title,
  });

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
                    'Esta secao ainda esta em construcao dentro do projeto.',
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
