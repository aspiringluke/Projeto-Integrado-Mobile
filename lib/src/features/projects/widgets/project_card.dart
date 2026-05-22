import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../characters/data/repositories/character_repository.dart';
import '../../characters/models/characters_models.dart';
import '../../characters/widgets/character_notebook_page.dart';
import '../models/project_image_data.dart';
import '../models/project_record.dart';
import '../models/project_tag_data.dart';
import '../models/project_style_defaults.dart';
import '../pages/project_page.dart';
import '../utils/project_character_showcase.dart';
import '../../../shared/utils/rect_from_context.dart';
import '../../../shared/widgets/anchored_info_bubble.dart';
import 'project_cover_fill.dart';
import 'project_image_transform_view.dart';
import 'project_image_viewer_dialog.dart';
import '../../../shared/widgets/buttons/glass_circle_button.dart';
import '../../../shared/widgets/outlined_tag_pill.dart';
import '../../../shared/widgets/pin_badge.dart';
import '../../../shared/widgets/synopsis_scroll_box.dart';

part 'project_card_header.dart';
part 'project_card_details.dart';
part 'project_card_parts/project_card_details_widgets.dart';
part 'project_card_info_bubble.dart';

class ProjectCard extends StatefulWidget {
  final int? projectId;
  final String title;
  final String synopsis;
  final List<ProjectTagData> tags;
  final List<ProjectTagData> availableTags;
  final Color coverColor;
  final Color accentColor;
  final ProjectImageData coverImage;
  final ProjectImageData accentImage;
  final bool isPinned;
  final VoidCallback? onTogglePinned;
  final DateTime createdAt;
  final DateTime lastModified;
  final DateTime lastAccessed;
  final String characterDisplayMode;
  final int characterGridColumns;
  final List<int> featuredCharacterIds;
  final List<CharacterListItem> displayedCharacters;
  final int unpinnedIndex;
  final VoidCallback? onOpenProject;
  final VoidCallback? onProjectReloadRequested;
  final ValueChanged<ProjectRecord>? onProjectChanged;
  final void Function(String title, String synopsis)? onProjectEdited;
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    this.projectId,
    this.title = 'Projeto 1',
    this.synopsis = '',
    this.tags = const <ProjectTagData>[],
    this.availableTags = const <ProjectTagData>[],
    this.coverColor = defaultProjectCoverColor,
    this.accentColor = defaultProjectAccentColor,
    this.coverImage = const ProjectImageData(),
    this.accentImage = const ProjectImageData(),
    this.isPinned = false,
    this.onTogglePinned,
    required this.createdAt,
    required this.lastModified,
    required this.lastAccessed,
    this.characterDisplayMode = 'list',
    this.characterGridColumns = 3,
    this.featuredCharacterIds = const <int>[],
    this.displayedCharacters = const <CharacterListItem>[],
    this.unpinnedIndex = 0,
    this.onOpenProject,
    this.onProjectReloadRequested,
    this.onProjectChanged,
    this.onProjectEdited,
    this.onDelete,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isEditing = false;
  _ProjectDateType _activeDateType = _ProjectDateType.lastModified;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _detailsFadeAnimation;
  late final AnimationController _entranceController;
  late final Animation<double> _entranceAnimation;
  late final ScrollController _synopsisScrollController;
  late final TextEditingController _titleController;
  late final TextEditingController _synopsisController;
  late final FocusNode _titleFocusNode;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
    _detailsFadeAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
    _synopsisScrollController = ScrollController();
    _titleController = TextEditingController(text: widget.title);
    _synopsisController = TextEditingController(text: widget.synopsis);
    _titleFocusNode = FocusNode();
    _entranceController.forward();
  }

  @override
  void didUpdateWidget(covariant ProjectCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title &&
        widget.title != _titleController.text) {
      _titleController.text = widget.title;
    }
    if (oldWidget.synopsis != widget.synopsis &&
        widget.synopsis != _synopsisController.text) {
      _synopsisController.text = widget.synopsis;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _synopsisController.dispose();
    _synopsisScrollController.dispose();
    _titleFocusNode.dispose();
    _entranceController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  Future<void> _openProject() async {
    widget.onOpenProject?.call();
    final updatedProject = await Navigator.of(context).push<ProjectRecord>(
      MaterialPageRoute<ProjectRecord>(
        builder: (_) => ProjectPage(
          projectId: widget.projectId,
          title: widget.title,
          synopsis: widget.synopsis,
          tags: widget.tags,
          availableTags: widget.availableTags,
          accentColor: widget.accentColor,
          coverColor: widget.coverColor,
          coverImage: widget.coverImage,
          accentImage: widget.accentImage,
          createdAt: widget.createdAt,
          lastModified: widget.lastModified,
          lastAccessed: widget.lastAccessed,
          isPinned: widget.isPinned,
          unpinnedIndex: widget.unpinnedIndex,
          initialCharacterDisplayMode: widget.characterDisplayMode,
          initialAvatarGridColumns: widget.characterGridColumns,
          featuredCharacterIds: widget.featuredCharacterIds,
        ),
      ),
    );
    if (updatedProject != null) {
      widget.onProjectChanged?.call(updatedProject);
      return;
    }

    widget.onProjectReloadRequested?.call();
  }

  Future<void> _openCoverImageViewer() async {
    if (widget.coverImage.bytes == null) {
      return;
    }

    await showProjectImageViewerDialog(
      context,
      title: widget.title,
      subtitle: 'Imagem do projeto',
      image: widget.coverImage,
    );
  }

  void _cycleDateType() {
    setState(() {
      _activeDateType = switch (_activeDateType) {
        _ProjectDateType.lastModified => _ProjectDateType.lastAccessed,
        _ProjectDateType.lastAccessed => _ProjectDateType.createdAt,
        _ProjectDateType.createdAt => _ProjectDateType.lastModified,
      };
    });
  }

  _ProjectDateEntry get _currentDateEntry => _ProjectDateEntries.fromValues(
    createdAt: widget.createdAt,
    lastModified: widget.lastModified,
    lastAccessed: widget.lastAccessed,
  ).forType(_activeDateType);

  void _toggleEditing() {
    if (_isEditing) {
      _confirmEditing();
      return;
    }

    setState(() {
      _isEditing = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _titleFocusNode.requestFocus();
      }
    });
  }

  void _confirmEditing() {
    if (!_isEditing) {
      return;
    }

    FocusScope.of(context).unfocus();
    final sanitizedTitle = _titleController.text.trim();
    final resolvedTitle = sanitizedTitle.isEmpty
        ? widget.title
        : sanitizedTitle;
    final resolvedSynopsis = _synopsisController.text;
    final hasChanges =
        resolvedTitle != widget.title || resolvedSynopsis != widget.synopsis;

    if (_titleController.text != resolvedTitle) {
      _titleController.value = _titleController.value.copyWith(
        text: resolvedTitle,
        selection: TextSelection.collapsed(offset: resolvedTitle.length),
        composing: TextRange.empty,
      );
    }

    setState(() {
      _isEditing = false;
    });

    if (hasChanges) {
      widget.onProjectEdited?.call(resolvedTitle, resolvedSynopsis);
    }
  }

  Future<void> _confirmDelete() async {
    widget.onDelete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) => _confirmEditing(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: AnimatedBuilder(
          animation: _entranceAnimation,
          builder: (context, child) {
            final offsetY = (1 - _entranceAnimation.value) * 10;
            return Opacity(
              opacity: _entranceAnimation.value,
              child: Transform.translate(
                offset: Offset(0, offsetY),
                child: child,
              ),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 2),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.accentColor.withValues(
                          alpha: _isExpanded ? 0.12 : 0.08,
                        ),
                        blurRadius: _isExpanded ? 12 : 10,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: _isExpanded ? 0.08 : 0.05,
                        ),
                        blurRadius: _isExpanded ? 12 : 9,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _buildProjectShellGradient(
                          widget.accentColor,
                          isExpanded: _isExpanded,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: _isExpanded ? 0.7 : 0.58,
                          ),
                          width: 0.85,
                        ),
                      ),
                      foregroundDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.13),
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.28, 0.56, 1.0],
                        ),
                      ),
                      child: AnimatedBuilder(
                        animation: _expandAnimation,
                        builder: (context, child) {
                          final bottomRadius = Radius.circular(
                            16 * (1 - _expandAnimation.value),
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ProjectHeader(
                                coverColor: widget.coverColor,
                                accentColor: widget.accentColor,
                                coverImage: widget.coverImage,
                                isExpanded: _isExpanded,
                                isEditing: _isEditing,
                                titleController: _titleController,
                                titleFocusNode: _titleFocusNode,
                                bottomRadius: bottomRadius,
                                onOpenProject: _openProject,
                                onOpenCoverImageViewer:
                                    widget.coverImage.bytes == null
                                    ? null
                                    : _openCoverImageViewer,
                                onToggleExpand: _toggleExpand,
                                onDelete: widget.onDelete == null
                                    ? null
                                    : _confirmDelete,
                              ),
                              ClipRect(
                                child: SizeTransition(
                                  sizeFactor: _expandAnimation,
                                  axisAlignment: -1,
                                  child: FadeTransition(
                                    opacity: _detailsFadeAnimation,
                                    child: _ProjectDetails(
                                      projectTitle: widget.title,
                                      projectId: widget.projectId,
                                      synopsis: widget.synopsis,
                                      dateEntry: _currentDateEntry,
                                      tags: widget.tags,
                                      availableTags: widget.availableTags,
                                      coverColor: widget.coverColor,
                                      accentColor: widget.accentColor,
                                      coverImage: widget.coverImage,
                                      accentImage: widget.accentImage,
                                      createdAt: widget.createdAt,
                                      lastModified: widget.lastModified,
                                      lastAccessed: widget.lastAccessed,
                                      isPinned: widget.isPinned,
                                      unpinnedIndex: widget.unpinnedIndex,
                                      featuredCharacterIds:
                                          widget.featuredCharacterIds,
                                      displayedCharacters:
                                          widget.displayedCharacters,
                                      isEditing: _isEditing,
                                      synopsisController: _synopsisController,
                                      onCycleDateType: _cycleDateType,
                                      onToggleEditing: _toggleEditing,
                                      onProjectChanged: widget.onProjectChanged,
                                      onProjectReloadRequested:
                                          widget.onProjectReloadRequested,
                                      synopsisScrollController:
                                          _synopsisScrollController,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: -4,
                child: PinBadge(
                  isActive: widget.isPinned,
                  onTap: widget.onTogglePinned,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

LinearGradient _buildProjectShellGradient(
  Color accentColor, {
  required bool isExpanded,
}) {
  final leading = Color.alphaBlend(
    accentColor.withValues(alpha: isExpanded ? 0.16 : 0.08),
    Colors.white.withValues(alpha: 0.84),
  );
  final center = Colors.white.withValues(alpha: isExpanded ? 0.82 : 0.76);
  final trailing = Color.alphaBlend(
    _lighten(accentColor, 0.22).withValues(alpha: isExpanded ? 0.18 : 0.1),
    const Color(0xFFF8F2F6).withValues(alpha: 0.82),
  );

  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [leading, center, trailing],
    stops: const [0.0, 0.48, 1.0],
  );
}

Color _lighten(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}
