part of '../create_character_dialog.dart';

class _RelevanceScoreSummary extends StatelessWidget {
  final double score;
  final _RelevanceCategoryConfig category;
  final List<_RelevanceCategoryConfig> categories;
  final Color accentColor;
  final ValueChanged<double>? onScoreChanged;

  const _RelevanceScoreSummary({
    required this.score,
    required this.category,
    required this.categories,
    required this.accentColor,
    this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = onScoreChanged != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: category.color.withValues(alpha: 0.42)),
            ),
            child: Center(
              child: Text(
                score.toStringAsFixed(1),
                style: TextStyle(
                  color: _darkenCharacterDialogColor(category.color, 0.16),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    color: _darkenCharacterDialogColor(category.color, 0.2),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                if (isInteractive)
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: category.color,
                      inactiveTrackColor: category.color.withValues(
                        alpha: 0.18,
                      ),
                      thumbColor: const Color(0xFF2C262C),
                      overlayColor: category.color.withValues(alpha: 0.12),
                      trackHeight: 9,
                    ),
                    child: Slider(
                      value: score.clamp(0.0, 10.0).toDouble(),
                      min: 0,
                      max: 10,
                      divisions: 100,
                      label: score.toStringAsFixed(1),
                      onChanged: onScoreChanged,
                    ),
                  )
                else
                  _RelevanceSpectrumBar(score: score, categories: categories),
                const SizedBox(height: 7),
                Text(
                  category.description,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.58),
                    fontSize: 11.2,
                    height: 1.2,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${category.min.toStringAsFixed(1)}-${category.max.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: _darkenCharacterDialogColor(category.color, 0.18),
                      fontSize: 10.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelevanceSpectrumBar extends StatelessWidget {
  final double score;
  final List<_RelevanceCategoryConfig> categories;
  final bool compact;

  const _RelevanceSpectrumBar({
    required this.score,
    required this.categories,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final markerWidth = compact ? 8.0 : 12.0;
        final markerHeight = compact ? 14.0 : 20.0;
        final markerLeft =
            (constraints.maxWidth - markerWidth) * (score.clamp(0, 10) / 10);

        return SizedBox(
          height: compact ? 16 : 24,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                top: compact ? 5 : 6,
                bottom: compact ? 5 : 6,
                child: Row(
                  children: [
                    for (final category in categories)
                      Expanded(
                        flex: ((category.max - category.min) * 10).round(),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: category.color.withValues(alpha: 0.62),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                left: markerLeft,
                top: compact ? 1 : 2,
                child: Container(
                  width: markerWidth,
                  height: markerHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C262C),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.88),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RelevanceFormulaNote extends StatelessWidget {
  final Color accentColor;

  const _RelevanceFormulaNote({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Text(
        'Pense em conceitos capazes de fazer um personagem ser importante na sua história e atribua a eles um peso e um valor, determinando em que setores exatamente um personagem é importante. O modelo abaixo é uma base genérica.',
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.56),
          fontSize: 10.4,
          height: 1.22,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _RelevanceEditorToolbar extends StatelessWidget {
  final _RelevanceEditorMode mode;
  final ValueChanged<_RelevanceEditorMode> onModeChanged;
  final VoidCallback onReset;

  const _RelevanceEditorToolbar({
    required this.mode,
    required this.onModeChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RelevanceModeToggle(mode: mode, onModeChanged: onModeChanged),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.restart_alt_rounded, size: 17),
          label: const Text('Padrão'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF514752),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        ),
      ],
    );
  }
}

class _RelevanceModeToggle extends StatelessWidget {
  final _RelevanceEditorMode mode;
  final ValueChanged<_RelevanceEditorMode> onModeChanged;

  const _RelevanceModeToggle({required this.mode, required this.onModeChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RelevanceModeToggleButton(
              label: 'Simples',
              selected: mode == _RelevanceEditorMode.simple,
              onTap: () => onModeChanged(_RelevanceEditorMode.simple),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _RelevanceModeToggleButton(
              label: 'Avançado',
              selected: mode == _RelevanceEditorMode.advanced,
              onTap: () => onModeChanged(_RelevanceEditorMode.advanced),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelevanceModeToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RelevanceModeToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFDF6EB8);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: selected
                ? Border.all(color: accent.withValues(alpha: 0.3))
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? _darkenCharacterDialogColor(accent, 0.18)
                  : const Color(0xFF514752),
              fontSize: 11.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddRelevanceParameterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddRelevanceParameterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const projectPink = Color(0xFFDF6EB8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: double.infinity,
          height: 42,
          decoration: BoxDecoration(
            color: projectPink.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: projectPink.withValues(alpha: 0.28)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                size: 18,
                color: _darkenCharacterDialogColor(projectPink, 0.18),
              ),
              const SizedBox(width: 6),
              Text(
                'Adicionar parametro',
                style: TextStyle(
                  color: _darkenCharacterDialogColor(projectPink, 0.18),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelevanceParameterIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RelevanceParameterIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = enabled ? const Color(0xFF7D6171) : const Color(0xFFB9AFB6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 26,
          height: 26,
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}

class _RelevanceParameterControl extends StatefulWidget {
  final _RelevanceParameterConfig parameter;
  final double value;
  final double weight;
  final bool canRemove;
  final bool canResetToDefault;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onResetToDefault;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<double> onValueChanged;
  final ValueChanged<double> onWeightChanged;

  const _RelevanceParameterControl({
    required this.parameter,
    required this.value,
    required this.weight,
    required this.canRemove,
    required this.canResetToDefault,
    required this.isEditing,
    required this.onEdit,
    required this.onRemove,
    required this.onResetToDefault,
    required this.onNameChanged,
    required this.onDescriptionChanged,
    required this.onValueChanged,
    required this.onWeightChanged,
  });

  @override
  State<_RelevanceParameterControl> createState() =>
      _RelevanceParameterControlState();
}

class _RelevanceParameterControlState
    extends State<_RelevanceParameterControl> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _descriptionFocusNode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.parameter.name);
    _descriptionController = TextEditingController(
      text: widget.parameter.description,
    );
    _nameFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _RelevanceParameterControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parameter.name != widget.parameter.name &&
        !_nameFocusNode.hasFocus) {
      _nameController.text = widget.parameter.name;
      _nameController.selection = TextSelection.collapsed(
        offset: widget.parameter.name.length,
      );
    }
    if (oldWidget.parameter.description != widget.parameter.description &&
        !_descriptionFocusNode.hasFocus) {
      _descriptionController.text = widget.parameter.description;
      _descriptionController.selection = TextSelection.collapsed(
        offset: widget.parameter.description.length,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const projectPink = Color(0xFFDF6EB8);
    final sliderTheme = SliderTheme.of(context).copyWith(
      activeTrackColor: projectPink,
      inactiveTrackColor: projectPink.withValues(alpha: 0.18),
      activeTickMarkColor: Colors.white.withValues(alpha: 0.42),
      inactiveTickMarkColor: projectPink.withValues(alpha: 0.28),
      thumbColor: projectPink,
      overlayColor: projectPink.withValues(alpha: 0.14),
      valueIndicatorColor: projectPink,
      trackHeight: 5,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(9, 8, 9, 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useStackedHeader = constraints.maxWidth < 340;
          final symbolBadge = Container(
            width: 32,
            height: 24,
            decoration: BoxDecoration(
              color: projectPink.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                _relevanceMonogram(
                  widget.parameter.name,
                  fallback: widget.parameter.symbol,
                ),
                style: TextStyle(
                  color: _darkenCharacterDialogColor(projectPink, 0.18),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );
          final nameField = widget.isEditing
              ? TextField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  minLines: 1,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF3A3339),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: widget.onNameChanged,
                )
              : Text(
                  widget.parameter.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF3A3339),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                );
          final actions = Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              Text(
                widget.value.toStringAsFixed(1),
                style: const TextStyle(
                  color: Color(0xFF514752),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              _RelevanceParameterIconButton(
                icon: widget.isEditing
                    ? Icons.check_rounded
                    : Icons.edit_rounded,
                onTap: widget.onEdit,
              ),
              _RelevanceParameterIconButton(
                icon: Icons.restart_alt_rounded,
                onTap: widget.canResetToDefault
                    ? widget.onResetToDefault
                    : null,
              ),
              _RelevanceParameterIconButton(
                icon: Icons.delete_outline_rounded,
                onTap: widget.canRemove ? widget.onRemove : null,
              ),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (useStackedHeader)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        symbolBadge,
                        const SizedBox(width: 8),
                        Expanded(child: nameField),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                )
              else
                Row(
                  children: [
                    symbolBadge,
                    const SizedBox(width: 8),
                    Expanded(child: nameField),
                    const SizedBox(width: 8),
                    actions,
                  ],
                ),
              const SizedBox(height: 4),
              widget.isEditing
                  ? TextField(
                      controller: _descriptionController,
                      focusNode: _descriptionFocusNode,
                      minLines: 2,
                      maxLines: 3,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.54),
                        fontSize: 10.2,
                        height: 1.22,
                        fontStyle: FontStyle.italic,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: widget.onDescriptionChanged,
                    )
                  : Text(
                      widget.parameter.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.54),
                        fontSize: 10.2,
                        height: 1.22,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
              const SizedBox(height: 2),
              SliderTheme(
                data: sliderTheme,
                child: Slider(
                  value: widget.value.clamp(0, 10),
                  min: 0,
                  max: 10,
                  divisions: 20,
                  onChanged: widget.onValueChanged,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Peso',
                    style: TextStyle(
                      color: Color(0xFF6A6167),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: sliderTheme,
                      child: Slider(
                        value: widget.weight.clamp(0, 1),
                        min: 0,
                        max: 1,
                        divisions: 20,
                        onChanged: widget.onWeightChanged,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 38,
                    child: Text(
                      '${(widget.weight * 100).toStringAsFixed(0)}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF6A6167),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
