import 'package:flutter/material.dart';

import '../../../shared/widgets/synopsis_scroll_box.dart';
import '../models/project_style_defaults.dart';
import '../models/project_tag_data.dart';
import 'project_color_editor.dart';

Future<CreateProjectTextDraft?> showCreateProjectTextDialog(
  BuildContext context, {
  required List<ProjectTagData> availableTags,
}) {
  return showDialog<CreateProjectTextDraft>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _CreateProjectDialog(availableTags: availableTags),
  );
}

class CreateProjectTextDraft {
  final String title;
  final String synopsis;
  final List<ProjectTagData> tags;
  final Color coverColor;
  final Color accentColor;

  const CreateProjectTextDraft({
    required this.title,
    required this.synopsis,
    required this.tags,
    required this.coverColor,
    required this.accentColor,
  });
}

class _CreateProjectDialog extends StatefulWidget {
  final List<ProjectTagData> availableTags;

  const _CreateProjectDialog({required this.availableTags});

  @override
  State<_CreateProjectDialog> createState() => _CreateProjectDialogState();
}

enum _ProjectColorTarget { cover, accent }

class _CreateProjectDialogState extends State<_CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _synopsisController;
  late final TextEditingController _newTagController;
  late final ScrollController _contentScrollController;
  late final ScrollController _synopsisScrollController;
  late List<ProjectTagData> _knownTags;
  final Set<String> _selectedTags = <String>{};
  late Color _newTagColor;
  HSLColor _coverColor = HSLColor.fromColor(defaultProjectCoverColor);
  HSLColor _accentColor = HSLColor.fromColor(defaultProjectAccentColor);
  _ProjectColorTarget _activeColorTarget = _ProjectColorTarget.accent;

  Color get _defaultNewTagColor => projectTagColorAt(_knownTags.length);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _synopsisController = TextEditingController();
    _newTagController = TextEditingController();
    _contentScrollController = ScrollController();
    _synopsisScrollController = ScrollController();
    _knownTags = List<ProjectTagData>.from(widget.availableTags);
    _newTagColor = _defaultNewTagColor;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _synopsisController.dispose();
    _newTagController.dispose();
    _contentScrollController.dispose();
    _synopsisScrollController.dispose();
    super.dispose();
  }

  void _toggleTag(ProjectTagData tag) {
    final normalizedLabel = tag.normalizedLabel;

    setState(() {
      if (_selectedTags.contains(normalizedLabel)) {
        _selectedTags.remove(normalizedLabel);
      } else {
        _selectedTags.add(normalizedLabel);
      }
    });
  }

  void _addTagFromInput() {
    final sanitizedLabel = sanitizeProjectTagLabel(_newTagController.text);
    final normalizedLabel = normalizeProjectTagLabel(_newTagController.text);
    if (normalizedLabel.isEmpty) return;

    final existingIndex = _knownTags.indexWhere(
      (tag) => tag.normalizedLabel == normalizedLabel,
    );

    setState(() {
      if (existingIndex != -1) {
        _selectedTags.add(normalizedLabel);
      } else {
        final newTag = ProjectTagData(
          label: sanitizedLabel,
          color: _newTagColor,
        );

        _knownTags = <ProjectTagData>[..._knownTags, newTag];
        _selectedTags.add(newTag.normalizedLabel);
      }

      _newTagController.clear();
      _newTagColor = _defaultNewTagColor;
    });
  }

  void _submit() {
    if (_newTagController.text.trim().isNotEmpty) {
      _addTagFromInput();
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final selectedTags = _knownTags
        .where((tag) => _selectedTags.contains(tag.normalizedLabel))
        .toList(growable: false);

    Navigator.of(context).pop(
      CreateProjectTextDraft(
        title: _titleController.text.trim(),
        synopsis: _synopsisController.text.trim(),
        tags: selectedTags,
        coverColor: _coverColor.toColor(),
        accentColor: _accentColor.toColor(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 470,
            maxHeight: MediaQuery.sizeOf(context).height - 48,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.98),
                const Color(0xFFF9EEF4).withValues(alpha: 0.97),
                const Color(0xFFF1DCE8).withValues(alpha: 0.93),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final viewportHeight = constraints.hasBoundedHeight
                    ? constraints.maxHeight
                    : MediaQuery.sizeOf(context).height - 96;

                return Form(
                  key: _formKey,
                  child: SynopsisScrollBox(
                    controller: _contentScrollController,
                    childIsScrollable: true,
                    height: viewportHeight,
                    contentPadding: const EdgeInsets.only(right: 8),
                    child: SingleChildScrollView(
                      controller: _contentScrollController,
                      physics: const BouncingScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Novo projeto',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2C262C),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close_rounded),
                                color: const Color(0xFF544959),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Base rapida, tags e identidade visual.',
                            style: TextStyle(
                              color: Color(0xFF6A6167),
                              fontSize: 11.5,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Nome do projeto *',
                            style: TextStyle(
                              color: Color(0xFF3A3339),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _titleController,
                            textInputAction: TextInputAction.next,
                            decoration: _buildInputDecoration(
                              hintText: 'Nome do projeto',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe um nome para o projeto.';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Sinopse',
                            style: TextStyle(
                              color: Color(0xFF3A3339),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          EditableSynopsisPanel(
                            controller: _synopsisController,
                            scrollController: _synopsisScrollController,
                            isEditing: true,
                            placeholderText:
                                'Sintese opcional para resumir a historia.',
                            textStyle: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF3A3339),
                              height: 1.35,
                            ),
                            height: 66,
                            panelPadding: const EdgeInsets.fromLTRB(
                              12,
                              9,
                              12,
                              9,
                            ),
                            scrollPadding: const EdgeInsets.only(right: 8),
                            fillColor: Colors.white.withValues(alpha: 0.56),
                            backgroundGradient: null,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.74),
                            ),
                            viewerBuilder: (context, text, style) {
                              return Text(text, style: style);
                            },
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'Tags',
                                style: TextStyle(
                                  color: Color(0xFF3A3339),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'nova cor opcional',
                                style: TextStyle(
                                  color: const Color(0xFF6A6167).withValues(
                                    alpha: 0.88,
                                  ),
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_knownTags.isEmpty)
                            _InfoSurface(
                              child: const Text(
                                'Nenhuma tag cadastrada ainda.',
                                style: TextStyle(
                                  color: Color(0xFF6A6167),
                                  fontSize: 12,
                                ),
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final tag in _knownTags)
                                  _SelectableTagChip(
                                    tag: tag,
                                    isSelected: _selectedTags.contains(
                                      tag.normalizedLabel,
                                    ),
                                    onTap: () => _toggleTag(tag),
                                  ),
                              ],
                            ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _newTagController,
                                  textInputAction: TextInputAction.done,
                                  decoration: _buildInputDecoration(
                                    hintText: 'Nova tag',
                                  ),
                                  onChanged: (_) => setState(() {}),
                                  onFieldSubmitted: (_) => _addTagFromInput(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 44,
                                child: FilledButton(
                                  onPressed: _addTagFromInput,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFDF6EB8),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                  ),
                                  child: const Icon(Icons.add_rounded, size: 20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _DraftTagPreview(
                                label: _newTagController.text.trim().isEmpty
                                    ? 'Nova tag'
                                    : sanitizeProjectTagLabel(
                                        _newTagController.text,
                                      ),
                                color: _newTagColor,
                              ),
                              for (final color in projectTagPalette)
                                _TagColorSwatch(
                                  color: color,
                                  isSelected: color == _newTagColor,
                                  onTap: () {
                                    setState(() {
                                      _newTagColor = color;
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _ColorTargetChip(
                                  label: 'Capa',
                                  color: _coverColor.toColor(),
                                  isSelected:
                                      _activeColorTarget ==
                                      _ProjectColorTarget.cover,
                                  onTap: () {
                                    setState(() {
                                      _activeColorTarget =
                                          _ProjectColorTarget.cover;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ColorTargetChip(
                                  label: 'Realce',
                                  color: _accentColor.toColor(),
                                  isSelected:
                                      _activeColorTarget ==
                                      _ProjectColorTarget.accent,
                                  onTap: () {
                                    setState(() {
                                      _activeColorTarget =
                                          _ProjectColorTarget.accent;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ProjectColorEditor(
                            title: _activeColorTarget == _ProjectColorTarget.cover
                                ? 'Cor da capa'
                                : 'Cor de realce',
                            description:
                                _activeColorTarget == _ProjectColorTarget.cover
                                ? 'Preenche o topo do cartao.'
                                : 'Aplica a base cromatica do cartao.',
                            color: _activeColorTarget == _ProjectColorTarget.cover
                                ? _coverColor.toColor()
                                : _accentColor.toColor(),
                            hslColor:
                                _activeColorTarget == _ProjectColorTarget.cover
                                ? _coverColor
                                : _accentColor,
                            useSolidCoverPreview:
                                _activeColorTarget == _ProjectColorTarget.cover,
                            onHueChanged: (value) {
                              setState(() {
                                if (_activeColorTarget ==
                                    _ProjectColorTarget.cover) {
                                  _coverColor = _coverColor.withHue(value);
                                } else {
                                  _accentColor = _accentColor.withHue(value);
                                }
                              });
                            },
                            onSaturationChanged: (value) {
                              setState(() {
                                if (_activeColorTarget ==
                                    _ProjectColorTarget.cover) {
                                  _coverColor = _coverColor.withSaturation(value);
                                } else {
                                  _accentColor = _accentColor.withSaturation(
                                    value,
                                  );
                                }
                              });
                            },
                            onLightnessChanged: (value) {
                              setState(() {
                                if (_activeColorTarget ==
                                    _ProjectColorTarget.cover) {
                                  _coverColor = _coverColor.withLightness(value);
                                } else {
                                  _accentColor = _accentColor.withLightness(
                                    value,
                                  );
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF514752),
                                    side: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.82,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFDF6EB8),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text('Criar projeto'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hintText}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
    );

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF8E838B), fontSize: 12.5),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.56),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: Color(0xFFDF6EB8), width: 1.1),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: Color(0xFFC96775), width: 1),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: Color(0xFFC96775), width: 1),
      ),
    );
  }
}

class _InfoSurface extends StatelessWidget {
  final Widget child;

  const _InfoSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.56)),
      ),
      child: child,
    );
  }
}

class _DraftTagPreview extends StatelessWidget {
  final String label;
  final Color color;

  const _DraftTagPreview({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : double.infinity;

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: color.withValues(alpha: 0.92)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.98),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TagColorSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

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
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2C262C)
                  : Colors.white.withValues(alpha: 0.88),
              width: isSelected ? 2.0 : 1.15,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isSelected ? 0.34 : 0.16),
                blurRadius: isSelected ? 10 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isSelected
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

class _ColorTargetChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorTargetChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.34),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.92)
                  : Colors.white.withValues(alpha: 0.72),
              width: isSelected ? 1.1 : 0.9,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: const Color(0xFF3A3339).withValues(
                      alpha: isSelected ? 1 : 0.72,
                    ),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectableTagChip extends StatelessWidget {
  final ProjectTagData tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableTagChip({
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : double.infinity;

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? tag.color.withValues(alpha: 0.16)
                      : Colors.white.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: tag.color.withValues(alpha: isSelected ? 0.98 : 0.78),
                    width: isSelected ? 1.2 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(Icons.check_rounded, size: 15, color: tag.color),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        tag.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                          color: tag.color.withValues(alpha: 0.98),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
