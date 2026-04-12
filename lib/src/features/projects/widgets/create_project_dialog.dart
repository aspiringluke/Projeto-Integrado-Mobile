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
  final List<String> tagLabels;
  final Color coverColor;
  final Color accentColor;

  const CreateProjectTextDraft({
    required this.title,
    required this.synopsis,
    required this.tagLabels,
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

class _CreateProjectDialogState extends State<_CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _synopsisController;
  late final TextEditingController _newTagController;
  late final ScrollController _contentScrollController;
  late final ScrollController _synopsisScrollController;
  late List<ProjectTagData> _knownTags;
  final Set<String> _selectedTags = <String>{};
  HSLColor _coverColor = HSLColor.fromColor(defaultProjectCoverColor);
  HSLColor _accentColor = HSLColor.fromColor(defaultProjectAccentColor);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _synopsisController = TextEditingController();
    _newTagController = TextEditingController();
    _contentScrollController = ScrollController();
    _synopsisScrollController = ScrollController();
    _knownTags = List<ProjectTagData>.from(widget.availableTags);
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
          color: projectTagColorAt(_knownTags.length),
        );

        _knownTags = <ProjectTagData>[..._knownTags, newTag];
        _selectedTags.add(newTag.normalizedLabel);
      }

      _newTagController.clear();
    });
  }

  void _submit() {
    if (_newTagController.text.trim().isNotEmpty) {
      _addTagFromInput();
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final selectedTagLabels = _knownTags
        .where((tag) => _selectedTags.contains(tag.normalizedLabel))
        .map((tag) => tag.label)
        .toList(growable: false);

    Navigator.of(context).pop(
      CreateProjectTextDraft(
        title: _titleController.text.trim(),
        synopsis: _synopsisController.text.trim(),
        tagLabels: selectedTagLabels,
        coverColor: _coverColor.toColor(),
        accentColor: _accentColor.toColor(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.sizeOf(context).height - 48,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.98),
                const Color(0xFFF7EBF2).withValues(alpha: 0.96),
                const Color(0xFFF0D9E7).withValues(alpha: 0.92),
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
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
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
                    contentPadding: const EdgeInsets.only(right: 10),
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
                                    fontSize: 20,
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
                            'Nome, sinopse, tags e aparencia inicial do projeto.',
                            style: TextStyle(
                              color: Color(0xFF6A6167),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Nome do projeto *',
                            style: TextStyle(
                              color: Color(0xFF3A3339),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            textInputAction: TextInputAction.next,
                            decoration: _buildInputDecoration(
                              hintText: 'Ex.: Reino partido',
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
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          EditableSynopsisPanel(
                            controller: _synopsisController,
                            scrollController: _synopsisScrollController,
                            isEditing: true,
                            placeholderText:
                                'Opcional. Use este campo para resumir a historia.',
                            textStyle: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF3A3339),
                              height: 1.4,
                            ),
                            height: 72,
                            panelPadding: const EdgeInsets.fromLTRB(
                              12,
                              10,
                              12,
                              10,
                            ),
                            scrollPadding: const EdgeInsets.only(right: 10),
                            fillColor: Colors.white.withValues(alpha: 0.52),
                            backgroundGradient: null,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            viewerBuilder: (context, text, style) {
                              return Text(text, style: style);
                            },
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Tags',
                                  style: TextStyle(
                                    color: Color(0xFF3A3339),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_knownTags.isEmpty)
                            _InfoSurface(
                              child: const Text(
                                'Nenhuma tag cadastrada ainda. Crie a primeira abaixo se quiser.',
                                style: TextStyle(
                                  color: Color(0xFF6A6167),
                                  fontSize: 12,
                                  height: 1.4,
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
                                    hintText: 'Adicionar tag',
                                  ),
                                  onFieldSubmitted: (_) => _addTagFromInput(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 44,
                                child: FilledButton(
                                  onPressed: _addTagFromInput,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFDF6EB8),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                  child: const Icon(Icons.add_rounded, size: 22),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ProjectColorEditor(
                            title: 'Cor da capa',
                            description: 'Preenche o topo do cartao colapsado.',
                            color: _coverColor.toColor(),
                            hslColor: _coverColor,
                            useSolidCoverPreview: true,
                            onHueChanged: (value) {
                              setState(() {
                                _coverColor = _coverColor.withHue(value);
                              });
                            },
                            onSaturationChanged: (value) {
                              setState(() {
                                _coverColor = _coverColor.withSaturation(value);
                              });
                            },
                            onLightnessChanged: (value) {
                              setState(() {
                                _coverColor = _coverColor.withLightness(value);
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          ProjectColorEditor(
                            title: 'Cor de realce',
                            description: 'Aplica a base cromatica do cartao.',
                            color: _accentColor.toColor(),
                            hslColor: _accentColor,
                            onHueChanged: (value) {
                              setState(() {
                                _accentColor = _accentColor.withHue(value);
                              });
                            },
                            onSaturationChanged: (value) {
                              setState(() {
                                _accentColor = _accentColor.withSaturation(
                                  value,
                                );
                              });
                            },
                            onLightnessChanged: (value) {
                              setState(() {
                                _accentColor = _accentColor.withLightness(
                                  value,
                                );
                              });
                            },
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF514752),
                                    side: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFDF6EB8),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
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
      hintStyle: const TextStyle(color: Color(0xFF8E838B), fontSize: 13),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.52),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.56)),
      ),
      child: child,
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
    return Material(
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
              Text(
                tag.label,
                style: TextStyle(
                  color: tag.color.withValues(alpha: 0.98),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
