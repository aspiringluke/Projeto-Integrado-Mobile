import 'dart:async';

import 'package:flutter/material.dart';

import '../../notas/data/repositories/folder_repository.dart';
import '../../tags/data/repositories/tag_group_repository.dart';
import '../../tags/data/repositories/tag_repository.dart';
import '../../tags/controllers/tag_controller.dart';
import '../models/project_image_data.dart';
import '../models/project_style_defaults.dart';
import '../models/project_tag_data.dart';
import '../../shared/story_registry.dart';

class ProjectListItem {
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
  bool isPinned = false;
  int unpinnedIndex;

  ProjectListItem({
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
    required this.unpinnedIndex,
  });
}

class ProjectListController extends ChangeNotifier {
  static const String _projectTagGroupTitle = 'Projetos';

  final TagRepository _tagRepository;
  final TagGroupRepository _tagGroupRepository;
  int? _projectTagGroupId;
  final List<ProjectListItem> _projects = <ProjectListItem>[];
  final List<ProjectTagData> _availableTags = <ProjectTagData>[];

  ProjectListController({
    TagRepository? tagRepository,
    TagGroupRepository? tagGroupRepository,
  }) : _tagRepository = tagRepository ?? TagRepository(),
       _tagGroupRepository = tagGroupRepository ?? TagGroupRepository() {
    unawaited(_hydrateTagsFromStorage());
  }

  bool get isEmpty => _projects.isEmpty;
  List<ProjectListItem> get projects => List.unmodifiable(_projects);
  List<ProjectTagData> get availableTags => List.unmodifiable(_availableTags);

  void addProject({
    required String title,
    String synopsis = '',
    Iterable<ProjectTagData> tags = const <ProjectTagData>[],
    Color coverColor = defaultProjectCoverColor,
    Color accentColor = defaultProjectAccentColor,
    ProjectImageData coverImage = const ProjectImageData(),
    ProjectImageData accentImage = const ProjectImageData(),
  }) {
    final sanitizedTitle = title.trim();
    if (sanitizedTitle.isEmpty) return;

    final unpinnedCount = _projects.where((item) => !item.isPinned).length;
    final resolvedTags = _resolveTags(tags);
    final now = DateTime.now();

    _projects.add(
      ProjectListItem(
        title: sanitizedTitle,
        synopsis: synopsis.trim(),
        tags: resolvedTags,
        coverColor: coverColor,
        accentColor: accentColor,
        coverImage: coverImage,
        accentImage: accentImage,
        createdAt: now,
        lastModified: now,
        lastAccessed: now,
        unpinnedIndex: unpinnedCount,
      ),
    );

    StoryRegistry.instance.registerProject(
      title: sanitizedTitle,
      accentColor: accentColor,
    );
    unawaited(_ensureAutoFolderForProject(sanitizedTitle, accentColor));

    notifyListeners();
  }

  void togglePinned(ProjectListItem project) {
    final currentIndex = _projects.indexOf(project);
    if (currentIndex == -1) return;

    if (!project.isPinned) {
      project.unpinnedIndex = _unpinnedIndexAt(currentIndex);
    }

    _projects.removeAt(currentIndex);
    project.isPinned = !project.isPinned;

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
  }

  void markProjectOpened(ProjectListItem project) {
    project.lastAccessed = DateTime.now();
    notifyListeners();
  }

  void updateProjectContent(
    ProjectListItem project, {
    required String title,
    required String synopsis,
  }) {
    final oldTitle = project.title;
    final sanitizedTitle = title.trim();
    if (sanitizedTitle.isEmpty) return;

    project.title = sanitizedTitle;
    project.synopsis = synopsis;
    project.lastModified = DateTime.now();
    if (oldTitle.trim() != sanitizedTitle) {
      StoryRegistry.instance.renameProject(oldTitle, sanitizedTitle);
      unawaited(_syncAutoFolderRename(oldTitle, sanitizedTitle));
    } else {
      StoryRegistry.instance.registerProject(
        title: sanitizedTitle,
        accentColor: project.accentColor,
      );
    }
    notifyListeners();
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
