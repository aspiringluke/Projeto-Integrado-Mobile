import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../pages/project_page.dart';
import 'synopsis_scroll_box.dart';

class ProjectCard extends StatefulWidget {
  final String title;

  const ProjectCard({super.key, this.title = 'Projeto 1'});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> with SingleTickerProviderStateMixin {
  static const String _initialSynopsis = '';

  bool _isExpanded = false;
  bool _isEditing = false;
  _ProjectDateType _activeDateType = _ProjectDateType.lastModified;
  late final _ProjectDateEntries _dateEntries;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _detailsFadeAnimation;
  late final ScrollController _synopsisScrollController;
  late final TextEditingController _synopsisController;

  @override
  void initState() {
    super.initState();
    _dateEntries = _ProjectDateEntries.fromSeed(widget.title.hashCode);
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _detailsFadeAnimation = CurvedAnimation(
      parent: _expandController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 0.8, curve: Curves.easeIn),
    );
    _synopsisScrollController = ScrollController();
    _synopsisController = TextEditingController(text: _initialSynopsis);
  }

  @override
  void dispose() {
    _synopsisController.dispose();
    _synopsisScrollController.dispose();
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

  _ProjectDateEntry get _currentDateEntry => _dateEntries.forType(_activeDateType);

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
      child: AnimatedScale(
        scale: _isExpanded ? 1.006 : 1.0,
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeOutCubic,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isExpanded
                            ? const [
                                Color(0xA6F1D1E2),
                                Color(0x7DFFF7FB),
                                Color(0x88E4BECF),
                              ]
                            : const [
                                Color(0x90E2DDE2),
                                Color(0x72FBFAFB),
                                Color(0x80C7C2C9),
                              ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.32),
                        width: 0.75,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 11,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _expandAnimation,
                      builder: (context, child) {
                        final bottomRadius = Radius.circular(16 * (1 - _expandAnimation.value));

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
                                    isEditing: _isEditing,
                                    synopsisController: _synopsisController,
                                    onCycleDateType: _cycleDateType,
                                    onToggleEditing: _toggleEditing,
                                    synopsisScrollController: _synopsisScrollController,
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
              left: 6,
              top: 6,
              child: const _PinBadge(),
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
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(16),
          bottom: bottomRadius,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isExpanded
              ? const [
                  Color(0xC6F1D4E2),
                  Color(0xA3FFF9FC),
                  Color(0xB8E6BED1),
                ]
              : const [
                  Color(0xC7DDD7DE),
                  Color(0xB6FBFAFB),
                  Color(0xB4C8C2CB),
                ],
          stops: const [0.0, 0.52, 1.0],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(16),
            bottom: bottomRadius,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isExpanded
                ? [
                    Colors.white.withValues(alpha: 0.22),
                    Colors.white.withValues(alpha: 0.06),
                    const Color(0x54D7AFC2),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.18),
                    Colors.white.withValues(alpha: 0.05),
                    const Color(0x46AFA7B3),
                  ],
            stops: const [0.0, 0.48, 1.0],
          ),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.24),
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              right: 52,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onOpenProject,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40, right: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: isExpanded ? const Color(0xFFFDF9FC) : const Color(0xFFF8F7F9),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.28),
                              blurRadius: 6,
                              offset: const Offset(0, 1.5),
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
              left: 14,
              right: 20,
              top: 4,
              height: 18,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.02),
                      ],
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
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
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
  const _PinBadge();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFF4EEF3).withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.7),
              width: 0.65,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Transform.rotate(
              angle: -0.32,
              child: const Icon(
                Icons.push_pin_outlined,
                size: 15,
                color: Color(0xFF8A828C),
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

  const _ProjectDateEntry({
    required this.label,
    required this.value,
  });
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
      Duration(days: 220 + (normalizedSeed % 290), hours: 2 + (normalizedSeed % 11)),
    );
    final lastModified = now.subtract(
      Duration(days: 2 + (normalizedSeed % 18), hours: 4 + (normalizedSeed % 8)),
    );
    final lastAccessed = now.subtract(
      Duration(hours: 7 + (normalizedSeed % 20), minutes: 14 + (normalizedSeed % 33)),
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
      createdAt: _ProjectDateEntry(
        label: 'Criado em',
        value: createdAt,
      ),
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
  final bool isEditing;
  final TextEditingController synopsisController;
  final VoidCallback onCycleDateType;
  final VoidCallback onToggleEditing;
  final ScrollController synopsisScrollController;

  const _ProjectDetails({
    required this.dateEntry,
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xCCF5E0E9),
            Color(0xB8FBEFF5),
            Color(0xC3E6C6D8),
          ],
          stops: [0.0, 0.54, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.28), width: 0.7),
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
              _GlassSurface(
                width: 36,
                height: 36,
                radius: 10,
                padding: EdgeInsets.zero,
                blurSigma: 4,
                fillColor: const Color(0xFFF3EEF1).withValues(alpha: 0.34),
                borderColor: Colors.white.withValues(alpha: 0.54),
                borderWidth: 0.65,
                onTap: onToggleEditing,
                child: Icon(
                  isEditing ? Icons.check_rounded : Icons.edit_outlined,
                  size: 18,
                  color: Colors.black54,
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
              color: Colors.black87,
              height: 1.4,
            ),
            fillColor: const Color(0xFFFFF7FB).withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.38),
              width: 0.7,
            ),
            placeholderStyle: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF8F8990),
              fontStyle: FontStyle.italic,
            ),
            viewerBuilder: (context, text, style) {
              return _ProjectMarkdownText(
                data: text,
                style: style,
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTag('Tag 1', const Color(0xFFF8BBD0)),
              const SizedBox(width: 8),
              _buildTag('Tag 2', const Color(0xFFBBDEFB)),
            ],
          ),
          const SizedBox(height: 16),
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
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F1F4).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.32),
                    width: 0.7,
                  ),
                ),
                child: const Icon(
                  Icons.swap_horiz,
                  color: Colors.black54,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCircle() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFC9C7CC).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final _ProjectDateEntry dateEntry;
  final VoidCallback onTapClock;

  const _TimeField({
    required this.dateEntry,
    required this.onTapClock,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            left: 18,
            child: _GlassSurface(
              radius: 21,
              blurSigma: 8,
              padding: const EdgeInsets.only(left: 36, right: 14),
              fillColor: const Color(0xFFE1DCE2).withValues(alpha: 0.52),
              borderColor: Colors.white.withValues(alpha: 0.7),
              borderWidth: 0.75,
              alignment: Alignment.centerLeft,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xCCFFFFFF),
                  Color(0xB5E7E1E7),
                  Color(0x9CCEC6CF),
                ],
                stops: [0.0, 0.48, 1.0],
              ),
              child: Text(
                _formatDateLabel(dateEntry),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF2C262C),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 3,
            bottom: 3,
            child: _GlassSurface(
              width: 36,
              height: 36,
              radius: 18,
              padding: EdgeInsets.zero,
              blurSigma: 6,
              fillColor: const Color(0xFFF0BEDB).withValues(alpha: 0.42),
              borderColor: Colors.white.withValues(alpha: 0.66),
              borderWidth: 0.7,
              onTap: onTapClock,
              child: const Icon(
                Icons.history_rounded,
                size: 18,
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

  const _ProjectMarkdownText({
    required this.data,
    required this.style,
  });

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
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const _GlassSurface({
    this.child,
    required this.radius,
    this.blurSigma = 8,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(0),
    this.alignment = Alignment.center,
    required this.fillColor,
    required this.borderColor,
    this.borderWidth = 0.8,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ??
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
      width: width,
      height: height,
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
            Colors.white.withValues(alpha: 0.12),
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
        child: onTap == null
            ? surface
            : Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(radius),
                  onTap: onTap,
                  child: surface,
                ),
              ),
      ),
    );
  }
}
