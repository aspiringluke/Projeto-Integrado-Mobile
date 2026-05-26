import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/view_options_bar.dart';
import '../../../shared/widgets/funcoes_busca.dart';
import '../../../shared/widgets/buttons/glass_circle_button.dart';
import '../../../shared/widgets/multi_select_action_bar.dart';
import '../../../shared/widgets/pin_badge.dart';
import '../../../shared/utils/text_normalization.dart';
import '../../notas/utils/notes_dialogs.dart';
import '../controllers/project_list_controller.dart';
import '../models/project_record.dart';
import '../widgets/project_card.dart';
import '../widgets/project_cover_fill.dart';
import '../widgets/project_image_viewer_dialog.dart';
import 'project_page.dart';

enum _ProjectDisplayMode { list, grid }

class ProjectListPage extends StatefulWidget {
  final ProjectListController controller;
  final String searchQuery;
  final ContentFilterState filterState;
  final ContentSortState sortState;
  static const double _floatingActionButtonClearance = 112;

  const ProjectListPage({
    super.key,
    required this.controller,
    this.searchQuery = '',
    this.filterState = const ContentFilterState(),
    this.sortState = const ContentSortState(),
  });

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  _ProjectDisplayMode _displayMode = _ProjectDisplayMode.list;
  bool _selectionMode = false;
  final Set<int> _selectedProjectIds = <int>{};

  bool get _isMobileReorderEnabled {
    if (kIsWeb) return false;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }

  void _toggleDisplayMode() {
    setState(() {
      _displayMode = _displayMode == _ProjectDisplayMode.list
          ? _ProjectDisplayMode.grid
          : _ProjectDisplayMode.list;
    });
  }

  bool get _isSelectionMode => _selectionMode;

  void _toggleSelectionMode() {
    if (_selectionMode || _selectedProjectIds.isNotEmpty) {
      _clearSelection();
      return;
    }

    setState(() {
      _selectionMode = true;
    });
  }

  void _selectAllProjects() {
    setState(() {
      _selectionMode = true;
      _selectedProjectIds
        ..clear()
        ..addAll(
          widget.controller.projects
              .map((project) => project.id)
              .whereType<int>(),
        );
    });
  }

  void _clearSelection() {
    if (!_selectionMode && _selectedProjectIds.isEmpty) return;
    setState(() {
      _selectionMode = false;
      _selectedProjectIds.clear();
    });
  }

  void _toggleProjectSelection(ProjectListItem project) {
    final projectId = project.id;
    if (projectId == null) return;

    setState(() {
      _selectionMode = true;
      if (!_selectedProjectIds.add(projectId)) {
        _selectedProjectIds.remove(projectId);
      }
    });
  }

  bool _isProjectSelected(ProjectListItem project) {
    final projectId = project.id;
    return projectId != null && _selectedProjectIds.contains(projectId);
  }

  List<ProjectListItem> _visibleProjects(Iterable<ProjectListItem> projects) {
    final query = normalizeSearchText(widget.searchQuery);
    final filtered = projects
        .where((project) {
          if (query.isEmpty) {
            return widget.filterState.matchesTags(
              project.tags.map((tag) => tag.label),
            );
          }
          final haystack = normalizeSearchText(
            <String>[
              project.title,
              project.synopsis,
              ...project.tags.map((tag) => tag.label),
            ].join(' '),
          );
          return haystack.contains(query) &&
              widget.filterState.matchesTags(
                project.tags.map((tag) => tag.label),
              );
        })
        .toList(growable: false);

    return filtered.toList(growable: false)..sort((left, right) {
      if (left.isPinned != right.isPinned) {
        return left.isPinned ? -1 : 1;
      }

      final comparison = switch (widget.sortState.mode) {
        ContentSortMode.lastAccessed => right.lastAccessed.compareTo(
          left.lastAccessed,
        ),
        ContentSortMode.lastModified => right.lastModified.compareTo(
          left.lastModified,
        ),
        ContentSortMode.createdAt => right.createdAt.compareTo(left.createdAt),
        ContentSortMode.title => left.title.toLowerCase().compareTo(
          right.title.toLowerCase(),
        ),
        ContentSortMode.synopsisLength =>
          right.synopsis.trim().length.compareTo(left.synopsis.trim().length),
        ContentSortMode.characterCount =>
          widget.controller
              .characterCountForProject(right)
              .compareTo(widget.controller.characterCountForProject(left)),
      };
      return widget.sortState.reversed ? -comparison : comparison;
    });
  }

  Future<void> _openProject(ProjectListItem project) async {
    unawaited(widget.controller.markProjectOpened(project));
    final updatedProject = await Navigator.of(context).push<ProjectRecord>(
      MaterialPageRoute<ProjectRecord>(
        builder: (_) => ProjectPage(
          projectId: project.id,
          title: project.title,
          synopsis: project.synopsis,
          tags: project.tags,
          availableTags: widget.controller.availableTags,
          accentColor: project.accentColor,
          coverColor: project.coverColor,
          coverImage: project.coverImage,
          accentImage: project.accentImage,
          createdAt: project.createdAt,
          lastModified: project.lastModified,
          lastAccessed: project.lastAccessed,
          isPinned: project.isPinned,
          unpinnedIndex: project.unpinnedIndex,
          initialCharacterDisplayMode: project.characterDisplayMode,
          initialAvatarGridColumns: project.characterGridColumns,
          featuredCharacterIds: project.featuredCharacterIds,
        ),
      ),
    );

    if (updatedProject != null) {
      widget.controller.applyProjectPageUpdate(project, updatedProject);
      return;
    }

    unawaited(widget.controller.refreshAfterProjectPage());
  }

  Future<void> _openProjectImage(ProjectListItem project) async {
    if (project.coverImage.bytes == null) {
      return;
    }

    await showProjectImageViewerDialog(
      context,
      title: project.title,
      subtitle: 'Imagem do projeto',
      image: project.coverImage,
    );
  }

  Future<void> _confirmDeleteProject(ProjectListItem project) async {
    final impact = await widget.controller.buildProjectDeletionImpact(project);
    if (!mounted) return;

    final folderAction = await showDeleteProjectConfirmation(
      context,
      projectTitle: project.title,
      characterCount: impact.characterCount,
      linkedNoteCount: impact.linkedNoteCount,
      folderNoteCount: impact.folderNoteCount,
      hasProjectFolder: impact.hasProjectFolder,
    );
    if (!mounted || folderAction == null) return;

    await widget.controller.deleteProject(
      project,
      deleteProjectFolder:
          folderAction == ProjectFolderDeletionAction.deleteFolder,
      releaseProjectFolder: impact.hasProjectFolder,
    );
  }

  Future<void> _confirmDeleteSelectedProjects() async {
    final selectedProjects = widget.controller.projects
        .where((project) => _isProjectSelected(project))
        .toList(growable: false);
    if (selectedProjects.isEmpty) return;

    final impacts = await Future.wait(
      selectedProjects.map(widget.controller.buildProjectDeletionImpact),
    );
    if (!mounted) return;

    final folderAction = await showDeleteProjectsConfirmation(
      context,
      projectCount: selectedProjects.length,
      characterCount: impacts.fold<int>(
        0,
        (sum, impact) => sum + impact.characterCount,
      ),
      linkedNoteCount: impacts.fold<int>(
        0,
        (sum, impact) => sum + impact.linkedNoteCount,
      ),
      folderNoteCount: impacts.fold<int>(
        0,
        (sum, impact) => sum + impact.folderNoteCount,
      ),
      projectFolderCount: impacts
          .where((impact) => impact.hasProjectFolder)
          .length,
    );
    if (!mounted || folderAction == null) return;

    for (var index = 0; index < selectedProjects.length; index += 1) {
      final project = selectedProjects[index];
      final impact = impacts[index];
      await widget.controller.deleteProject(
        project,
        deleteProjectFolder:
            folderAction == ProjectFolderDeletionAction.deleteFolder,
        releaseProjectFolder: impact.hasProjectFolder,
      );
    }

    _clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final isMobileReorderEnabled = _isMobileReorderEnabled;
    final controller = widget.controller;
    final bottomListPadding =
        MediaQuery.paddingOf(context).bottom +
        ProjectListPage._floatingActionButtonClearance;
    final listPadding = EdgeInsets.fromLTRB(0, 0, 0, bottomListPadding);

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

        final projects = _visibleProjects(controller.projects);
        final availableTags = controller.availableTags;
        final hasActiveListTransform =
            widget.searchQuery.trim().isNotEmpty ||
            widget.filterState.isActive ||
            widget.sortState.isActive;
        final canReorder =
            isMobileReorderEnabled &&
            _displayMode == _ProjectDisplayMode.list &&
            !_isSelectionMode &&
            !hasActiveListTransform;

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
              onDelete: () => unawaited(_confirmDeleteProject(project)),
            ),
          );

          final selectableCard = _ProjectSelectionWrapper(
            selected: _isProjectSelected(project),
            selectionMode: _isSelectionMode,
            accentColor: project.accentColor,
            onToggleSelection: () => _toggleProjectSelection(project),
            child: card,
          );

          if (canReorder) {
            return ReorderableDelayedDragStartListener(
              key: projectKey,
              index: index,
              child: selectableCard,
            );
          }

          return KeyedSubtree(key: projectKey, child: selectableCard);
        }

        Widget buildGrid() {
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.sizeOf(context).width;
              const spacing = 10.0;
              const columns = 3;
              const horizontalPadding = 16.0;
              final contentWidth = (width - horizontalPadding * 2).clamp(
                0.0,
                double.infinity,
              );
              final tileWidth =
                  (contentWidth - spacing * (columns - 1)) / columns;

              return ListView(
                padding: listPadding,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: 10,
                      children: [
                        for (var index = 0; index < projects.length; index += 1)
                          SizedBox(
                            width: tileWidth,
                            child: _ProjectGridTile(
                              project: projects[index],
                              selectionMode: _isSelectionMode,
                              isSelected: _isProjectSelected(projects[index]),
                              onTap: () => _isSelectionMode
                                  ? _toggleProjectSelection(projects[index])
                                  : unawaited(_openProject(projects[index])),
                              onLongPress: () =>
                                  _toggleProjectSelection(projects[index]),
                              onTogglePinned: () =>
                                  controller.togglePinned(projects[index]),
                              onOpenImage:
                                  projects[index].coverImage.bytes == null
                                  ? null
                                  : () => unawaited(
                                      _openProjectImage(projects[index]),
                                    ),
                              onDelete: () => unawaited(
                                _confirmDeleteProject(projects[index]),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        }

        Widget buildList() {
          if (!canReorder) {
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
        }

        if (projects.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Nenhum projeto encontrado com os filtros atuais.',
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

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ViewOptionsBar(
                          title: 'Visualização',
                          modeIcon: _displayMode == _ProjectDisplayMode.grid
                              ? Icons.grid_view_rounded
                              : Icons.view_list_rounded,
                          modeLabel: _displayMode == _ProjectDisplayMode.grid
                              ? 'Grade'
                              : 'Lista',
                          toggleTooltip:
                              _displayMode == _ProjectDisplayMode.grid
                              ? 'Exibir em lista'
                              : 'Exibir em grade',
                          onToggleMode: _toggleDisplayMode,
                        ),
                      ),
                      const SizedBox(width: 8),
                      MultiSelectIconButton(
                        icon: _isSelectionMode
                            ? Icons.close_rounded
                            : Icons.checklist_rounded,
                        tooltip: _isSelectionMode
                            ? 'Sair da seleção'
                            : 'Selecionar',
                        onTap: _toggleSelectionMode,
                      ),
                      const SizedBox(width: 8),
                      MultiSelectIconButton(
                        icon: Icons.select_all_rounded,
                        tooltip: 'Selecionar tudo',
                        onTap: _selectAllProjects,
                      ),
                    ],
                  ),
                  if (_isSelectionMode) ...[
                    const SizedBox(height: 10),
                    MultiSelectActionBar(
                      label:
                          '${_selectedProjectIds.length} projeto(s) selecionado(s)',
                      onClear: _clearSelection,
                      actions: [
                        MultiSelectAction(
                          icon: Icons.delete_outline_rounded,
                          tooltip: 'Excluir selecionados',
                          onTap: _confirmDeleteSelectedProjects,
                          destructive: true,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: _displayMode == _ProjectDisplayMode.list
                  ? buildList()
                  : buildGrid(),
            ),
          ],
        );
      },
    );
  }
}

class _ProjectSelectionWrapper extends StatelessWidget {
  final Widget child;
  final bool selectionMode;
  final bool selected;
  final Color accentColor;
  final VoidCallback onToggleSelection;

  const _ProjectSelectionWrapper({
    required this.child,
    required this.selectionMode,
    required this.selected,
    required this.accentColor,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: onToggleSelection,
      child: Stack(
        children: [
          child,
          if (selectionMode)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onToggleSelection,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(32, 10, 16, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: selected
                          ? Border.all(
                              color: accentColor.withValues(alpha: 0.72),
                              width: 2,
                            )
                          : null,
                      color: selected
                          ? accentColor.withValues(alpha: 0.08)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          if (selectionMode)
            Positioned(
              top: 14,
              right: 24,
              child: _SelectionBadge(
                selected: selected,
                accentColor: accentColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectionBadge extends StatelessWidget {
  final bool selected;
  final Color accentColor;

  const _SelectionBadge({required this.selected, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.72),
        border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        selected
            ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded,
        size: 18,
        color: selected ? accentColor : const Color(0xFF544959),
      ),
    );
  }
}

class _ProjectGridTile extends StatelessWidget {
  final ProjectListItem project;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onTogglePinned;
  final VoidCallback? onOpenImage;
  final VoidCallback onDelete;
  final bool selectionMode;
  final bool isSelected;

  const _ProjectGridTile({
    required this.project,
    required this.onTap,
    required this.onLongPress,
    required this.onTogglePinned,
    required this.onOpenImage,
    required this.onDelete,
    required this.selectionMode,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 120.0;
        final buttonSize = tileWidth < 112 ? 24.0 : 28.0;
        final iconSize = tileWidth < 112 ? 12.0 : 14.0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onTap,
                onLongPress: onLongPress,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.72),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: project.accentColor.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 158,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ProjectCoverFill(
                            color: project.coverColor,
                            accentColor: project.accentColor,
                            imageBytes: project.coverImage.bytes,
                            imageWidth: project.coverImage.width,
                            imageHeight: project.coverImage.height,
                            imageScale: project.coverImage.scale,
                            imageOffsetX: project.coverImage.offsetX,
                            imageOffsetY: project.coverImage.offsetY,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.12),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.42),
                                ],
                                stops: const [0, 0.48, 1],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  project.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    fontStyle: FontStyle.italic,
                                    height: 1.05,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                if (project.synopsis.trim().isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Text(
                                    project.synopsis.trim(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.78,
                                      ),
                                      fontSize: 10.2,
                                      height: 1.05,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Positioned(
                            top: 7,
                            right: 7,
                            child: selectionMode
                                ? _SelectionBadge(
                                    selected: isSelected,
                                    accentColor: project.accentColor,
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (onOpenImage != null) ...[
                                        GlassCircleButton(
                                          diameter: buttonSize,
                                          onTap: onOpenImage,
                                          tooltip: 'Ver imagem',
                                          fillColor: Colors.white.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderColor: Colors.white.withValues(
                                            alpha: 0.72,
                                          ),
                                          borderWidth: 0.8,
                                          blurSigma: 12,
                                          child: Icon(
                                            Icons.open_in_full_rounded,
                                            size: iconSize,
                                            color: Colors.white.withValues(
                                              alpha: 0.96,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                      ],
                                      GlassCircleButton(
                                        diameter: buttonSize,
                                        onTap: onDelete,
                                        tooltip: 'Excluir projeto',
                                        fillColor: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderColor: Colors.white.withValues(
                                          alpha: 0.72,
                                        ),
                                        borderWidth: 0.8,
                                        blurSigma: 12,
                                        child: Icon(
                                          Icons.delete_outline_rounded,
                                          size: iconSize,
                                          color: Colors.white.withValues(
                                            alpha: 0.96,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          if (selectionMode && isSelected)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: project.accentColor.withValues(
                                        alpha: 0.7,
                                      ),
                                      width: 2,
                                    ),
                                    color: project.accentColor.withValues(
                                      alpha: 0.08,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: -4,
              child: PinBadge(
                isActive: project.isPinned,
                onTap: onTogglePinned,
              ),
            ),
          ],
        );
      },
    );
  }
}
