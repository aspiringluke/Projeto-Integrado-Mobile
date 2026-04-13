import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/project_tag_data.dart';
import '../models/project_style_defaults.dart';
import '../widgets/project_card.dart';

class ProjectListController extends ChangeNotifier {
  final List<_ProjectListItem> _projects = <_ProjectListItem>[];
  final List<ProjectTagData> _availableTags = <ProjectTagData>[];

  bool get isEmpty => _projects.isEmpty;
  List<ProjectTagData> get availableTags => List.unmodifiable(_availableTags);

  void addProject({
    required String title,
    String synopsis = '',
    Iterable<ProjectTagData> tags = const <ProjectTagData>[],
    Color coverColor = defaultProjectCoverColor,
    Color accentColor = defaultProjectAccentColor,
    Uint8List? coverImageBytes,
    double? coverImageWidth,
    double? coverImageHeight,
    double coverImageScale = 1,
    double coverImageOffsetX = 0,
    double coverImageOffsetY = 0,
    Uint8List? accentImageBytes,
    double? accentImageWidth,
    double? accentImageHeight,
    double accentImageScale = 1,
    double accentImageOffsetX = 0,
    double accentImageOffsetY = 0,
  }) {
    final sanitizedTitle = title.trim();
    if (sanitizedTitle.isEmpty) return;

    final unpinnedCount = _projects.where((item) => !item.isPinned).length;
    final resolvedTags = _resolveTags(tags);

    final now = DateTime.now();

    _projects.add(
      _ProjectListItem(
        title: sanitizedTitle,
        synopsis: synopsis.trim(),
        tags: resolvedTags,
        coverColor: coverColor,
        accentColor: accentColor,
        coverImageBytes: coverImageBytes,
        coverImageWidth: coverImageWidth,
        coverImageHeight: coverImageHeight,
        coverImageScale: coverImageScale,
        coverImageOffsetX: coverImageOffsetX,
        coverImageOffsetY: coverImageOffsetY,
        accentImageBytes: accentImageBytes,
        accentImageWidth: accentImageWidth,
        accentImageHeight: accentImageHeight,
        accentImageScale: accentImageScale,
        accentImageOffsetX: accentImageOffsetX,
        accentImageOffsetY: accentImageOffsetY,
        createdAt: now,
        lastModified: now,
        lastAccessed: now,
        unpinnedIndex: unpinnedCount,
      ),
    );

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

      final newTag = ProjectTagData(
        label: sanitizedLabel,
        color: tag.color,
      );

      _availableTags.add(newTag);
      resolvedTags.add(newTag);
    }

    return List<ProjectTagData>.unmodifiable(resolvedTags);
  }

  void _togglePinned(_ProjectListItem project) {
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

class ProjectListPage extends StatelessWidget {
  final ProjectListController controller;
  static const double _floatingActionButtonClearance = 112;

  const ProjectListPage({super.key, required this.controller});

  bool get _isMobileReorderEnabled {
    if (kIsWeb) return false;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isMobileReorderEnabled = _isMobileReorderEnabled;
    final bottomListPadding =
        MediaQuery.paddingOf(context).bottom + _floatingActionButtonClearance;
    final listPadding = EdgeInsets.fromLTRB(0, 8, 0, bottomListPadding);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Nenhum projeto criado. Clique no botão de "+" para criar um novo!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF544959),
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          );
        }

        Widget buildProjectCard(BuildContext context, int index) {
          final project = controller._projects[index];
          final card = RepaintBoundary(
            child: ProjectCard(
              title: project.title,
              synopsis: project.synopsis,
              tags: project.tags,
              coverColor: project.coverColor,
              accentColor: project.accentColor,
              coverImageBytes: project.coverImageBytes,
              coverImageWidth: project.coverImageWidth,
              coverImageHeight: project.coverImageHeight,
              coverImageScale: project.coverImageScale,
              coverImageOffsetX: project.coverImageOffsetX,
              coverImageOffsetY: project.coverImageOffsetY,
              accentImageBytes: project.accentImageBytes,
              accentImageWidth: project.accentImageWidth,
              accentImageHeight: project.accentImageHeight,
              accentImageScale: project.accentImageScale,
              accentImageOffsetX: project.accentImageOffsetX,
              accentImageOffsetY: project.accentImageOffsetY,
              isPinned: project.isPinned,
              onTogglePinned: () => controller._togglePinned(project),
              createdAt: project.createdAt,
              lastModified: project.lastModified,
              lastAccessed: project.lastAccessed,
              onOpenProject: () {
                project.lastAccessed = DateTime.now();
                controller.notifyListeners();
              },
              onProjectEdited: (title, synopsis) {
                project.title = title;
                project.synopsis = synopsis;
                project.lastModified = DateTime.now();
                controller.notifyListeners();
              },
            ),
          );

          if (isMobileReorderEnabled) {
            return ReorderableDelayedDragStartListener(
              key: ValueKey(project.title),
              index: index,
              child: card,
            );
          }

          return KeyedSubtree(key: ValueKey(project.title), child: card);
        }

        if (!isMobileReorderEnabled) {
          return ListView.builder(
            padding: listPadding,
            itemCount: controller._projects.length,
            itemBuilder: buildProjectCard,
          );
        }

        return ReorderableListView.builder(
          buildDefaultDragHandles: false,
          padding: listPadding,
          itemCount: controller._projects.length,
          onReorder: controller.reorderProjects,
          proxyDecorator: (widget, index, animation) {
            return Material(
              elevation: 12,
              color: Colors.transparent,
              shadowColor: Colors.pink.withValues(alpha: 0.25),
              child: Opacity(
                opacity: 0.95,
                child: Transform.scale(scale: 1.02, child: widget),
              ),
            );
          },
          itemBuilder: buildProjectCard,
        );
      },
    );
  }
}

class _ProjectListItem {
  String title;
  String synopsis;
  final List<ProjectTagData> tags;
  final Color coverColor;
  final Color accentColor;
  final Uint8List? coverImageBytes;
  final double? coverImageWidth;
  final double? coverImageHeight;
  final double coverImageScale;
  final double coverImageOffsetX;
  final double coverImageOffsetY;
  final Uint8List? accentImageBytes;
  final double? accentImageWidth;
  final double? accentImageHeight;
  final double accentImageScale;
  final double accentImageOffsetX;
  final double accentImageOffsetY;
  final DateTime createdAt;
  DateTime lastModified;
  DateTime lastAccessed;
  bool isPinned = false;
  int unpinnedIndex;

  _ProjectListItem({
    required this.title,
    required this.synopsis,
    required this.tags,
    required this.coverColor,
    required this.accentColor,
    required this.coverImageBytes,
    required this.coverImageWidth,
    required this.coverImageHeight,
    required this.coverImageScale,
    required this.coverImageOffsetX,
    required this.coverImageOffsetY,
    required this.accentImageBytes,
    required this.accentImageWidth,
    required this.accentImageHeight,
    required this.accentImageScale,
    required this.accentImageOffsetX,
    required this.accentImageOffsetY,
    required this.createdAt,
    required this.lastModified,
    required this.lastAccessed,
    required this.unpinnedIndex,
  });
}
