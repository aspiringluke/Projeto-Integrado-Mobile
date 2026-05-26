import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../features/projects/models/project_tag_data.dart';
import '../utils/text_normalization.dart';

enum ContentSortMode {
  lastAccessed,
  lastModified,
  createdAt,
  title,
  synopsisLength,
  characterCount,
}

enum ContentFilterMatchMode { any, all }

class ContentFilterState {
  final String tagQuery;
  final ContentFilterMatchMode matchMode;
  final bool inverted;

  const ContentFilterState({
    this.tagQuery = '',
    this.matchMode = ContentFilterMatchMode.any,
    this.inverted = false,
  });

  bool get isActive => tagQuery.trim().isNotEmpty;

  ContentFilterState copyWith({
    String? tagQuery,
    ContentFilterMatchMode? matchMode,
    bool? inverted,
  }) {
    return ContentFilterState(
      tagQuery: tagQuery ?? this.tagQuery,
      matchMode: matchMode ?? this.matchMode,
      inverted: inverted ?? this.inverted,
    );
  }

  bool matchesTags(Iterable<String> tags) {
    final terms = tagQuery
        .split(RegExp(r'[,;\n]'))
        .map(normalizeSearchText)
        .where((term) => term.isNotEmpty)
        .toList(growable: false);
    if (terms.isEmpty) {
      return true;
    }

    final normalizedTags = tags
        .map(normalizeSearchText)
        .where((tag) => tag.isNotEmpty)
        .toList(growable: false);
    final matches = switch (matchMode) {
      ContentFilterMatchMode.any => terms.any(
        (term) => normalizedTags.any((tag) => tag.contains(term)),
      ),
      ContentFilterMatchMode.all => terms.every(
        (term) => normalizedTags.any((tag) => tag.contains(term)),
      ),
    };

    return inverted ? !matches : matches;
  }
}

class TagFilterGroup {
  final String title;
  final Color color;
  final IconData? icon;
  final List<ProjectTagData> tags;

  const TagFilterGroup({
    required this.title,
    required this.color,
    required this.tags,
    this.icon,
  });
}

class ContentSortState {
  final ContentSortMode mode;
  final bool reversed;

  const ContentSortState({
    this.mode = ContentSortMode.lastAccessed,
    this.reversed = false,
  });

  bool get isActive => mode != ContentSortMode.lastAccessed || reversed;

  ContentSortState copyWith({ContentSortMode? mode, bool? reversed}) {
    return ContentSortState(
      mode: mode ?? this.mode,
      reversed: reversed ?? this.reversed,
    );
  }
}

String contentSortModeLabel(ContentSortMode mode) {
  return switch (mode) {
    ContentSortMode.lastAccessed => 'Último acesso',
    ContentSortMode.lastModified => 'Modificação',
    ContentSortMode.createdAt => 'Criação',
    ContentSortMode.title => 'Ordem alfabética',
    ContentSortMode.synopsisLength => 'Maior síntese',
    ContentSortMode.characterCount => 'Mais personagens',
  };
}

String contentFilterModeLabel(ContentFilterMatchMode mode) {
  return switch (mode) {
    ContentFilterMatchMode.any => 'Contém ao menos um',
    ContentFilterMatchMode.all => 'Contém todos',
  };
}

Future<ContentFilterState?> showContentFilterMenu({
  required BuildContext context,
  required ContentFilterState initial,
  Iterable<String> availableTags = const <String>[],
  Iterable<TagFilterGroup> availableTagGroups = const <TagFilterGroup>[],
}) {
  return showGeneralDialog<ContentFilterState>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Filtros',
    barrierColor: Colors.black.withValues(alpha: 0.12),
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, animation, secondaryAnimation) {
      final tagGroups = availableTagGroups.isNotEmpty
          ? availableTagGroups.toList(growable: false)
          : availableTags.isNotEmpty
          ? [
              TagFilterGroup(
                title: 'Tags',
                color: const Color(0xFFDF6EB8),
                tags: availableTags
                    .map(
                      (tag) => ProjectTagData(
                        label: tag,
                        color: const Color(0xFFDF6EB8),
                      ),
                    )
                    .where((tag) => tag.label.trim().isNotEmpty)
                    .toList(growable: false),
              ),
            ]
          : const <TagFilterGroup>[];

      return _GlassFilterDialog(
        initial: initial,
        availableTagGroups: tagGroups,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
  );
}

Future<ContentSortState?> showContentSortMenu({
  required BuildContext context,
  required ContentSortState initial,
  bool includeCharacterCount = true,
}) {
  return showGeneralDialog<ContentSortState>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Ordenação',
    barrierColor: Colors.black.withValues(alpha: 0.12),
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _GlassSortDialog(
        initial: initial,
        includeCharacterCount: includeCharacterCount,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
  );
}

class _GlassFilterDialog extends StatefulWidget {
  final ContentFilterState initial;
  final List<TagFilterGroup> availableTagGroups;

  const _GlassFilterDialog({
    required this.initial,
    required this.availableTagGroups,
  });

  @override
  State<_GlassFilterDialog> createState() => _GlassFilterDialogState();
}

class _GlassFilterDialogState extends State<_GlassFilterDialog> {
  late final TextEditingController _searchController;
  late ContentFilterMatchMode _mode;
  late bool _inverted;
  late final Map<String, String> _selectedTagsByNormalized;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _mode = widget.initial.matchMode;
    _inverted = widget.initial.inverted;
    _selectedTagsByNormalized = <String, String>{
      for (final term in widget.initial.tagQuery.split(RegExp(r'[,;\n]')))
        if (term.trim().isNotEmpty) normalizeSearchText(term): term.trim(),
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      final normalized = normalizeSearchText(tag);
      if (normalized.isEmpty) return;
      if (_selectedTagsByNormalized.containsKey(normalized)) {
        _selectedTagsByNormalized.remove(normalized);
      } else {
        _selectedTagsByNormalized[normalized] = tag;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = normalizeSearchText(_searchController.text);
    final selectedTagsList = _selectedTagsByNormalized.values.toList(
      growable: false,
    )..sort();
    final tagQueryString = selectedTagsList.join(', ');
    final visibleGroups = widget.availableTagGroups
        .map((group) {
          final filteredTags = group.tags
              .where((tag) {
                final normalized = normalizeSearchText(tag.label);
                if (normalized.isEmpty ||
                    _selectedTagsByNormalized.containsKey(normalized)) {
                  return false;
                }
                if (query.isEmpty) return true;
                return normalizeSearchText(group.title).contains(query) ||
                    normalized.contains(query);
              })
              .toList(growable: false);
          return TagFilterGroup(
            title: group.title,
            color: group.color,
            icon: group.icon,
            tags: filteredTags,
          );
        })
        .where((group) => group.tags.isNotEmpty)
        .toList(growable: false);

    return _GlassMenuFrame(
      title: 'Filtros',
      icon: Icons.filter_alt_outlined,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search field
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: _glassInputDecoration('Procurar por tag'),
          ),
          if (_selectedTagsByNormalized.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final tag in selectedTagsList)
                  _GlassChip(
                    label: tag,
                    selected: true,
                    onTap: () => _toggleTag(tag),
                    showRemove: true,
                  ),
              ],
            ),
          ],
          if (visibleGroups.isNotEmpty) ...[
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final group in visibleGroups) ...[
                  _TagFilterGroupSection(
                    group: group,
                    isTagSelected: (label) => _selectedTagsByNormalized
                        .containsKey(normalizeSearchText(label)),
                    onTagTap: _toggleTag,
                    initiallyExpanded:
                        query.isNotEmpty ||
                        group.tags.any(
                          (tag) => _selectedTagsByNormalized.containsKey(
                            normalizeSearchText(tag.label),
                          ),
                        ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ],
          if (_searchController.text.isNotEmpty &&
              visibleGroups.isEmpty &&
              _selectedTagsByNormalized.isNotEmpty) ...[
            const SizedBox(height: 6),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final mode in ContentFilterMatchMode.values)
                _GlassChip(
                  label: contentFilterModeLabel(mode),
                  selected: _mode == mode,
                  onTap: () => setState(() => _mode = mode),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            value: _inverted,
            onChanged: (value) => setState(() => _inverted = value),
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Inverter lógica',
              style: TextStyle(
                color: Color(0xFF3A3339),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDF6EB8),
                    side: const BorderSide(
                      color: Color(0xFFDF6EB8),
                      width: 1.2,
                    ),
                  ),
                  onPressed: () =>
                      Navigator.of(context).pop(const ContentFilterState()),
                  child: const Text('Limpar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFDF6EB8),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(
                    ContentFilterState(
                      tagQuery: tagQueryString,
                      matchMode: _mode,
                      inverted: _inverted,
                    ),
                  ),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagFilterGroupSection extends StatefulWidget {
  final TagFilterGroup group;
  final bool Function(String label) isTagSelected;
  final ValueChanged<String> onTagTap;
  final bool initiallyExpanded;

  const _TagFilterGroupSection({
    required this.group,
    required this.isTagSelected,
    required this.onTagTap,
    required this.initiallyExpanded,
  });

  @override
  State<_TagFilterGroupSection> createState() => _TagFilterGroupSectionState();
}

class _TagFilterGroupSectionState extends State<_TagFilterGroupSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant _TagFilterGroupSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initiallyExpanded && !_isExpanded) {
      _isExpanded = true;
    }
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = widget.group.color;
    final tags = widget.group.tags;

    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: headerColor.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _toggleExpanded,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    if (widget.group.icon != null) ...[
                      Icon(widget.group.icon, size: 13, color: headerColor),
                      const SizedBox(width: 5),
                    ],
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: headerColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.group.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _darkenColor(headerColor, 0.18),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      tags.length.toString(),
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.42),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: Colors.black.withValues(alpha: 0.42),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 160),
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in tags)
                    _GlassChip(
                      label: tag.label,
                      selected: widget.isTagSelected(tag.label),
                      onTap: () => widget.onTagTap(tag.label),
                    ),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }
}

Color _darkenColor(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

class _GlassSortDialog extends StatefulWidget {
  final ContentSortState initial;
  final bool includeCharacterCount;

  const _GlassSortDialog({
    required this.initial,
    required this.includeCharacterCount,
  });

  @override
  State<_GlassSortDialog> createState() => _GlassSortDialogState();
}

class _GlassSortDialogState extends State<_GlassSortDialog> {
  late ContentSortMode _mode;
  late bool _reversed;

  @override
  void initState() {
    super.initState();
    _mode = widget.initial.mode;
    _reversed = widget.initial.reversed;
  }

  @override
  Widget build(BuildContext context) {
    final modes = [
      ContentSortMode.lastAccessed,
      ContentSortMode.lastModified,
      ContentSortMode.createdAt,
      ContentSortMode.title,
      ContentSortMode.synopsisLength,
      if (widget.includeCharacterCount) ContentSortMode.characterCount,
    ];

    return _GlassMenuFrame(
      title: 'Ordenação',
      icon: Icons.swap_vert_rounded,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final mode in modes)
                _GlassChip(
                  label: contentSortModeLabel(mode),
                  selected: _mode == mode,
                  onTap: () => setState(() => _mode = mode),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SwitchListTile.adaptive(
            value: _reversed,
            onChanged: (value) => setState(() => _reversed = value),
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Inverter lógica',
              style: TextStyle(
                color: Color(0xFF3A3339),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDF6EB8),
                    side: const BorderSide(
                      color: Color(0xFFDF6EB8),
                      width: 1.2,
                    ),
                  ),
                  onPressed: () =>
                      Navigator.of(context).pop(const ContentSortState()),
                  child: const Text('Padrão'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFDF6EB8),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(ContentSortState(mode: _mode, reversed: _reversed)),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassMenuFrame extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _GlassMenuFrame({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.54),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFDF6EB8).withValues(alpha: 0.42),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDF6EB8).withValues(alpha: 0.22),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 18, color: const Color(0xFFDF6EB8)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Color(0xFF2B262C),
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: const Color(0xFFDF6EB8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool showRemove;

  const _GlassChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.showRemove = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: showRemove ? 6 : 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFDF6EB8).withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.56),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? const Color(0xFFDF6EB8).withValues(alpha: 0.34)
                  : Colors.white.withValues(alpha: 0.78),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF8A3E67)
                      : const Color(0xFF514752),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (showRemove) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: selected
                      ? const Color(0xFF8A3E67)
                      : const Color(0xFF514752),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _glassInputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    isDense: true,
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.62),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.74)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.74)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFDF6EB8), width: 1.1),
    ),
  );
}

class FuncoesBusca extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onSortTap;
  final VoidCallback? onMagicTap;
  final String hintText;
  final bool filterActive;
  final bool sortActive;

  const FuncoesBusca({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.onSortTap,
    this.onMagicTap,
    this.hintText = 'Pesquisar',
    this.filterActive = false,
    this.sortActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: 46,
          padding: const EdgeInsets.fromLTRB(14, 5, 14, 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFFFFFFF).withValues(alpha: 0.72),
                const Color(0xFFF3F0F3).withValues(alpha: 0.62),
              ],
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.52)),
              bottom: BorderSide(color: Colors.black.withValues(alpha: 0.045)),
            ),
          ),
          child: Row(
            children: [
              _ActionIcon(
                icon: Icons.filter_alt_outlined,
                onTap: onFilterTap,
                isActive: filterActive,
              ),
              const SizedBox(width: 10),
              _ActionIcon(
                icon: Icons.swap_vert_rounded,
                onTap: onSortTap,
                isActive: sortActive,
              ),
              const SizedBox(width: 10),
              _ActionIcon(
                icon: Icons.auto_awesome_outlined,
                onTap:
                    onMagicTap ??
                    () => Navigator.of(context).pushNamed("/chatbot"),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SearchField(
                  controller: controller,
                  onChanged: onChanged,
                  hintText: hintText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.hintText,
  });

  static const List<double> _desaturateMatrix = <double>[
    0.65,
    0.25,
    0.10,
    0,
    0,
    0.20,
    0.65,
    0.15,
    0,
    0,
    0.16,
    0.24,
    0.60,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(_desaturateMatrix),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7D7DC).withValues(alpha: 0.18),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF9F9FB).withValues(alpha: 0.54),
                        const Color(0xFFE2E2E7).withValues(alpha: 0.38),
                        const Color(0xFFFFFFFF).withValues(alpha: 0.22),
                      ],
                      stops: const [0, 0.46, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  transform: GradientRotation(-math.pi / 5.9),
                  colors: [
                    const Color(0x00FFFFFF),
                    const Color(0x92A9AAB2),
                    const Color(0x45D0D1D7),
                    const Color(0x00FFFFFF),
                  ],
                  stops: const [0.04, 0.24, 0.43, 0.7],
                ),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.34),
                    Colors.white.withValues(alpha: 0.04),
                    Colors.white.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.34, 1],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.86),
                  width: 1.15,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          TextField(
            controller: controller,
            onChanged: onChanged,
            readOnly: onChanged == null,
            enableInteractiveSelection: onChanged != null,
            cursorColor: const Color(0xFF6E6870),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.black.withValues(alpha: 0.42),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              isDense: true,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 42,
                minHeight: 34,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.search_rounded,
                  color: Colors.black.withValues(alpha: 0.9),
                  size: 29,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isActive;

  const _ActionIcon({required this.icon, this.onTap, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      radius: 20,
      onTap: onTap,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Center(
          child: Icon(
            icon,
            color: isActive ? const Color(0xFFDF6EB8) : const Color(0xFF151419),
            size: 28,
          ),
        ),
      ),
    );
  }
}
