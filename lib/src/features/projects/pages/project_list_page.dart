import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controllers/project_list_controller.dart';
import '../widgets/project_card.dart';

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
        if (controller.isLoading && controller.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

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

        final projects = controller.projects;
        final availableTags = controller.availableTags;

        Widget buildProjectCard(BuildContext context, int index) {
          final project = projects[index];
          final projectKey = ValueKey(project.id ?? project.title);
          final card = RepaintBoundary(
            child: ProjectCard(
              projectId: project.id,
              title: project.title,
              synopsis: project.synopsis,
              tags: project.tags,
              availableTags: availableTags,
              coverColor: project.coverColor,
              accentColor: project.accentColor,
              coverImage: project.coverImage,
              accentImage: project.accentImage,
              isPinned: project.isPinned,
              onTogglePinned: () => controller.togglePinned(project),
              createdAt: project.createdAt,
              lastModified: project.lastModified,
              lastAccessed: project.lastAccessed,
              characterDisplayMode: project.characterDisplayMode,
              characterGridColumns: project.characterGridColumns,
              featuredCharacterIds: project.featuredCharacterIds,
              displayedCharacters: project.displayedCharacters,
              unpinnedIndex: project.unpinnedIndex,
              onOpenProject: () =>
                  unawaited(controller.markProjectOpened(project)),
              onProjectChanged: (updatedProject) =>
                  controller.applyProjectPageUpdate(project, updatedProject),
              onProjectEdited: (title, synopsis) => unawaited(
                controller.updateProjectContent(
                  project,
                  title: title,
                  synopsis: synopsis,
                ),
              ),
              onProjectReloadRequested: () =>
                  unawaited(controller.refreshAfterProjectPage()),
              onDelete: () => unawaited(controller.deleteProject(project)),
            ),
          );

          if (isMobileReorderEnabled) {
            return ReorderableDelayedDragStartListener(
              key: projectKey,
              index: index,
              child: card,
            );
          }

          return KeyedSubtree(key: projectKey, child: card);
        }

        if (!isMobileReorderEnabled) {
          return ListView.builder(
            padding: listPadding,
            itemCount: projects.length,
            itemBuilder: buildProjectCard,
          );
        }

        return ReorderableListView.builder(
          buildDefaultDragHandles: false,
          padding: listPadding,
          itemCount: projects.length,
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
