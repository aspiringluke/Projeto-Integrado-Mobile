part of 'project_page.dart';

class ProjectPage extends StatefulWidget {
  final int? projectId;
  final String title;
  final Color accentColor;
  final Color? coverColor;
  final ProjectImageData coverImage;
  final ProjectSectionId initialSection;
  final String initialCharacterDisplayMode;
  final int initialAvatarGridColumns;

  const ProjectPage({
    super.key,
    this.projectId,
    required this.title,
    this.accentColor = const Color(0xFFDF6EB8),
    this.coverColor,
    this.coverImage = const ProjectImageData(),
    this.initialSection = ProjectSectionId.configProjeto,
    this.initialCharacterDisplayMode = 'list',
    this.initialAvatarGridColumns = 3,
  });

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

enum ProjectSectionId {
  configProjeto,
  insights,
  diagrams,
  characters,
  notes,
  world,
}

enum CharacterDisplayMode { list, avatars }

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
  static const Map<ProjectSectionId, _ProjectSectionMeta> _sectionMeta =
      <ProjectSectionId, _ProjectSectionMeta>{
        ProjectSectionId.configProjeto: _ProjectSectionMeta(
          label: 'Página inicial',
          icon: Icons.tune_rounded,
          isImplemented: false,
        ),
        ProjectSectionId.insights: _ProjectSectionMeta(
          label: 'IA',
          icon: Icons.auto_awesome_outlined,
          isImplemented: false,
        ),
        ProjectSectionId.diagrams: _ProjectSectionMeta(
          label: 'Mapa',
          icon: Icons.account_tree_outlined,
          isImplemented: false,
        ),
        ProjectSectionId.characters: _ProjectSectionMeta(
          label: 'Personagens',
          icon: Icons.person_outline_rounded,
          isImplemented: true,
        ),
        ProjectSectionId.notes: _ProjectSectionMeta(
          label: 'Enredo',
          icon: Icons.edit_note_outlined,
          isImplemented: false,
        ),
        ProjectSectionId.world: _ProjectSectionMeta(
          label: 'Mundo',
          icon: Icons.public_outlined,
          isImplemented: false,
        ),
      };

  late ProjectSectionId _activeSection;
  bool _isCreateMenuOpen = false;
  final CharactersPinController _charactersPinController =
      const CharactersPinController();
  final CharacterRepository _characterRepository = CharacterRepository();
  final ProjectRepository _projectRepository = ProjectRepository();
  late List<CharacterListItem> _characters;
  late CharacterDisplayMode _characterDisplayMode;
  late int _avatarGridColumns;
  bool _isLoadingCharacters = false;
  String? _characterErrorMessage;
  int _characterLoadRequestToken = 0;

  @override
  void initState() {
    super.initState();
    _activeSection = widget.initialSection;
    _characters = <CharacterListItem>[];
    _characterDisplayMode = _characterDisplayModeFromStorage(
      widget.initialCharacterDisplayMode,
    );
    _avatarGridColumns = widget.initialAvatarGridColumns.clamp(2, 6);
    if (widget.projectId != null) {
      unawaited(_loadCharacters());
    }
  }

  String get _activeSectionLabel => _sectionMeta[_activeSection]!.label;

  void _setActiveSection(ProjectSectionId section) {
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
        content: Text('$label em construção.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _loadCharacters() async {
    final projectId = widget.projectId;
    if (projectId == null) {
      return;
    }

    final requestToken = ++_characterLoadRequestToken;
    setState(() {
      _isLoadingCharacters = true;
      _characterErrorMessage = null;
    });

    final result = await _characterRepository.listCharactersForProject(
      projectId,
    );
    if (!mounted || requestToken != _characterLoadRequestToken) {
      return;
    }

    setState(() {
      _isLoadingCharacters = false;
      if (!result.$1) {
        _characterErrorMessage = result.$3 ?? 'Falha ao carregar personagens';
        _characters = <CharacterListItem>[];
        return;
      }

      _characters = result.$2 ?? <CharacterListItem>[];
    });
  }

  Future<void> _persistProjectViewSettings() async {
    final projectId = widget.projectId;
    if (projectId == null) {
      return;
    }

    final result = await _projectRepository.updateProject(
      projectId,
      characterDisplayMode: _characterDisplayMode.name,
      characterGridColumns: _avatarGridColumns,
    );
    if (!result.$1 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.$2), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _persistCharacterOrdering() async {
    for (final character in _characters) {
      final characterId = character.id;
      if (characterId == null) {
        continue;
      }

      await _characterRepository.updateCharacter(
        characterId,
        projectTitle: widget.title,
        isPinned: character.isPinned,
        unpinnedIndex: character.unpinnedIndex,
        lastAccessed: character.lastAccessed,
      );
    }
  }

  Future<void> _touchCharacter(CharacterListItem character) async {
    final characterId = character.id;
    if (characterId == null) {
      return;
    }

    character.lastAccessed = DateTime.now();
    if (mounted) {
      setState(() {});
    }
    await _characterRepository.touchCharacter(characterId);
  }

  Future<void> _updateCharacter(
    CharacterListItem character,
    CharacterCardData updatedData,
  ) async {
    final previousName = character.data.name;
    final previousAccent = character.data.accent;

    setState(() {
      character.data = updatedData;
      character.lastModified = DateTime.now();
      character.lastAccessed = DateTime.now();
    });

    final characterId = character.id;
    if (characterId != null) {
      final result = await _characterRepository.updateCharacter(
        characterId,
        projectTitle: widget.title,
        data: updatedData,
        lastAccessed: character.lastAccessed,
      );
      if (!result.$1 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.$2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    if (previousName != updatedData.name ||
        previousAccent != updatedData.accent) {
      StoryRegistry.instance.updateCharacter(
        projectTitle: widget.title,
        oldName: previousName,
        newName: updatedData.name,
        accentColor: updatedData.accent,
      );
      return;
    }

    StoryRegistry.instance.registerCharacter(
      projectTitle: widget.title,
      name: updatedData.name,
      accentColor: updatedData.accent,
    );
  }

  void _setAvatarGridColumns(int columnCount) {
    if (columnCount < 2 || columnCount > 6) {
      return;
    }

    setState(() {
      _avatarGridColumns = columnCount;
    });
    unawaited(_persistProjectViewSettings());
  }

  Future<void> _createCharacter() async {
    _setActiveSection(ProjectSectionId.characters);
    final draft = await showCreateCharacterDialog(context);
    if (!mounted || draft == null) {
      return;
    }

    final projectId = widget.projectId;
    if (projectId == null) {
      return;
    }

    final now = DateTime.now();
    final created = await _characterRepository.createCharacter(
      CharacterListItem(
        projectId: projectId,
        projectTitle: widget.title,
        data: CharacterCardData(
          name: draft.name,
          alias: draft.alias,
          motto: draft.motto,
          formationsAndOccupations: draft.formationsAndOccupations,
          titles: draft.titles,
          genderTag: draft.genderTag,
          sexualityTag: draft.sexualityTag,
          ethnicityTag: draft.ethnicityTag,
          functionTag: draft.functionTag,
          relevanceTag: draft.relevanceTag,
          visibleProfileFields: draft.visibleProfileFields,
          accent: draft.accentColor,
          avatarColor: draft.coverColor,
          profileImage: draft.profileImage,
          icon: Icons.person_rounded,
          birthYear: 2000,
          birthDay: draft.birthDay,
          birthMonth: draft.birthMonth,
          heightCm: draft.heightCm,
          weightKg: draft.weightKg,
          quote: draft.motto,
          synopsis: draft.synopsis,
          seed: DateTime.now().microsecondsSinceEpoch,
        ),
        unpinnedIndex: _characters.where((item) => !item.isPinned).length,
        createdAt: now,
        lastModified: now,
        lastAccessed: now,
      ),
    );

    if (!mounted) {
      return;
    }

    if (!created.$1 || created.$2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(created.$3 ?? 'Falha ao criar personagem'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _characterLoadRequestToken += 1;
    setState(() {
      _characters.add(created.$2!);
      _isCreateMenuOpen = false;
      _isLoadingCharacters = false;
      _characterErrorMessage = null;
    });

    StoryRegistry.instance.registerCharacter(
      projectTitle: widget.title,
      name: draft.name,
      accentColor: draft.accentColor,
    );
  }

  void _createDiagram() {
    _closeCreateMenu();
    _showComingSoon('Novo diagrama');
  }

  Widget _buildCharactersSection() {
    if (_isLoadingCharacters) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_characterErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 160),
          child: Text(
            _characterErrorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF544959),
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return CharactersSection(
      characters: _characters,
      showAvatarGrid: _characterDisplayMode == CharacterDisplayMode.avatars,
      avatarGridColumns: _avatarGridColumns,
      onToggleDisplayMode: _toggleCharacterDisplayMode,
      onChangeAvatarGridColumns: _setAvatarGridColumns,
      onTogglePinned: _togglePinnedCharacter,
      onCharacterEdited: (character, updatedData) =>
          unawaited(_updateCharacter(character, updatedData)),
      onCharacterViewed: (character) => unawaited(_touchCharacter(character)),
    );
  }

  Widget _buildSectionBody() {
    return switch (_activeSection) {
      ProjectSectionId.characters => _buildCharactersSection(),
      _ => _UnderConstructionSection(
        icon: _sectionMeta[_activeSection]!.icon,
        title: _sectionMeta[_activeSection]!.label,
      ),
    };
  }

  void _togglePinnedCharacter(CharacterListItem character) {
    setState(() {
      _charactersPinController.togglePinned(_characters, character);
    });
    unawaited(_persistCharacterOrdering());
  }

  void _toggleCharacterDisplayMode() {
    setState(() {
      _characterDisplayMode = _characterDisplayMode == CharacterDisplayMode.list
          ? CharacterDisplayMode.avatars
          : CharacterDisplayMode.list;
    });
    unawaited(_persistProjectViewSettings());
  }

  @override
  Widget build(BuildContext context) {
    final resolvedCoverColor = widget.coverColor ?? widget.accentColor;
    final headerBackground = Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(
                  widget.accentColor.withValues(alpha: 0.08),
                  resolvedCoverColor.withValues(alpha: 0.92),
                ),
                Color.alphaBlend(
                  resolvedCoverColor.withValues(alpha: 0.88),
                  Colors.black.withValues(alpha: 0.06),
                ),
                Color.alphaBlend(
                  widget.accentColor.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.1),
                ),
              ],
              stops: const [0.0, 0.56, 1.0],
            ),
          ),
        ),
        if (widget.coverImage.bytes != null)
          Positioned.fill(
            child: Opacity(
              opacity: 0.78,
              child: ProjectImageTransformView(
                imageBytes: widget.coverImage.bytes!,
                imageWidth: widget.coverImage.width ?? 1,
                imageHeight: widget.coverImage.height ?? 1,
                scale: widget.coverImage.scale,
                offsetX: widget.coverImage.offsetX,
                offsetY: widget.coverImage.offsetY,
              ),
            ),
          ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.18),
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.16),
                ],
                stops: const [0.0, 0.34, 0.76, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.14),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.06),
                ],
                stops: const [0.0, 0.52, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
    final headerCenter = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              color: const Color(0xFFF8EFF5),
              fontSize: 31,
              fontWeight: FontWeight.w400,
              letterSpacing: 2.8,
              height: 1,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 2),
                ),
                Shadow(
                  color: Colors.white.withValues(alpha: 0.16),
                  blurRadius: 12,
                  offset: Offset.zero,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '...$_activeSectionLabel...',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFFF7EEF4).withValues(alpha: 0.92),
            fontSize: 13,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.3,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.34),
                blurRadius: 12,
                offset: const Offset(0, 1),
              ),
              Shadow(
                color: Colors.white.withValues(alpha: 0.16),
                blurRadius: 10,
                offset: Offset.zero,
              ),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      bottomNavigationBar: _ProjectFooterNav(
        accentColor: widget.accentColor,
        activeSection: _activeSection,
        onSelect: _setActiveSection,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/FUNDO.png', fit: BoxFit.cover),
          ),
          Column(
            children: [
              MainHeader(
                asSliver: false,
                title: widget.title,
                subtitle: _activeSectionLabel,
                onBackPressed: () => Navigator.of(context).pop(),
                onConfigPressed: () {},
                titleFontSize: 31,
                titleLetterSpacing: 2.8,
                contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                titleHorizontalPadding: 60,
                titleShadow: true,
                surroundSubtitleWithDots: true,
                centerChild: headerCenter,
                backgroundChild: headerBackground,
              ),
              const FuncoesBusca(),
              Expanded(child: _buildSectionBody()),
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
              accentColor: widget.accentColor,
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
      (ProjectSectionId.configProjeto, 'Página inicial', Icons.tune_rounded),
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
            blurSigma: 10,
            fillColor: accentColor.withValues(alpha: 0.58),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.88),
                _lightenProjectAccent(
                  accentColor,
                  0.18,
                ).withValues(alpha: 0.92),
                accentColor.withValues(alpha: 0.98),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderColor: Colors.white.withValues(alpha: 0.9),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: open ? 0.18 : 0.12),
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
