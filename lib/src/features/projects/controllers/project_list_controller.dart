import 'dart:async';

import 'package:flutter/material.dart';

import '../../characters/data/repositories/character_repository.dart';
import '../../characters/models/characters_models.dart';
import '../../notas/data/repositories/folder_repository.dart';
import '../../shared/story_registry.dart';
import '../../tags/controllers/tag_controller.dart';
import '../../tags/data/repositories/tag_group_repository.dart';
import '../../tags/data/repositories/tag_repository.dart';
import '../data/repositories/project_repository.dart';
import '../models/project_image_data.dart';
import '../models/project_record.dart';
import '../models/project_style_defaults.dart';
import '../models/project_tag_data.dart';
import '../utils/project_character_showcase.dart';

class ProjectListItem {
  final int? id;
  String title;
  String synopsis;
  final List<ProjectTagData> tags;
  final Color coverColor;
  final Color accentColor;
  final ProjectImageData coverImage;
  final ProjectImageData accentImage;
  final DateTime createdAt;
  DateTime lastModified;
  DateTime lastAccessed;
  bool isPinned;
  int unpinnedIndex;
  String characterDisplayMode;
  int characterGridColumns;
  List<int> featuredCharacterIds;
  List<CharacterListItem> displayedCharacters;

  ProjectListItem({
    this.id,
    required this.title,
    required this.synopsis,
    required this.tags,
    required this.coverColor,
    required this.accentColor,
    this.coverImage = const ProjectImageData(),
    this.accentImage = const ProjectImageData(),
    required this.createdAt,
    required this.lastModified,
    required this.lastAccessed,
    this.isPinned = false,
    required this.unpinnedIndex,
    this.characterDisplayMode = 'list',
    this.characterGridColumns = 3,
    this.featuredCharacterIds = const <int>[],
    this.displayedCharacters = const <CharacterListItem>[],
  });
}

class ProjectListController extends ChangeNotifier {
  static const String _projectTagGroupTitle = 'Projetos';

  final ProjectRepository _projectRepository;
  final CharacterRepository _characterRepository;
  final TagRepository _tagRepository;
  final TagGroupRepository _tagGroupRepository;
  int? _projectTagGroupId;
  final List<ProjectListItem> _projects = <ProjectListItem>[];
  final List<ProjectTagData> _availableTags = <ProjectTagData>[];
  final List<CharacterListItem> _allCharacters = <CharacterListItem>[];
  bool _isLoading = false;
  String? _errorMessage;
  int _loadRequestToken = 0;

  ProjectListController({
    ProjectRepository? projectRepository,
    CharacterRepository? characterRepository,
    TagRepository? tagRepository,
    TagGroupRepository? tagGroupRepository,
  }) : _projectRepository = projectRepository ?? ProjectRepository(),
       _characterRepository = characterRepository ?? CharacterRepository(),
       _tagRepository = tagRepository ?? TagRepository(),
       _tagGroupRepository = tagGroupRepository ?? TagGroupRepository() {
    unawaited(_hydrateInitialState());
  }

  bool get isEmpty => _projects.isEmpty;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProjectListItem> get projects => List.unmodifiable(_projects);
  List<ProjectTagData> get availableTags => List.unmodifiable(_availableTags);

  Future<void> addProject({
    required String title,
    String synopsis = '',
    Iterable<ProjectTagData> tags = const <ProjectTagData>[],
    Color coverColor = defaultProjectCoverColor,
    Color accentColor = defaultProjectAccentColor,
    ProjectImageData coverImage = const ProjectImageData(),
    ProjectImageData accentImage = const ProjectImageData(),
    List<int> featuredCharacterIds = const <int>[],
  }) async {
    final sanitizedTitle = title.trim();
    if (sanitizedTitle.isEmpty) {
      _setError('O projeto precisa ter um título');
      return;
    }

    _setError(null);
    final unpinnedCount = _projects.where((item) => !item.isPinned).length;
    final resolvedTags = _resolveTags(tags);
    final created = await _projectRepository.createProject(
      title: sanitizedTitle,
      synopsis: synopsis.trim(),
      tags: resolvedTags,
      coverColor: coverColor,
      accentColor: accentColor,
      coverImage: coverImage,
      accentImage: accentImage,
      featuredCharacterIds: featuredCharacterIds,
      unpinnedIndex: unpinnedCount,
    );

    if (!created.$1 || created.$2 == null) {
      _setError(created.$3 ?? 'Falha ao criar projeto');
      return;
    }

    _invalidatePendingLoads(resetLoading: true);
    final project = _mapRecordToItem(created.$2!);
    _projects.add(project);
    StoryRegistry.instance.registerProject(
      title: project.title,
      accentColor: project.accentColor,
    );
    await _ensureAutoFolderForProject(project.title, project.accentColor);
    notifyListeners();
  }

  Future<void> loadProjects() async {
    final requestToken = ++_loadRequestToken;
    _setLoading(true);
    _setError(null);
    notifyListeners();

    final result = await _projectRepository.listProjects();
    if (requestToken != _loadRequestToken) {
      return;
    }

    if (!result.$1) {
      _projects.clear();
      _setLoading(false);
      _setError(result.$3 ?? 'Falha ao carregar projetos');
      notifyListeners();
      return;
    }

    _projects
      ..clear()
      ..addAll(
        (result.$2 ?? const <ProjectRecord>[])
            .where((record) => record.title.trim().isNotEmpty)
            .map(_mapRecordToItem),
      );
    await _syncCharactersFromStorage();
    if (requestToken != _loadRequestToken) {
      return;
    }
    _setLoading(false);
    notifyListeners();
  }

  Future<void> markProjectOpened(ProjectListItem project) async {
    project.lastAccessed = DateTime.now();
    notifyListeners();

    if (project.id != null) {
      await _projectRepository.touchProject(project.id!);
    }
  }

  Future<void> refreshAfterProjectPage() async {
    await loadProjects();
  }

  void applyProjectPageUpdate(ProjectListItem project, ProjectRecord updated) {
    final index = _projects.indexOf(project);
    if (index == -1) {
      return;
    }

    final oldTitle = project.title;
    final resolvedTags = TagController.resolveProjectTagPool(
      existingTags: _availableTags,
      incomingTags: updated.tags,
    );
    _availableTags
      ..clear()
      ..addAll(resolvedTags.resolvedKnownTags);

    _projects[index] = ProjectListItem(
      id: updated.id ?? project.id,
      title: updated.title,
      synopsis: updated.synopsis,
      tags: resolvedTags.resolvedIncomingTags,
      coverColor: updated.coverColor,
      accentColor: updated.accentColor,
      coverImage: updated.coverImage,
      accentImage: const ProjectImageData(),
      createdAt: updated.createdAt,
      lastModified: updated.lastModified,
      lastAccessed: updated.lastAccessed,
      isPinned: project.isPinned,
      unpinnedIndex: project.unpinnedIndex,
      characterDisplayMode: updated.characterDisplayMode,
      characterGridColumns: updated.characterGridColumns,
      featuredCharacterIds: List<int>.unmodifiable(
        updated.featuredCharacterIds,
      ),
      displayedCharacters: _displayedCharactersForProject(
        updated.id ?? project.id,
        updated.featuredCharacterIds,
      ),
    );

    if (oldTitle.trim() != updated.title.trim()) {
      StoryRegistry.instance.renameProject(oldTitle, updated.title);
      unawaited(_syncAutoFolderRename(oldTitle, updated.title));
    } else {
      StoryRegistry.instance.registerProject(
        title: updated.title,
        accentColor: updated.accentColor,
      );
    }

    _invalidatePendingLoads(resetLoading: true);
    notifyListeners();
    unawaited(_refreshDisplayedCharactersForProject(_projects[index]));
  }

  void reorderProjects(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _projects.length) return;

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    if (newIndex < 0 || newIndex > _projects.length) return;

    final item = _projects.removeAt(oldIndex);
    _projects.insert(newIndex, item);
    _normalizePinnedGroups();
    _updateUnpinnedSlots();
    notifyListeners();
    unawaited(_persistProjectOrdering());
  }

  void togglePinned(ProjectListItem project) {
    final currentIndex = _projects.indexOf(project);
    if (currentIndex == -1) return;

    if (!project.isPinned) {
      project.unpinnedIndex = _unpinnedIndexAt(currentIndex);
    }

    _projects.removeAt(currentIndex);
    project.isPinned = !project.isPinned;
    project.lastModified = DateTime.now();

    if (project.isPinned) {
      _projects.insert(0, project);
    } else {
      final pinnedCount = _projects.where((item) => item.isPinned).length;
      final unpinnedCount = _projects.length - pinnedCount;
      final targetUnpinnedIndex = project.unpinnedIndex.clamp(0, unpinnedCount);
      _projects.insert(pinnedCount + targetUnpinnedIndex, project);
      _updateUnpinnedSlots();
    }

    notifyListeners();
    unawaited(_persistProjectOrdering());
  }

  Future<void> updateProjectContent(
    ProjectListItem project, {
    required String title,
    required String synopsis,
  }) async {
    if (project.id == null) {
      _setError('Projeto sem identificador');
      return;
    }

    final oldTitle = project.title;
    final sanitizedTitle = title.trim();
    if (sanitizedTitle.isEmpty) {
      _setError('O projeto precisa ter um título');
      return;
    }

    final updateResult = await _projectRepository.updateProject(
      project.id!,
      title: sanitizedTitle,
      synopsis: synopsis,
      lastAccessed: project.lastAccessed,
    );

    if (!updateResult.$1) {
      _setError(updateResult.$2);
      return;
    }

    _invalidatePendingLoads(resetLoading: true);
    project.title = sanitizedTitle;
    project.synopsis = synopsis;
    project.lastModified = DateTime.now();
    if (oldTitle.trim() != sanitizedTitle) {
      StoryRegistry.instance.renameProject(oldTitle, sanitizedTitle);
      await _syncAutoFolderRename(oldTitle, sanitizedTitle);
    } else {
      StoryRegistry.instance.registerProject(
        title: sanitizedTitle,
        accentColor: project.accentColor,
      );
    }
    notifyListeners();
  }

  Future<void> updateProjectCharacterViewSettings(
    ProjectListItem project, {
    required String characterDisplayMode,
    required int characterGridColumns,
  }) async {
    if (project.id == null) {
      return;
    }

    _invalidatePendingLoads(resetLoading: true);
    project.characterDisplayMode = characterDisplayMode;
    project.characterGridColumns = characterGridColumns;
    notifyListeners();

    final result = await _projectRepository.updateProject(
      project.id!,
      characterDisplayMode: characterDisplayMode,
      characterGridColumns: characterGridColumns,
      lastAccessed: project.lastAccessed,
    );

    if (!result.$1) {
      _setError(result.$2);
    }
  }

  Future<void> _hydrateInitialState() async {
    await _hydrateTagsFromStorage();
    await loadProjects();
  }

  Future<void> _hydrateTagsFromStorage() async {
    final groupId = await _ensureProjectTagGroupId();
    final result = await _tagRepository.listTags(groupId: groupId);
    if (!result.$1 || result.$2 == null || result.$2!.isEmpty) return;

    final persisted = result.$2!
        .map((tag) => ProjectTagData(label: tag.label, color: tag.color))
        .toList(growable: false);

    final resolution = TagController.resolveProjectTagPool(
      existingTags: _availableTags,
      incomingTags: persisted,
    );
    _availableTags
      ..clear()
      ..addAll(resolution.resolvedKnownTags);
    notifyListeners();
  }

  Future<int?> _ensureProjectTagGroupId() async {
    if (_projectTagGroupId != null) return _projectTagGroupId;

    final ensured = await _tagGroupRepository.ensureGroup(
      title: _projectTagGroupTitle,
      color: defaultProjectAccentColor,
    );
    if (ensured.$1 && ensured.$2?.id != null) {
      _projectTagGroupId = ensured.$2!.id;
    }

    return _projectTagGroupId;
  }

  Future<void> _persistResolvedTags(Iterable<ProjectTagData> tags) async {
    final groupId = await _ensureProjectTagGroupId();
    for (final tag in tags) {
      await _tagRepository.upsertTag(
        label: tag.label,
        color: tag.color,
        groupId: groupId,
      );
    }
  }

  Future<void> _persistProjectOrdering() async {
    _normalizePinnedGroups();
    _updateUnpinnedSlots();

    for (final project in _projects) {
      if (project.id == null) continue;
      await _projectRepository.updateProject(
        project.id!,
        isPinned: project.isPinned,
        unpinnedIndex: project.unpinnedIndex,
        lastAccessed: project.lastAccessed,
      );
    }
  }

  Future<void> _syncAutoFolderRename(String oldTitle, String newTitle) async {
    final normalizedOldTitle = oldTitle.trim();
    final normalizedNewTitle = newTitle.trim();
    if (normalizedOldTitle.isEmpty ||
        normalizedNewTitle.isEmpty ||
        normalizedOldTitle == normalizedNewTitle) {
      return;
    }

    final folderRepository = FolderRepository();
    final folder = await folderRepository.findRootFolderByTitle(
      normalizedOldTitle,
    );
    if (folder == null || folder.id == null) {
      return;
    }

    await folderRepository.updateFolder(folder.id!, normalizedNewTitle, null);
    await folderRepository.updateFolderMetadata(
      folder.id!,
      folder.metadata
          .copyWith(projectRootTitle: normalizedNewTitle)
          .toJsonString(),
    );
  }

  Future<void> _ensureAutoFolderForProject(
    String title,
    Color accentColor,
  ) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) return;

    final folderRepository = FolderRepository();
    await folderRepository.ensureRootFolder(
      title: normalizedTitle,
      color: accentColor,
    );
  }

  Future<void> _syncCharactersFromStorage() async {
    final characterResult = await _characterRepository.listAllCharacters();
    final characters = characterResult.$1
        ? characterResult.$2 ?? const <CharacterListItem>[]
        : const <CharacterListItem>[];

    _allCharacters
      ..clear()
      ..addAll(characters);
    _applyDisplayedCharacters(characters);

    StoryRegistry.instance.syncProjectsAndCharacters(
      projects: _projects
          .map(
            (project) => RegisteredProjectRef(
              title: project.title,
              accentColor: project.accentColor,
            ),
          )
          .toList(growable: false),
      characters: characters
          .where(
            (character) =>
                (character.projectTitle?.trim().isNotEmpty ?? false) &&
                character.data.name.trim().isNotEmpty,
          )
          .map(
            (character) => RegisteredCharacterRef(
              projectTitle: character.projectTitle!,
              name: character.data.name,
              accentColor: character.data.accent,
            ),
          )
          .toList(growable: false),
    );
  }

  List<ProjectTagData> _resolveTags(Iterable<ProjectTagData> tags) {
    final resolution = TagController.resolveProjectTagPool(
      existingTags: _availableTags,
      incomingTags: tags,
    );

    _availableTags
      ..clear()
      ..addAll(resolution.resolvedKnownTags);
    unawaited(_persistResolvedTags(resolution.resolvedIncomingTags));
    return resolution.resolvedIncomingTags;
  }

  ProjectListItem _mapRecordToItem(ProjectRecord record) {
    return ProjectListItem(
      id: record.id,
      title: record.title,
      synopsis: record.synopsis,
      tags: List<ProjectTagData>.unmodifiable(record.tags),
      coverColor: record.coverColor,
      accentColor: record.accentColor,
      coverImage: record.coverImage,
      accentImage: const ProjectImageData(),
      createdAt: record.createdAt,
      lastModified: record.lastModified,
      lastAccessed: record.lastAccessed,
      isPinned: record.isPinned,
      unpinnedIndex: record.unpinnedIndex,
      characterDisplayMode: record.characterDisplayMode,
      characterGridColumns: record.characterGridColumns,
      featuredCharacterIds: List<int>.unmodifiable(record.featuredCharacterIds),
      displayedCharacters: _displayedCharactersForProject(
        record.id,
        record.featuredCharacterIds,
      ),
    );
  }

  void _applyDisplayedCharacters(List<CharacterListItem> characters) {
    for (final project in _projects) {
      project.displayedCharacters = resolveProjectShowcaseCharacters(
        selectedCharacterIds: project.featuredCharacterIds,
        characters: characters
            .where((character) => character.projectId == project.id)
            .toList(growable: false),
      );
    }
  }

  List<CharacterListItem> _displayedCharactersForProject(
    int? projectId,
    List<int> featuredCharacterIds,
  ) {
    if (projectId == null) {
      return const <CharacterListItem>[];
    }

    return resolveProjectShowcaseCharacters(
      selectedCharacterIds: featuredCharacterIds,
      characters: _allCharacters
          .where((character) => character.projectId == projectId)
          .toList(growable: false),
    );
  }

  Future<void> _refreshDisplayedCharactersForProject(
    ProjectListItem project,
  ) async {
    final projectId = project.id;
    if (projectId == null) {
      return;
    }

    final result = await _characterRepository.listCharactersForProject(
      projectId,
    );
    if (!result.$1) {
      return;
    }

    final characters = result.$2 ?? const <CharacterListItem>[];
    _allCharacters.removeWhere((character) => character.projectId == projectId);
    _allCharacters.addAll(characters);
    project.displayedCharacters = resolveProjectShowcaseCharacters(
      selectedCharacterIds: project.featuredCharacterIds,
      characters: characters,
    );
    notifyListeners();
  }

  void _invalidatePendingLoads({bool resetLoading = false}) {
    _loadRequestToken += 1;
    if (resetLoading) {
      _setLoading(false);
    }
  }

  int _unpinnedIndexAt(int listIndex) {
    var count = 0;

    for (var index = 0; index < listIndex; index += 1) {
      if (!_projects[index].isPinned) {
        count += 1;
      }
    }

    return count;
  }

  void _normalizePinnedGroups() {
    final pinned = _projects
        .where((item) => item.isPinned)
        .toList(growable: false);
    final unpinned = _projects
        .where((item) => !item.isPinned)
        .toList(growable: false);

    _projects
      ..clear()
      ..addAll(pinned)
      ..addAll(unpinned);
  }

  void _setError(String? value) {
    _errorMessage = value;
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _updateUnpinnedSlots() {
    var unpinnedIndex = 0;

    for (final project in _projects) {
      if (!project.isPinned) {
        project.unpinnedIndex = unpinnedIndex;
        unpinnedIndex += 1;
      }
    }
  }
}
