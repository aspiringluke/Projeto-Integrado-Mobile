import 'package:flutter/material.dart';

import '../models/project_image_data.dart';
import '../models/project_style_defaults.dart';
import '../models/project_tag_data.dart';

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
  final List<ProjectListItem> _projects = <ProjectListItem>[];
  final List<ProjectTagData> _availableTags = <ProjectTagData>[];

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
    project.title = title;
    project.synopsis = synopsis;
    project.lastModified = DateTime.now();
    notifyListeners();
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
    final resolvedTags = <ProjectTagData>[];
    final seenLabels = <String>{};

    for (final tag in tags) {
      final sanitizedLabel = sanitizeProjectTagLabel(tag.label);
      final normalizedLabel = normalizeProjectTagLabel(tag.label);

      if (normalizedLabel.isEmpty || !seenLabels.add(normalizedLabel)) {
        continue;
      }

      final existingIndex = _availableTags.indexWhere(
        (tag) => tag.normalizedLabel == normalizedLabel,
      );

      if (existingIndex != -1) {
        resolvedTags.add(_availableTags[existingIndex]);
        continue;
      }

      final newTag = ProjectTagData(label: sanitizedLabel, color: tag.color);
      _availableTags.add(newTag);
      resolvedTags.add(newTag);
    }

    return List<ProjectTagData>.unmodifiable(resolvedTags);
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
