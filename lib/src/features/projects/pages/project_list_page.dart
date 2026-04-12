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
  }) {
    final sanitizedTitle = title.trim();
    if (sanitizedTitle.isEmpty) return;

    final unpinnedCount = _projects.where((item) => !item.isPinned).length;
    final resolvedTags = _resolveTags(tags);

    _projects.add(
      _ProjectListItem(
        title: sanitizedTitle,
        synopsis: synopsis.trim(),
        tags: resolvedTags,
        coverColor: coverColor,
        accentColor: accentColor,
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
              isPinned: project.isPinned,
              onTogglePinned: () => controller._togglePinned(project),
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
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller._projects.length,
            itemBuilder: buildProjectCard,
          );
        }

        return ReorderableListView.builder(
          buildDefaultDragHandles: false,
          padding: const EdgeInsets.symmetric(vertical: 8),
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
  final String title;
  final String synopsis;
  final List<ProjectTagData> tags;
  final Color coverColor;
  final Color accentColor;
  bool isPinned = false;
  int unpinnedIndex;

  _ProjectListItem({
    required this.title,
    required this.synopsis,
    required this.tags,
    required this.coverColor,
    required this.accentColor,
    required this.unpinnedIndex,
  });
}
