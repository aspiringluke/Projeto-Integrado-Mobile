import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/project_card.dart';

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  late List<_ProjectListItem> _projects;

  bool get _isMobileReorderEnabled {
    if (kIsWeb) return false;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }

  @override
  void initState() {
    super.initState();
    _projects = <_ProjectListItem>[];
  }

  void _togglePinned(_ProjectListItem project) {
    setState(() {
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
    });
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
    final pinned = _projects.where((item) => item.isPinned).toList(growable: false);
    final unpinned = _projects.where((item) => !item.isPinned).toList(growable: false);
    _projects = <_ProjectListItem>[
      ...pinned,
      ...unpinned,
    ];
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

  @override
  Widget build(BuildContext context) {
    if (_projects.isEmpty) {
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
      final project = _projects[index];
      final card = RepaintBoundary(
        child: ProjectCard(
          title: project.title,
          isPinned: project.isPinned,
          onTogglePinned: () => _togglePinned(project),
        ),
      );

      if (_isMobileReorderEnabled) {
        return ReorderableDelayedDragStartListener(
          key: ValueKey(project.title),
          index: index,
          child: card,
        );
      }

      return KeyedSubtree(
        key: ValueKey(project.title),
        child: card,
      );
    }

    if (!_isMobileReorderEnabled) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _projects.length,
        itemBuilder: buildProjectCard,
      );
    }

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _projects.length,
      onReorder: (oldIndex, newIndex) {
        if (!_isMobileReorderEnabled) return;

        if (newIndex > oldIndex) {
          newIndex -= 1;
        }

        setState(() {
          final item = _projects.removeAt(oldIndex);
          _projects.insert(newIndex, item);
          _normalizePinnedGroups();
          _updateUnpinnedSlots();
        });
      },
      proxyDecorator: (widget, index, animation) {
        return Material(
          elevation: 12,
          color: Colors.transparent,
          shadowColor: Colors.pink.withValues(alpha: 0.25),
          child: Opacity(
            opacity: 0.95,
            child: Transform.scale(
              scale: 1.02,
              child: widget,
            ),
          ),
        );
      },
      itemBuilder: buildProjectCard,
    );
  }
}

class _ProjectListItem {
  final String title;
  bool isPinned = false;
  int unpinnedIndex;

  _ProjectListItem({
    required this.title,
    required this.unpinnedIndex,
  });
}
