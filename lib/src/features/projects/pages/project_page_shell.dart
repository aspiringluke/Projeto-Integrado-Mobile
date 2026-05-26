part of 'project_page.dart';

class ProjectPage extends StatefulWidget {
  final int? projectId;
  final String title;
  final String synopsis;
  final List<ProjectTagData> tags;
  final Color accentColor;
  final Color? coverColor;
  final ProjectImageData coverImage;
  final ProjectImageData accentImage;
  final List<ProjectTagData> availableTags;
  final DateTime? createdAt;
  final DateTime? lastModified;
  final DateTime? lastAccessed;
  final bool isPinned;
  final int unpinnedIndex;
  final ProjectSectionId initialSection;
  final String initialCharacterDisplayMode;
  final int initialAvatarGridColumns;
  final List<int> featuredCharacterIds;

  const ProjectPage({
    super.key,
    this.projectId,
    required this.title,
    this.synopsis = '',
    this.tags = const <ProjectTagData>[],
    this.accentColor = const Color(0xFFDF6EB8),
    this.coverColor,
    this.coverImage = const ProjectImageData(),
    this.accentImage = const ProjectImageData(),
    this.availableTags = const <ProjectTagData>[],
    this.createdAt,
    this.lastModified,
    this.lastAccessed,
    this.isPinned = false,
    this.unpinnedIndex = 0,
    this.initialSection = ProjectSectionId.configProjeto,
    this.initialCharacterDisplayMode = 'list',
    this.initialAvatarGridColumns = 3,
    this.featuredCharacterIds = const <int>[],
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
          label: 'Geral',
          icon: Icons.tune_rounded,
          isImplemented: true,
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
  late ProjectRecord _projectDraft;
  late CharacterDisplayMode _characterDisplayMode;
  late int _avatarGridColumns;
  late final TextEditingController _characterSearchController;
  String _characterSearchQuery = '';
  ContentFilterState _characterFilter = const ContentFilterState();
  ContentSortState _characterSort = const ContentSortState();
  bool _isLoadingCharacters = false;
  String? _characterErrorMessage;
  int _characterLoadRequestToken = 0;
  bool _hasPendingProjectChanges = false;
  bool _isClosing = false;
  late String _lastPersistedProjectTitle;
  late final ValueNotifier<String> _projectTitleNotifier;

  @override
  void initState() {
    super.initState();
    _activeSection = widget.initialSection;
    _characters = <CharacterListItem>[];
    final now = DateTime.now();
    _projectDraft = ProjectRecord(
      id: widget.projectId,
      title: widget.title,
      synopsis: widget.synopsis,
      tags: widget.tags,
      coverColor: widget.coverColor ?? widget.accentColor,
      accentColor: widget.accentColor,
      coverImage: widget.coverImage,
      accentImage: const ProjectImageData(),
      isPinned: widget.isPinned,
      unpinnedIndex: widget.unpinnedIndex,
      characterDisplayMode: widget.initialCharacterDisplayMode,
      characterGridColumns: widget.initialAvatarGridColumns,
      featuredCharacterIds: widget.featuredCharacterIds,
      createdAt: widget.createdAt ?? now,
      lastModified: widget.lastModified ?? now,
      lastAccessed: widget.lastAccessed ?? now,
    );
    _projectTitleNotifier = ValueNotifier<String>(_projectDraft.title);
    _characterSearchController = TextEditingController();
    _lastPersistedProjectTitle = _projectDraft.title;
    _characterDisplayMode = _characterDisplayModeFromStorage(
      widget.initialCharacterDisplayMode,
    );
    _avatarGridColumns = widget.initialAvatarGridColumns.clamp(2, 6);
    if (_projectDraft.id != null) {
      unawaited(_loadCharacters());
    }
  }

  String get _activeSectionLabel => _sectionMeta[_activeSection]!.label;

  @override
  void dispose() {
    _characterSearchController.dispose();
    _projectTitleNotifier.dispose();
    super.dispose();
  }

  void _updateProjectDraft(ProjectRecord next) {
    final previous = _projectDraft;
    final updated = next.copyWith(
      lastModified: DateTime.now(),
      lastAccessed: DateTime.now(),
    );
    _projectDraft = updated;
    _hasPendingProjectChanges = true;

    if (_projectTitleNotifier.value != updated.title) {
      _projectTitleNotifier.value = updated.title;
    }

    if (_requiresProjectBodyRebuild(previous, updated)) {
      setState(() {});
    }
  }

  bool _requiresProjectBodyRebuild(ProjectRecord previous, ProjectRecord next) {
    return previous.id != next.id ||
        previous.tags != next.tags ||
        previous.coverColor != next.coverColor ||
        previous.accentColor != next.accentColor ||
        previous.coverImage != next.coverImage ||
        previous.accentImage != next.accentImage ||
        previous.isPinned != next.isPinned ||
        previous.unpinnedIndex != next.unpinnedIndex ||
        previous.characterDisplayMode != next.characterDisplayMode ||
        previous.characterGridColumns != next.characterGridColumns ||
        previous.featuredCharacterIds != next.featuredCharacterIds;
  }

  Future<bool> _flushProjectDraft() async {
    if (!_hasPendingProjectChanges) {
      return true;
    }

    if (_projectDraft.id == null) {
      _hasPendingProjectChanges = false;
      return true;
    }

    final previousTitle = _lastPersistedProjectTitle;
    final projectToSave = _projectDraft.copyWith(
      accentImage: const ProjectImageData(),
      characterDisplayMode: _characterDisplayMode.name,
      characterGridColumns: _avatarGridColumns,
    );
    final result = await _projectRepository.saveProject(projectToSave);

    if (!mounted) {
      return false;
    }

    if (!result.$1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.$2), behavior: SnackBarBehavior.floating),
      );
      return false;
    }

    _hasPendingProjectChanges = false;
    _projectDraft = projectToSave;
    _lastPersistedProjectTitle = _projectDraft.title;
    if (previousTitle.trim() != _projectDraft.title.trim()) {
      StoryRegistry.instance.renameProject(previousTitle, _projectDraft.title);
    } else {
      StoryRegistry.instance.registerProject(
        title: _projectDraft.title,
        accentColor: _projectDraft.accentColor,
      );
    }
    return true;
  }

  Future<void> _closeProjectPage() async {
    if (_isClosing) {
      return;
    }

    _isClosing = true;
    final didFlush = await _flushProjectDraft();
    if (!mounted) {
      return;
    }

    if (!didFlush) {
      _isClosing = false;
      return;
    }

    Navigator.of(context).pop(_projectDraft);
  }

  void _updateBannerCoverImage(ProjectImageData image) {
    _updateProjectDraft(_projectDraft.copyWith(coverImage: image));
  }

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
    final projectId = _projectDraft.id;
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

      _characters = (result.$2 ?? const <CharacterListItem>[]).toList(
        growable: true,
      );
    });
  }

  Future<void> _persistProjectViewSettings() async {
    final projectId = _projectDraft.id;
    if (projectId == null) {
      return;
    }

    final result = await _projectRepository.saveProject(
      _projectDraft.copyWith(
        characterDisplayMode: _characterDisplayMode.name,
        characterGridColumns: _avatarGridColumns,
        lastAccessed: _projectDraft.lastAccessed,
      ),
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

      await _characterRepository.saveCharacter(
        character.copyWith(
          projectTitle: _projectDraft.title,
          lastAccessed: character.lastAccessed,
        ),
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
      final result = await _characterRepository.saveCharacter(
        character.copyWith(
          projectTitle: _projectDraft.title,
          data: updatedData,
          lastAccessed: character.lastAccessed,
        ),
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
        projectTitle: _projectDraft.title,
        oldName: previousName,
        newName: updatedData.name,
        accentColor: updatedData.accent,
      );
      return;
    }

    StoryRegistry.instance.registerCharacter(
      projectTitle: _projectDraft.title,
      name: updatedData.name,
      accentColor: updatedData.accent,
    );
  }

  Future<void> _deleteCharacter(CharacterListItem character) async {
    final characterId = character.id;
    final linkedNotes = await _notesLinkedToCharacter(character);
    if (!mounted) {
      return;
    }

    final deletionAction = await showDeleteCharacterConfirmation(
      context,
      characterName: character.data.name,
      linkedNoteCount: linkedNotes.length,
    );
    if (!mounted || deletionAction == null) {
      return;
    }

    if (deletionAction ==
        CharacterLinkedNotesDeletionAction.deleteLinkedNotes) {
      await _deleteCharacterLinkedNotes(linkedNotes);
    } else {
      await _markCharacterNotesAsFormerlyLinked(character, linkedNotes);
    }
    if (!mounted) {
      return;
    }

    if (characterId == null) {
      setState(() {
        _characters.remove(character);
      });
      return;
    }

    final result = await _characterRepository.deleteCharacter(characterId);
    if (!mounted) {
      return;
    }

    if (!result.$1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.$2), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() {
      _characters.removeWhere((item) => item.id == characterId);
      if (_projectDraft.featuredCharacterIds.contains(characterId)) {
        _projectDraft = _projectDraft.copyWith(
          featuredCharacterIds: _projectDraft.featuredCharacterIds
              .where((id) => id != characterId)
              .toList(growable: false),
        );
        _hasPendingProjectChanges = true;
      }
    });

    StoryRegistry.instance.removeCharacter(
      projectTitle: _projectDraft.title,
      name: character.data.name,
    );
    unawaited(_persistCharacterOrdering());
    unawaited(_flushProjectDraft());
  }

  Future<void> _deleteCharacters(List<CharacterListItem> characters) async {
    if (characters.isEmpty) return;

    final linkedNotesByCharacter = <CharacterListItem, List<Note>>{};
    for (final character in characters) {
      linkedNotesByCharacter[character] = await _notesLinkedToCharacter(
        character,
      );
    }
    if (!mounted) return;

    final linkedNoteIds = <int>{};
    for (final notes in linkedNotesByCharacter.values) {
      linkedNoteIds.addAll(notes.map((note) => note.id).whereType<int>());
    }

    final deletionAction = await showDeleteCharactersConfirmation(
      context,
      characterCount: characters.length,
      linkedNoteCount: linkedNoteIds.length,
    );
    if (!mounted || deletionAction == null) {
      return;
    }

    if (deletionAction ==
        CharacterLinkedNotesDeletionAction.deleteLinkedNotes) {
      await _deleteCharacterLinkedNotes(
        linkedNotesByCharacter.values
            .expand((notes) => notes)
            .toList(growable: false),
      );
    } else {
      for (final entry in linkedNotesByCharacter.entries) {
        await _markCharacterNotesAsFormerlyLinked(entry.key, entry.value);
      }
    }
    if (!mounted) return;

    final deletedIds = <int>{};
    for (final character in characters) {
      final characterId = character.id;
      if (characterId == null) {
        deletedIds.addAll(
          _characters
              .where((item) => identical(item, character))
              .map((item) => item.id)
              .whereType<int>(),
        );
        continue;
      }

      final result = await _characterRepository.deleteCharacter(characterId);
      if (!mounted) return;
      if (!result.$1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.$2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        continue;
      }
      deletedIds.add(characterId);
      StoryRegistry.instance.removeCharacter(
        projectTitle: _projectDraft.title,
        name: character.data.name,
      );
    }

    setState(() {
      _characters.removeWhere(
        (item) => item.id != null && deletedIds.contains(item.id),
      );
      if (_projectDraft.featuredCharacterIds.any(deletedIds.contains)) {
        _projectDraft = _projectDraft.copyWith(
          featuredCharacterIds: _projectDraft.featuredCharacterIds
              .where((id) => !deletedIds.contains(id))
              .toList(growable: false),
        );
        _hasPendingProjectChanges = true;
      }
    });

    unawaited(_persistCharacterOrdering());
    unawaited(_flushProjectDraft());
  }

  Future<List<Note>> _notesLinkedToCharacter(
    CharacterListItem character,
  ) async {
    final result = await NoteRepository().listAllNotes();
    if (!result.$1) {
      return const <Note>[];
    }

    final projectTitle = _normalizeDeletionLabel(_projectDraft.title);
    final characterName = _normalizeDeletionLabel(character.data.name);
    return (result.$2 ?? const <Note>[])
        .where((note) {
          final link = note.metadata.linkTarget;
          return _normalizeDeletionLabel(link.projectTitle) == projectTitle &&
              _normalizeDeletionLabel(link.characterName) == characterName;
        })
        .toList(growable: false);
  }

  Future<void> _markCharacterNotesAsFormerlyLinked(
    CharacterListItem character,
    List<Note> notes,
  ) async {
    final repository = NoteRepository();
    for (final note in notes) {
      final noteId = note.id;
      if (noteId == null) continue;

      final link = note.metadata.linkTarget;
      await repository.saveNote(
        id: noteId,
        titulo: note.title,
        descricao: note.text,
        idPasta: note.idPasta,
        color: note.color,
        metadata: note.metadata.copyWith(
          linkTarget: NoteLinkTarget(
            projectTitle: link.projectTitle,
            characterName:
                'Anteriormente vinculado à ${character.data.name.trim()}',
          ),
        ),
      );
    }
  }

  Future<void> _deleteCharacterLinkedNotes(List<Note> notes) async {
    final repository = NoteRepository();
    final deletedNoteIds = <int>{};
    for (final note in notes) {
      final noteId = note.id;
      if (noteId == null || !deletedNoteIds.add(noteId)) continue;

      await repository.deleteNote(noteId);
    }
  }

  String _normalizeDeletionLabel(String? value) =>
      (value ?? '').trim().toLowerCase();

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

    final projectId = _projectDraft.id;
    if (projectId == null) {
      return;
    }

    final now = DateTime.now();
    final created = await _characterRepository.createCharacter(
      CharacterListItem(
        projectId: projectId,
        projectTitle: _projectDraft.title,
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
          notebookComplexityValues: draft.notebookComplexityValues,
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
      projectTitle: _projectDraft.title,
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

    final visibleCharacters = _visibleCharacters(_characters);
    return CharactersSection(
      characters: visibleCharacters,
      showAvatarGrid: _characterDisplayMode == CharacterDisplayMode.avatars,
      avatarGridColumns: _avatarGridColumns,
      onToggleDisplayMode: _toggleCharacterDisplayMode,
      onChangeAvatarGridColumns: _setAvatarGridColumns,
      emptyMessage: _characters.isEmpty
          ? 'Nenhum personagem criado. Clique no "+" para criar um!'
          : 'Nenhum personagem encontrado com os filtros atuais.',
      onTogglePinned: _togglePinnedCharacter,
      onCharacterEdited: (character, updatedData) =>
          unawaited(_updateCharacter(character, updatedData)),
      onCharacterViewed: (character) => unawaited(_touchCharacter(character)),
      onCharacterDeleted: (character) => unawaited(_deleteCharacter(character)),
      onCharactersDeleted: (characters) =>
          unawaited(_deleteCharacters(characters)),
    );
  }

  List<CharacterListItem> _visibleCharacters(
    Iterable<CharacterListItem> characters,
  ) {
    final query = normalizeSearchText(_characterSearchQuery);
    final filtered = characters
        .where((character) {
          final tagMatches = _characterFilter.matchesTags(
            _characterTagLabels(character),
          );
          if (!tagMatches) return false;
          if (query.isEmpty) {
            return true;
          }
          final data = character.data;
          final haystack = normalizeSearchText(
            <String>[
              data.name,
              data.alias,
              data.synopsis,
              data.motto,
              data.genderTag,
              data.sexualityTag,
              data.ethnicityTag,
              data.functionTag,
              data.relevanceTag,
            ].join(' '),
          );
          return haystack.contains(query);
        })
        .toList(growable: false);

    return filtered..sort((left, right) {
      if (left.isPinned != right.isPinned) {
        return left.isPinned ? -1 : 1;
      }

      final comparison = switch (_characterSort.mode) {
        ContentSortMode.lastAccessed => right.lastAccessed.compareTo(
          left.lastAccessed,
        ),
        ContentSortMode.lastModified => right.lastModified.compareTo(
          left.lastModified,
        ),
        ContentSortMode.createdAt => right.createdAt.compareTo(left.createdAt),
        ContentSortMode.title => left.data.name.toLowerCase().compareTo(
          right.data.name.toLowerCase(),
        ),
        ContentSortMode.synopsisLength =>
          right.data.synopsis.trim().length.compareTo(
            left.data.synopsis.trim().length,
          ),
        ContentSortMode.characterCount => 0,
      };
      return _characterSort.reversed ? -comparison : comparison;
    });
  }

  List<String> _characterTagLabels(CharacterListItem character) {
    final data = character.data;
    return [
      data.genderTag,
      data.sexualityTag,
      data.ethnicityTag,
      data.functionTag,
      data.relevanceTag,
    ].where((tag) => tag.trim().isNotEmpty).toList(growable: false);
  }

  List<TagFilterGroup> _buildCharacterTagGroups() {
    final groups = <TagFilterGroup>[
      _buildCharacterTagGroup(
        title: 'Gênero',
        icon: Icons.wc_rounded,
        color: projectTagColorAt(0),
        labels: _characters
            .map((character) => character.data.genderTag)
            .where((tag) => tag.trim().isNotEmpty),
      ),
      _buildCharacterTagGroup(
        title: 'Sexualidade',
        icon: Icons.favorite_border_rounded,
        color: projectTagColorAt(1),
        labels: _characters
            .map((character) => character.data.sexualityTag)
            .where((tag) => tag.trim().isNotEmpty),
      ),
      _buildCharacterTagGroup(
        title: 'Etnia',
        icon: Icons.groups_2_outlined,
        color: projectTagColorAt(2),
        labels: _characters
            .map((character) => character.data.ethnicityTag)
            .where((tag) => tag.trim().isNotEmpty),
      ),
      _buildCharacterTagGroup(
        title: 'Função',
        icon: Icons.badge_outlined,
        color: projectTagColorAt(3),
        labels: _characters
            .map((character) => character.data.functionTag)
            .where((tag) => tag.trim().isNotEmpty),
      ),
      _buildCharacterTagGroup(
        title: 'Relevância',
        icon: Icons.star_rounded,
        color: projectTagColorAt(4),
        labels: _characters
            .map((character) => character.data.relevanceTag)
            .where((tag) => tag.trim().isNotEmpty),
      ),
    ];

    return groups
        .where((group) => group.tags.isNotEmpty)
        .toList(growable: false);
  }

  TagFilterGroup _buildCharacterTagGroup({
    required String title,
    required IconData icon,
    required Color color,
    required Iterable<String> labels,
  }) {
    final tagsByNormalized = <String, ProjectTagData>{};
    for (final label in labels) {
      final sanitized = sanitizeProjectTagLabel(label);
      final normalized = normalizeSearchText(sanitized);
      if (normalized.isEmpty) continue;
      tagsByNormalized.putIfAbsent(
        normalized,
        () => ProjectTagData(label: sanitized, color: color, groupTitle: title),
      );
    }

    return TagFilterGroup(
      title: title,
      color: color,
      icon: icon,
      tags: tagsByNormalized.values.toList(growable: false),
    );
  }

  void _onCharacterSearchChanged(String value) {
    setState(() {
      _characterSearchQuery = value;
    });
  }

  Future<void> _openCharacterFilterMenu() async {
    final result = await showContentFilterMenu(
      context: context,
      initial: _characterFilter,
      availableTagGroups: _buildCharacterTagGroups(),
    );
    if (!mounted || result == null) return;
    setState(() => _characterFilter = result);
  }

  Future<void> _openCharacterSortMenu() async {
    final result = await showContentSortMenu(
      context: context,
      initial: _characterSort,
      includeCharacterCount: false,
    );
    if (!mounted || result == null) return;
    setState(() => _characterSort = result);
  }

  Widget _buildSectionBody() {
    return switch (_activeSection) {
      ProjectSectionId.configProjeto => ProjectGeneralSection(
        project: _projectDraft,
        availableTags: widget.availableTags,
        availableCharacters: _characters,
        isLoadingCharacters: _isLoadingCharacters,
        onChanged: _updateProjectDraft,
      ),
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

  Future<void> _openCoverImageViewer() async {
    final coverImage = _projectDraft.coverImage;
    if (coverImage.bytes == null) {
      return;
    }

    await showProjectImageViewerDialog(
      context,
      title: _projectDraft.title,
      subtitle: 'Imagem do projeto',
      image: coverImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedCoverColor = _projectDraft.coverColor;
    final accentColor = _projectDraft.accentColor;
    final coverImage = _projectDraft.coverImage;
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
                  accentColor.withValues(alpha: 0.08),
                  resolvedCoverColor.withValues(alpha: 0.92),
                ),
                Color.alphaBlend(
                  resolvedCoverColor.withValues(alpha: 0.88),
                  Colors.black.withValues(alpha: 0.06),
                ),
                Color.alphaBlend(
                  accentColor.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.1),
                ),
              ],
              stops: const [0.0, 0.56, 1.0],
            ),
          ),
        ),
        if (coverImage.bytes != null)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final metrics = computeProjectImageViewportMetrics(
                  viewportSize: constraints.biggest,
                  imageWidth: coverImage.width ?? 0,
                  imageHeight: coverImage.height ?? 0,
                  scale: coverImage.scale,
                );

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) {
                    final offset = resolveProjectImageDragOffset(
                      currentOffsetX: coverImage.offsetX,
                      currentOffsetY: coverImage.offsetY,
                      dragDelta: details.delta,
                      metrics: metrics,
                    );
                    _updateBannerCoverImage(
                      coverImage.copyWith(
                        offsetX: offset.dx,
                        offsetY: offset.dy,
                      ),
                    );
                  },
                  child: Opacity(
                    opacity: 0.78,
                    child: ProjectImageTransformView(
                      imageBytes: coverImage.bytes!,
                      imageWidth: coverImage.width ?? 1,
                      imageHeight: coverImage.height ?? 1,
                      scale: coverImage.scale,
                      offsetX: coverImage.offsetX,
                      offsetY: coverImage.offsetY,
                    ),
                  ),
                );
              },
            ),
          ),
        Positioned.fill(
          child: IgnorePointer(
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
        ),
        Positioned.fill(
          child: IgnorePointer(
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
        ),
        if (coverImage.bytes != null)
          Positioned(
            left: 16,
            bottom: 12,
            child: GlassCircleButton(
              diameter: 34,
              onTap: _openCoverImageViewer,
              tooltip: 'Ver imagem',
              fillColor: Colors.white.withValues(alpha: 0.14),
              borderColor: Colors.white.withValues(alpha: 0.72),
              borderWidth: 0.8,
              blurSigma: 12,
              child: Icon(
                Icons.open_in_full_rounded,
                size: 17,
                color: Colors.white.withValues(alpha: 0.96),
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          unawaited(_closeProjectPage());
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDF2F8),
        bottomNavigationBar: _ProjectFooterNav(
          accentColor: accentColor,
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
                ValueListenableBuilder<String>(
                  valueListenable: _projectTitleNotifier,
                  builder: (context, projectTitle, _) {
                    final liveHeaderCenter = Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            projectTitle.toUpperCase(),
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
                            color: const Color(
                              0xFFF7EEF4,
                            ).withValues(alpha: 0.92),
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

                    return MainHeader(
                      asSliver: false,
                      title: projectTitle,
                      subtitle: _activeSectionLabel,
                      onBackPressed: () => unawaited(_closeProjectPage()),
                      onConfigPressed: () {},
                      titleFontSize: 31,
                      titleLetterSpacing: 2.8,
                      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      titleHorizontalPadding: 60,
                      titleShadow: true,
                      surroundSubtitleWithDots: true,
                      centerChild: liveHeaderCenter,
                      backgroundChild: headerBackground,
                    );
                  },
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _activeSection == ProjectSectionId.characters
                      ? FuncoesBusca(
                          key: const ValueKey('project-character-search'),
                          controller: _characterSearchController,
                          onChanged: _onCharacterSearchChanged,
                          onFilterTap: () =>
                              unawaited(_openCharacterFilterMenu()),
                          onSortTap: () => unawaited(_openCharacterSortMenu()),
                          filterActive: _characterFilter.isActive,
                          sortActive: _characterSort.isActive,
                          hintText: 'Pesquisar personagens',
                        )
                      : Container(
                          key: ValueKey('project-search-collapsed'),
                          height: 1,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xD6FFFFFF),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                ),
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
                accentColor: accentColor,
                isOpen: _isCreateMenuOpen,
                onToggle: _toggleCreateMenu,
                onCreateCharacter: _createCharacter,
                onCreateDiagram: _createDiagram,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
