import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/project_tag_data.dart';
import '../pages/project_page.dart';
import '../../../shared/widgets/buttons/glass_circle_button.dart';
import '../../../shared/widgets/outlined_tag_pill.dart';
import '../../../shared/widgets/synopsis_scroll_box.dart';

class ProjectCard extends StatefulWidget {
  final String title;
  final String synopsis;
  final List<ProjectTagData> tags;
  final bool isPinned;
  final VoidCallback? onTogglePinned;

  const ProjectCard({
    super.key,
    this.title = 'Projeto 1',
    this.synopsis = '',
    this.tags = const <ProjectTagData>[],
    this.isPinned = false,
    this.onTogglePinned,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isEditing = false;
  _ProjectDateType _activeDateType = _ProjectDateType.lastModified;
  late final _ProjectDateEntries _dateEntries;
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
    _dateEntries = _ProjectDateEntries.fromSeed(widget.title.hashCode);
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ProjectPage(title: widget.title)),
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
      _dateEntries.forType(_activeDateType);

  void _toggleEditing() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isEditing = !_isEditing;
    });
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
                      color: Colors.black.withValues(
                        alpha: _isExpanded ? 0.08 : 0.06,
                      ),
                      blurRadius: _isExpanded ? 11 : 9,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isExpanded
                            ? [
                                const Color(0x7FECE1E9),
                                const Color(0x9CFBF7FB),
                                const Color(0x86E7DCE5),
                              ]
                            : [
                                const Color(0x78E5DCE5),
                                const Color(0x98FAF7FA),
                                const Color(0x80DDD4DE),
                              ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.48),
                        width: 0.75,
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
                                    dateEntry: _currentDateEntry,
                                    tags: widget.tags,
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
  final bool isExpanded;
  final Radius bottomRadius;
  final VoidCallback onOpenProject;
  final VoidCallback onToggleExpand;

  const _ProjectHeader({
    required this.title,
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

  factory _ProjectDateEntries.fromSeed(int seed) {
    final normalizedSeed = seed.abs();
    final now = DateTime.now();
    final createdAt = now.subtract(
      Duration(
        days: 220 + (normalizedSeed % 290),
        hours: 2 + (normalizedSeed % 11),
      ),
    );
    final lastModified = now.subtract(
      Duration(
        days: 2 + (normalizedSeed % 18),
        hours: 4 + (normalizedSeed % 8),
      ),
    );
    final lastAccessed = now.subtract(
      Duration(
        hours: 7 + (normalizedSeed % 20),
        minutes: 14 + (normalizedSeed % 33),
      ),
    );

    return _ProjectDateEntries(
      lastModified: _ProjectDateEntry(
        label: '\u00DAltima modifica\u00E7\u00E3o',
        value: lastModified,
      ),
      lastAccessed: _ProjectDateEntry(
        label: '\u00DAltimo acesso',
        value: lastAccessed,
      ),
      createdAt: _ProjectDateEntry(label: 'Criado em', value: createdAt),
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
  final _ProjectDateEntry dateEntry;
  final List<ProjectTagData> tags;
  final bool isEditing;
  final TextEditingController synopsisController;
  final VoidCallback onCycleDateType;
  final VoidCallback onToggleEditing;
  final ScrollController synopsisScrollController;

  const _ProjectDetails({
    required this.dateEntry,
    required this.tags,
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
                    const Color(0xFFF7EEF5).withValues(alpha: 0.28),
                    const Color(0xFFE4D4E1).withValues(alpha: 0.14),
                  ],
                ),
                borderColor: Colors.white.withValues(alpha: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
              Row(
                children: [
                  _buildCircle(),
                  const SizedBox(width: 4),
                  _buildCircle(),
                  const SizedBox(width: 4),
                  _buildCircle(),
                ],
              ),
              GlassCircleButton(
                diameter: 34,
                blurSigma: 6,
                fillColor: Colors.white.withValues(alpha: 0.28),
                borderColor: Colors.white.withValues(alpha: 0.62),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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

  Widget _buildCircle() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFC9C7CC).withValues(alpha: 0.54),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.48),
            const Color(0xFFD7D3D9).withValues(alpha: 0.36),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.62),
          width: 0.75,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final _ProjectDateEntry dateEntry;
  final VoidCallback onTapClock;

  const _TimeField({required this.dateEntry, required this.onTapClock});

  @override
  Widget build(BuildContext context) {
    const circleDiameter = 38.0;
    const fieldHeight = 38.0;
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
              fillColor: const Color(0xFFF3EEF3).withValues(alpha: 0.3),
              borderColor: Colors.white.withValues(alpha: 0.84),
              borderWidth: 0.75,
              alignment: Alignment.centerLeft,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.64),
                  const Color(0xFFF6EEF3).withValues(alpha: 0.32),
                  const Color(0xFFE3D8E0).withValues(alpha: 0.16),
                ],
                stops: [0.0, 0.48, 1.0],
              ),
              child: Text(
                _formatDateLabel(dateEntry),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
              fillColor: const Color(0xFFF0BEDB).withValues(alpha: 0.5),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.7),
                  const Color(0xFFF4D5E6).withValues(alpha: 0.52),
                  const Color(0xFFE8C4D9).withValues(alpha: 0.36),
                ],
              ),
              borderColor: Colors.white.withValues(alpha: 0.84),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDF6EB8).withValues(alpha: 0.08),
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
    return '${entry.label}: ${_formatDate(entry.value)}, ${_formatRelativePhrase(entry.value)}.';
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
