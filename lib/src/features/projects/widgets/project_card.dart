import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../characters/widgets/character_overlays.dart';
import '../models/project_tag_data.dart';
import '../models/project_style_defaults.dart';
import '../pages/project_page.dart';
import 'project_cover_fill.dart';
import '../../../shared/widgets/buttons/glass_circle_button.dart';
import '../../../shared/widgets/outlined_tag_pill.dart';
import '../../../shared/widgets/synopsis_scroll_box.dart';

class ProjectCard extends StatefulWidget {
  final String title;
  final String synopsis;
  final List<ProjectTagData> tags;
  final Color coverColor;
  final Color accentColor;
  final bool isPinned;
  final VoidCallback? onTogglePinned;
  final DateTime createdAt;
  final DateTime lastModified;
  final DateTime lastAccessed;
  final VoidCallback? onOpenProject;
  final VoidCallback? onProjectEdited;

  const ProjectCard({
    super.key,
    this.title = 'Projeto 1',
    this.synopsis = '',
    this.tags = const <ProjectTagData>[],
    this.coverColor = defaultProjectCoverColor,
    this.accentColor = defaultProjectAccentColor,
    this.isPinned = false,
    this.onTogglePinned,
    required this.createdAt,
    required this.lastModified,
    required this.lastAccessed,
    this.onOpenProject,
    this.onProjectEdited,
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
  late final TextEditingController _synopsisController;

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
    _synopsisController = TextEditingController(text: widget.synopsis);
    _entranceController.forward();
  }

  @override
  void dispose() {
    _synopsisController.dispose();
    _synopsisScrollController.dispose();
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

  void _openProject() {
    widget.onOpenProject?.call();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProjectPage(title: widget.title),
      ),
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

  _ProjectDateEntry get _currentDateEntry =>
      _ProjectDateEntries.fromValues(
        createdAt: widget.createdAt,
        lastModified: widget.lastModified,
        lastAccessed: widget.lastAccessed,
      ).forType(_activeDateType);

  void _toggleEditing() {
    FocusScope.of(context).unfocus();

    final willStopEditing = _isEditing;
    setState(() {
      _isEditing = !_isEditing;
    });

    if (willStopEditing) {
      widget.onProjectEdited?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                              title: widget.title,
                              coverColor: widget.coverColor,
                              isExpanded: _isExpanded,
                              bottomRadius: bottomRadius,
                              onOpenProject: _openProject,
                              onToggleExpand: _toggleExpand,
                            ),
                            ClipRect(
                              child: SizeTransition(
                                sizeFactor: _expandAnimation,
                                axisAlignment: -1,
                                child: FadeTransition(
                                  opacity: _detailsFadeAnimation,
                                  child: _ProjectDetails(
                                    projectTitle: widget.title,
                                    dateEntry: _currentDateEntry,
                                    tags: widget.tags,
                                    accentColor: widget.accentColor,
                                    isEditing: _isEditing,
                                    synopsisController: _synopsisController,
                                    onCycleDateType: _cycleDateType,
                                    onToggleEditing: _toggleEditing,
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
              child: _PinBadge(
                isActive: widget.isPinned,
                onTap: widget.onTogglePinned,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectHeader extends StatelessWidget {
  final String title;
  final Color coverColor;
  final bool isExpanded;
  final Radius bottomRadius;
  final VoidCallback onOpenProject;
  final VoidCallback onToggleExpand;

  const _ProjectHeader({
    required this.title,
    required this.coverColor,
    required this.isExpanded,
    required this.bottomRadius,
    required this.onOpenProject,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(16),
          bottom: bottomRadius,
        ),
        border: Border(
          bottom: BorderSide(
            color: isExpanded
                ? Colors.white.withValues(alpha: 0.22)
                : Colors.transparent,
            width: 0.7,
          ),
        ),
      ),
      child: SizedBox(
        height: 60,
        child: Stack(
          children: [
            Positioned.fill(
              child: ProjectCoverFill(
                color: coverColor,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(16),
                  bottom: bottomRadius,
                ),
              ),
            ),
            Positioned.fill(
              right: 52,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onOpenProject,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50, right: 18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: isExpanded
                              ? const Color(0xFFF9F6FA)
                              : const Color(0xFFF7F4F8),
                          fontSize: 17.5,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.22),
                              blurRadius: 5,
                              offset: const Offset(0, 1.2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 26,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(16),
                      bottom: Radius.circular(bottomRadius.x),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onToggleExpand,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.black.withValues(alpha: 0.48),
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinBadge extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onTap;

  const _PinBadge({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(
              0xFFF4EEF3,
            ).withValues(alpha: isActive ? 0.9 : 0.78),
            gradient: isActive
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFF6D3E5).withValues(alpha: 0.96),
                      const Color(0xFFF0BEDB).withValues(alpha: 0.9),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.72),
                      const Color(0xFFF0E7EE).withValues(alpha: 0.82),
                    ],
                  ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: isActive ? 0.84 : 0.7),
              width: 0.65,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? const Color(0xFFDF6EB8).withValues(alpha: 0.26)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: isActive ? 10 : 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: AnimatedScale(
              scale: isActive ? 1.06 : 1,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              child: Transform.rotate(
                angle: -0.32,
                child: Icon(
                  isActive ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  size: isActive ? 16 : 15,
                  color: Color(
                    0xFF8A828C,
                  ).withValues(alpha: isActive ? 0.98 : 0.56),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _ProjectDateType { lastModified, lastAccessed, createdAt }

class _ProjectDateEntry {
  final String label;
  final DateTime value;

  const _ProjectDateEntry({required this.label, required this.value});
}

class _ProjectDateEntries {
  final _ProjectDateEntry lastModified;
  final _ProjectDateEntry lastAccessed;
  final _ProjectDateEntry createdAt;

  const _ProjectDateEntries({
    required this.lastModified,
    required this.lastAccessed,
    required this.createdAt,
  });

  factory _ProjectDateEntries.fromValues({
    required DateTime createdAt,
    required DateTime lastModified,
    required DateTime lastAccessed,
  }) {
    return _ProjectDateEntries(
      lastModified: _ProjectDateEntry(
        label: '\u00DAltima modifica\u00E7\u00E3o',
        value: lastModified,
      ),
      lastAccessed: _ProjectDateEntry(
        label: '\u00DAltimo acesso',
        value: lastAccessed,
      ),
      createdAt: _ProjectDateEntry(label: 'Criado', value: createdAt),
    );
  }

  _ProjectDateEntry forType(_ProjectDateType type) {
    return switch (type) {
      _ProjectDateType.lastModified => lastModified,
      _ProjectDateType.lastAccessed => lastAccessed,
      _ProjectDateType.createdAt => createdAt,
    };
  }
}

class _ProjectDetails extends StatelessWidget {
  final String projectTitle;
  final _ProjectDateEntry dateEntry;
  final List<ProjectTagData> tags;
  final Color accentColor;
  final bool isEditing;
  final TextEditingController synopsisController;
  final VoidCallback onCycleDateType;
  final VoidCallback onToggleEditing;
  final ScrollController synopsisScrollController;

  const _ProjectDetails({
    required this.projectTitle,
    required this.dateEntry,
    required this.tags,
    required this.accentColor,
    required this.isEditing,
    required this.synopsisController,
    required this.onCycleDateType,
    required this.onToggleEditing,
    required this.synopsisScrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              accentColor.withValues(alpha: 0.14),
              Colors.white.withValues(alpha: 0.78),
            ),
            Colors.white.withValues(alpha: 0.72),
            Color.alphaBlend(
              accentColor.withValues(alpha: 0.2),
              const Color(0xFFFFF8FC).withValues(alpha: 0.76),
            ),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.22),
            width: 0.7,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _TimeField(
                  accentColor: accentColor,
                  dateEntry: dateEntry,
                  onTapClock: onCycleDateType,
                ),
              ),
              const SizedBox(width: 12),
              GlassCircleButton(
                diameter: 36,
                onTap: onToggleEditing,
                blurSigma: 8,
                fillColor: Colors.white.withValues(alpha: 0.32),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.58),
                    accentColor.withValues(alpha: 0.2),
                    _lighten(accentColor, 0.22).withValues(alpha: 0.16),
                  ],
                ),
                borderColor: Colors.white.withValues(alpha: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.14),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                child: Icon(
                  isEditing ? Icons.check_rounded : Icons.edit_outlined,
                  size: 18,
                  color: const Color(0xFF544959),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          EditableSynopsisPanel(
            controller: synopsisController,
            scrollController: synopsisScrollController,
            isEditing: isEditing,
            focusedBorderColor: accentColor,
            placeholderText: synopsisPlaceholderText,
            textStyle: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8F8990),
              height: 1.4,
            ),
            fillColor: Colors.white.withValues(alpha: 0.72),
            blurSigma: 5,
            backgroundGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.8),
                const Color(0xFFFFF8FC).withValues(alpha: 0.68),
                const Color(0xFFF1E6EE).withValues(alpha: 0.42),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.78),
              width: 0.7,
            ),
            placeholderStyle: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF8F8990),
              fontStyle: FontStyle.italic,
            ),
            viewerBuilder: (context, text, style) {
              return _ProjectMarkdownText(data: text, style: style);
            },
          ),
          const SizedBox(height: 16),
          if (tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in tags)
                  OutlinedTagPill(label: tag.label, color: tag.color),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _showProjectCharacterInfo(
                      context,
                      rectFromContext(context),
                    ),
                    child: const _ProjectInfoButton(),
                  );
                },
              ),
              GlassCircleButton(
                diameter: 34,
                blurSigma: 6,
                fillColor: accentColor.withValues(alpha: 0.22),
                borderColor: Colors.white.withValues(alpha: 0.62),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.56),
                    accentColor.withValues(alpha: 0.22),
                    _lighten(accentColor, 0.22).withValues(alpha: 0.18),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.14),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                child: const Icon(
                  Icons.swap_horiz,
                  color: Color(0xFF544959),
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showProjectCharacterInfo(BuildContext context, Rect anchorRect) async {
    final recognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProjectPage(
              title: projectTitle,
              initialSection: ProjectSectionId.configProjeto,
            ),
          ),
        );
      };

    await _showAnchoredInfoBubble(
      context: context,
      anchorRect: anchorRect,
      width: 260,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nenhum personagem exibido aqui.',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.82),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Os 3 personagens de maior relevância são automaticamente exibidos, ou você pode escolher manualmente na',
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.72),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.72),
                fontSize: 12,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: 'página de configurações do projeto',
                  style: const TextStyle(
                    color: Color(0xFF5B33A8),
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: recognizer,
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showAnchoredInfoBubble({
  required BuildContext context,
  required Rect anchorRect,
  required Widget child,
  double width = 180,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Info',
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 140),
    pageBuilder: (context, animation, secondaryAnimation) {
      final screenSize = MediaQuery.of(context).size;
      const horizontalPadding = 12.0;
      const arrowSize = 12.0;
      const verticalGap = 8.0;
      const estimatedHeight = 130.0;
      final left = (anchorRect.center.dx - (width / 2))
          .clamp(
            horizontalPadding,
            screenSize.width - width - horizontalPadding,
          )
          .toDouble();
      final showAbove = anchorRect.bottom + estimatedHeight > screenSize.height - 24;
      final top = (showAbove
              ? anchorRect.top - estimatedHeight - arrowSize - verticalGap
              : anchorRect.bottom + verticalGap)
          .clamp(12.0, screenSize.height - estimatedHeight - 12.0)
          .toDouble();
      final pointerLeft = (anchorRect.center.dx - left - (arrowSize / 2))
          .clamp(
            18.0,
            width - 18.0,
          )
          .toDouble();

      return Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: width,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 140),
                tween: Tween<double>(begin: 0.96, end: 1),
                builder: (context, scale, dialogChild) {
                  return Transform.scale(
                    scale: scale,
                    alignment: showAbove ? Alignment.bottomCenter : Alignment.topCenter,
                    child: dialogChild,
                  );
                },
                child: _AnchoredInfoBubble(
                  showAbove: showAbove,
                  pointerLeft: pointerLeft,
                  arrowSize: arrowSize,
                  child: child,
                ),
              ),
            ),
          ],
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _AnchoredInfoBubble extends StatelessWidget {
  final bool showAbove;
  final double pointerLeft;
  final double arrowSize;
  final Widget child;

  const _AnchoredInfoBubble({
    required this.showAbove,
    required this.pointerLeft,
    required this.arrowSize,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.86),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    final arrow = Positioned(
      left: pointerLeft,
      top: showAbove ? null : 0,
      bottom: showAbove ? 0 : null,
      child: CustomPaint(
        size: Size(arrowSize, arrowSize),
        painter: _BubbleArrowPainter(
          color: Colors.white.withValues(alpha: 0.9),
          pointUp: !showAbove,
        ),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: showAbove
              ? EdgeInsets.only(bottom: arrowSize - 1)
              : EdgeInsets.only(top: arrowSize - 1),
          child: bubble,
        ),
        arrow,
      ],
    );
  }
}

class _BubbleArrowPainter extends CustomPainter {
  final Color color;
  final bool pointUp;

  const _BubbleArrowPainter({
    required this.color,
    required this.pointUp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    if (pointUp) {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close();
    }

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BubbleArrowPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.pointUp != pointUp;
  }
}

class _ProjectInfoButton extends StatelessWidget {
  const _ProjectInfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 38,
      height: 38,
      child: Center(
        child: _DottedCircle(),
      ),
    );
  }
}

class _DottedCircle extends StatelessWidget {
  const _DottedCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(
        painter: _DottedCirclePainter(
          color: const Color(0xFFB0B0B0),
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _DottedCirclePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final dashLength = 5.0;
    final gapLength = 4.0;
    final circumference = 2 * 3.1415926535897932 * radius;
    final dashAngle = dashLength / radius;
    final gapAngle = gapLength / radius;

    for (var startAngle = 0.0;
        startAngle < 2 * 3.1415926535897932;
        startAngle += dashAngle + gapAngle) {
      canvas.drawArc(rect, startAngle, dashAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TimeField extends StatelessWidget {
  final Color accentColor;
  final _ProjectDateEntry dateEntry;
  final VoidCallback onTapClock;

  const _TimeField({
    required this.accentColor,
    required this.dateEntry,
    required this.onTapClock,
  });

  @override
  Widget build(BuildContext context) {
    const circleDiameter = 38.0;
    const fieldHeight = 50.0;
    const pillLeftInset = 8.0;

    return SizedBox(
      height: fieldHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            left: pillLeftInset,
            child: _GlassSurface(
              radius: fieldHeight / 2,
              blurSigma: 9,
              padding: const EdgeInsets.only(left: 40, right: 31),
              fillColor: accentColor.withValues(alpha: 0.16),
              borderColor: Colors.white.withValues(alpha: 0.84),
              borderWidth: 0.75,
              alignment: Alignment.centerLeft,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.64),
                  accentColor.withValues(alpha: 0.18),
                  _lighten(accentColor, 0.24).withValues(alpha: 0.12),
                ],
                stops: [0.0, 0.48, 1.0],
              ),
              child: Text(
                _formatDateLabel(dateEntry),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF2C262C),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: GlassCircleButton(
              diameter: circleDiameter,
              onTap: onTapClock,
              blurSigma: 8,
              fillColor: accentColor.withValues(alpha: 0.42),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.7),
                  _lighten(accentColor, 0.18).withValues(alpha: 0.52),
                  accentColor.withValues(alpha: 0.42),
                ],
              ),
              borderColor: Colors.white.withValues(alpha: 0.84),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.12),
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              child: const Icon(
                Icons.history_rounded,
                size: 19,
                color: Color(0xFF171419),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateLabel(_ProjectDateEntry entry) {
    return '${entry.label}: ${_formatRelativePhrase(entry.value)}\n${_formatDate(entry.value)}';
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString().padLeft(4, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  String _formatRelativePhrase(DateTime value) {
    final difference = DateTime.now().difference(value);

    if (difference.inMinutes < 1) return 'h\u00E1 menos de 1 minuto';
    if (difference.inMinutes < 60) {
      return 'h\u00E1 ${_pluralize(difference.inMinutes, 'minuto', 'minutos')}';
    }
    if (difference.inHours < 24) {
      return 'h\u00E1 ${_pluralize(difference.inHours, 'hora', 'horas')}';
    }
    if (difference.inDays < 7) {
      return 'h\u00E1 ${_pluralize(difference.inDays, 'dia', 'dias')}';
    }
    if (difference.inDays < 30) {
      return 'h\u00E1 ${_pluralize((difference.inDays / 7).floor(), 'semana', 'semanas')}';
    }
    if (difference.inDays < 365) {
      return 'h\u00E1 ${_pluralize((difference.inDays / 30).floor(), 'm\u00EAs', 'meses')}';
    }
    return 'h\u00E1 ${_pluralize((difference.inDays / 365).floor(), 'ano', 'anos')}';
  }

  String _pluralize(int value, String singular, String plural) {
    final normalizedValue = value < 1 ? 1 : value;
    return normalizedValue == 1 ? '1 $singular' : '$normalizedValue $plural';
  }
}

class _ProjectMarkdownText extends StatelessWidget {
  final String data;
  final TextStyle style;

  const _ProjectMarkdownText({required this.data, required this.style});

  @override
  Widget build(BuildContext context) {
    final sanitizedData = _sanitizeProjectMarkdown(data);
    final normalizedData = sanitizedData.trim().isEmpty ? ' ' : sanitizedData;
    final styleSheet = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: style,
      pPadding: EdgeInsets.zero,
      blockSpacing: 0,
      listIndent: 18,
      listBullet: style,
      listBulletPadding: const EdgeInsets.only(right: 6),
      strong: style.copyWith(fontWeight: FontWeight.w700),
      em: style.copyWith(fontStyle: FontStyle.italic),
      code: style.copyWith(
        fontFamily: 'monospace',
        backgroundColor: Colors.transparent,
      ),
      blockquote: style,
      blockquotePadding: EdgeInsets.zero,
      blockquoteDecoration: const BoxDecoration(),
    );

    return MarkdownBody(
      data: normalizedData,
      shrinkWrap: true,
      softLineBreak: true,
      styleSheet: styleSheet,
    );
  }
}

String _sanitizeProjectMarkdown(String data) {
  final withoutHtml = data.replaceAll(RegExp(r'<[^>]*>'), '');
  final rawLines = withoutHtml.split('\n');
  final sanitizedLines = <String>[];
  final atxHeadingPattern = RegExp(r'^\s{0,3}#{1,6}\s*');
  final setextHeadingPattern = RegExp(r'^\s{0,3}(=+|-+)\s*$');

  for (final line in rawLines) {
    final normalizedLine = line.replaceFirst(atxHeadingPattern, '');

    if (setextHeadingPattern.hasMatch(normalizedLine) &&
        sanitizedLines.isNotEmpty &&
        sanitizedLines.last.trim().isNotEmpty) {
      continue;
    }

    sanitizedLines.add(normalizedLine);
  }

  return sanitizedLines.join('\n');
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

class _GlassSurface extends StatelessWidget {
  final Widget? child;
  final double radius;
  final double blurSigma;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final Gradient? gradient;

  const _GlassSurface({
    this.child,
    required this.radius,
    this.blurSigma = 8,
    this.padding = const EdgeInsets.all(0),
    this.alignment = Alignment.center,
    required this.fillColor,
    required this.borderColor,
    this.borderWidth = 0.8,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient =
        gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(Colors.white.withValues(alpha: 0.14), fillColor),
            fillColor,
            Color.alphaBlend(Colors.black.withValues(alpha: 0.03), fillColor),
          ],
          stops: const [0.0, 0.52, 1.0],
        );
    final surface = Container(
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor,
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.10),
            Colors.white.withValues(alpha: 0.03),
            Colors.transparent,
          ],
          stops: const [0.0, 0.22, 0.52],
        ),
      ),
      child: child,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: surface,
      ),
    );
  }
}
