part of '../character_notebook_page.dart';

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = Colors.white.withValues(alpha: 0.98);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.52),
          width: 0.9,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.2),
            color.withValues(alpha: 0.5),
            color.withValues(alpha: 0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsibleSection extends StatefulWidget {
  final Color accentColor;
  final Color leadingIconColor;
  final String title;
  final String subtitle;
  final List<String>? fields;
  final IconData icon;
  final Widget child;

  const _CollapsibleSection({
    required this.accentColor,
    required this.leadingIconColor,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.fields,
  });

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.88),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black,
                      Colors.black,
                      Colors.black.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.75, 1.0],
                  ).createShader(bounds);
                },
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 17,
                        color: widget.leadingIconColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Color(0xFF2C262C),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (widget.fields != null &&
                              widget.fields!.isNotEmpty)
                            Text(
                              widget.fields!.map((f) => '\u2022 $f').join('  '),
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.48),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          else
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.45),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.black.withValues(alpha: 0.58),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: widget.child,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _NotebookTextFieldCard extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final String label;
  final String placeholderText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int minLines;
  final int? maxLines;

  const _NotebookTextFieldCard({
    required this.accentColor,
    required this.icon,
    required this.label,
    required this.placeholderText,
    required this.controller,
    required this.onChanged,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      color: Color(0xFF544959),
      fontSize: 12.5,
      height: 1.35,
    );
    const placeholderStyle = TextStyle(
      color: Color(0xFF8F8990),
      fontSize: 11,
      height: 1.35,
      fontStyle: FontStyle.italic,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.16),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 15, color: const Color(0xFF544959)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2C262C),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _NotebookDynamicTextFieldPanel(
            accentColor: accentColor,
            placeholderText: placeholderText,
            controller: controller,
            onChanged: onChanged,
            minLines: minLines,
            maxLines: maxLines,
            textStyle: textStyle,
            placeholderStyle: placeholderStyle,
          ),
        ],
      ),
    );
  }
}

class _NotebookDynamicTextFieldPanel extends StatefulWidget {
  final Color accentColor;
  final String placeholderText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int minLines;
  final int? maxLines;
  final TextStyle textStyle;
  final TextStyle placeholderStyle;

  const _NotebookDynamicTextFieldPanel({
    required this.accentColor,
    required this.placeholderText,
    required this.controller,
    required this.onChanged,
    required this.minLines,
    required this.maxLines,
    required this.textStyle,
    required this.placeholderStyle,
  });

  @override
  State<_NotebookDynamicTextFieldPanel> createState() =>
      _NotebookDynamicTextFieldPanelState();
}

class _NotebookDynamicTextFieldPanelState
    extends State<_NotebookDynamicTextFieldPanel> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const panelPadding = EdgeInsets.all(12);
    const scrollPadding = EdgeInsets.only(right: 8);

    return LayoutBuilder(
      builder: (context, constraints) {
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.controller,
          builder: (context, value, child) {
            return EditableSynopsisPanel(
              controller: widget.controller,
              scrollController: _scrollController,
              isEditing: true,
              onChanged: widget.onChanged,
              height: _calculateHeight(
                context: context,
                maxWidth: constraints.maxWidth,
                panelPadding: panelPadding,
                scrollPadding: scrollPadding,
              ),
              placeholderText: widget.placeholderText,
              textStyle: widget.textStyle,
              placeholderStyle: widget.placeholderStyle,
              focusedBorderColor: widget.accentColor,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              keyboardType: widget.maxLines == 1
                  ? TextInputType.text
                  : TextInputType.multiline,
              textInputAction: widget.maxLines == 1
                  ? TextInputAction.next
                  : TextInputAction.newline,
              panelPadding: panelPadding,
              scrollPadding: scrollPadding,
              fillColor: Colors.white.withValues(alpha: 0.72),
              blurSigma: 4,
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
              viewerBuilder: (context, text, style) => Text(text, style: style),
            );
          },
        );
      },
    );
  }

  double _calculateHeight({
    required BuildContext context,
    required double maxWidth,
    required EdgeInsetsGeometry panelPadding,
    required EdgeInsetsGeometry scrollPadding,
  }) {
    final text = widget.controller.text.trim().isEmpty
        ? widget.placeholderText
        : widget.controller.text;
    final resolvedPanelPadding = panelPadding.resolve(
      Directionality.of(context),
    );
    final resolvedScrollPadding = scrollPadding.resolve(
      Directionality.of(context),
    );
    final availableWidth = max(
      0.0,
      maxWidth -
          resolvedPanelPadding.horizontal -
          resolvedScrollPadding.horizontal,
    );
    final measurementStyle = widget.controller.text.trim().isEmpty
        ? widget.placeholderStyle
        : widget.textStyle;
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: measurementStyle),
      textDirection: Directionality.of(context),
      maxLines: widget.maxLines,
    )..layout(maxWidth: availableWidth);
    final lineStyle = measurementStyle;
    final lineHeight = (lineStyle.fontSize ?? 11) * (lineStyle.height ?? 1.0);
    final minimumHeight =
        (lineHeight * widget.minLines) + resolvedPanelPadding.vertical;
    final maxHeight = widget.maxLines == 1 ? minimumHeight : 220.0;
    final estimatedHeight =
        textPainter.size.height + resolvedPanelPadding.vertical;

    return estimatedHeight.clamp(minimumHeight, maxHeight);
  }
}

class _ColorTile extends StatelessWidget {
  final Color accentColor;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorTile({
    required this.accentColor,
    required this.label,
    required this.color,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isSelected ? 0.66 : 0.54),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.34)
                  : accentColor.withValues(alpha: 0.16),
              width: isSelected ? 1.1 : 0.8,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF2C262C),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.24),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.56),
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final Color accentColor;
  final Color avatarColor;
  final ProjectImageData image;
  final String imageLabel;
  final ValueChanged<double> onScaleChanged;
  final void Function(double offsetX, double offsetY) onOffsetChanged;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;

  const _ImageTile({
    required this.accentColor,
    required this.avatarColor,
    required this.image,
    required this.imageLabel,
    required this.onScaleChanged,
    required this.onOffsetChanged,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.16),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto',
            style: TextStyle(
              color: Color(0xFF2C262C),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            imageLabel,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.56),
              fontSize: 11.5,
              height: 1.3,
            ),
          ),
          if (image.bytes != null) ...[
            const SizedBox(height: 10),
            _NotebookProfileImageEditor(
              image: image,
              accentColor: accentColor,
              avatarColor: avatarColor,
              onScaleChanged: onScaleChanged,
              onOffsetChanged: onOffsetChanged,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickImage,
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text('Imagem'),
                ),
              ),
              if (onRemoveImage != null) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onRemoveImage,
                  child: const Text('Remover'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _NotebookProfileImageEditor extends StatelessWidget {
  final ProjectImageData image;
  final Color accentColor;
  final Color avatarColor;
  final ValueChanged<double> onScaleChanged;
  final void Function(double offsetX, double offsetY) onOffsetChanged;

  const _NotebookProfileImageEditor({
    required this.image,
    required this.accentColor,
    required this.avatarColor,
    required this.onScaleChanged,
    required this.onOffsetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameWidth = (constraints.maxWidth - 44)
            .clamp(160.0, 260.0)
            .toDouble();
        final frameHeight =
            frameWidth *
            (characterProfileTileHeight / characterProfileTileWidth);
        final canvasHeight = frameHeight + 44;
        final frameTop = (canvasHeight - frameHeight) / 2;
        final frameLeft = (constraints.maxWidth - frameWidth) / 2;
        final metrics = computeProjectImageViewportMetrics(
          viewportSize: Size(frameWidth, frameHeight),
          imageWidth: image.width ?? 0,
          imageHeight: image.height ?? 0,
          scale: image.scale,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: canvasHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.alphaBlend(
                        accentColor.withValues(alpha: 0.14),
                        Colors.white.withValues(alpha: 0.84),
                      ),
                      Color.alphaBlend(
                        avatarColor.withValues(alpha: 0.34),
                        const Color(0xFFF8F1F5),
                      ),
                      Color.alphaBlend(
                        accentColor.withValues(alpha: 0.12),
                        const Color(0xFFF0E2EA),
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) {
                    final offset = resolveProjectImageDragOffset(
                      currentOffsetX: image.offsetX,
                      currentOffsetY: image.offsetY,
                      dragDelta: details.delta,
                      metrics: metrics,
                    );
                    onOffsetChanged(offset.dx, offset.dy);
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: SizedBox(
                          width: frameWidth,
                          height: frameHeight,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                              topRight: Radius.circular(18),
                              bottomRight: Radius.circular(18),
                            ),
                            child: ProjectImageTransformView(
                              imageBytes: image.bytes!,
                              imageWidth: image.width ?? frameWidth,
                              imageHeight: image.height ?? frameHeight,
                              scale: image.scale,
                              offsetX: image.offsetX,
                              offsetY: image.offsetY,
                              viewportWidth: frameWidth,
                              viewportHeight: frameHeight,
                            ),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              height: frameTop,
                              child: ColoredBox(
                                color: Colors.white.withValues(alpha: 0.34),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: frameTop,
                              child: ColoredBox(
                                color: Colors.white.withValues(alpha: 0.34),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: frameTop,
                              bottom: frameTop,
                              width: frameLeft,
                              child: ColoredBox(
                                color: Colors.white.withValues(alpha: 0.34),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: frameTop,
                              bottom: frameTop,
                              width: frameLeft,
                              child: ColoredBox(
                                color: Colors.white.withValues(alpha: 0.34),
                              ),
                            ),
                            Positioned(
                              left: frameLeft,
                              top: frameTop,
                              width: frameWidth,
                              height: frameHeight,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                    topRight: Radius.circular(18),
                                    bottomRight: Radius.circular(18),
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.94),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Zoom',
                  style: TextStyle(
                    color: Color(0xFF514752),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 8,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      activeTrackColor: accentColor,
                      inactiveTrackColor: accentColor.withValues(alpha: 0.22),
                      thumbColor: accentColor,
                    ),
                    child: Slider(
                      value: image.scale.clamp(1.0, 3.0).toDouble(),
                      min: 1,
                      max: 3,
                      onChanged: onScaleChanged,
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${image.scale.toStringAsFixed(1)}x',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF7A7079),
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CharacterIdentityTagGrid extends StatelessWidget {
  final String genderLabel;
  final Color? genderColor;
  final String sexualityLabel;
  final Color? sexualityColor;
  final String ethnicityLabel;
  final Color? ethnicityColor;
  final String functionLabel;
  final Color? functionColor;
  final Color accentColor;
  final bool showRequiredErrors;
  final VoidCallback onPickGenderTag;
  final VoidCallback onPickSexualityTag;
  final VoidCallback onPickEthnicityTag;
  final VoidCallback onPickFunctionTag;

  const _CharacterIdentityTagGrid({
    required this.genderLabel,
    required this.genderColor,
    required this.sexualityLabel,
    required this.sexualityColor,
    required this.ethnicityLabel,
    required this.ethnicityColor,
    required this.functionLabel,
    required this.functionColor,
    required this.accentColor,
    required this.showRequiredErrors,
    required this.onPickGenderTag,
    required this.onPickSexualityTag,
    required this.onPickEthnicityTag,
    required this.onPickFunctionTag,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CharacterTagSelectorField(
                label: 'Gênero',
                value: genderLabel,
                accentColor: accentColor,
                selectedColor: genderColor,
                isRequired: false,
                showError: false,
                onTap: onPickGenderTag,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CharacterTagSelectorField(
                label: 'Sexualidade',
                value: sexualityLabel,
                accentColor: accentColor,
                selectedColor: sexualityColor,
                onTap: onPickSexualityTag,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CharacterTagSelectorField(
                label: 'Etnia',
                value: ethnicityLabel,
                accentColor: accentColor,
                selectedColor: ethnicityColor,
                onTap: onPickEthnicityTag,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CharacterTagSelectorField(
                label: 'Função',
                value: functionLabel,
                accentColor: accentColor,
                selectedColor: functionColor,
                onTap: onPickFunctionTag,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CharacterTagSelectorField extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;
  final Color? selectedColor;
  final bool isRequired;
  final bool showError;
  final VoidCallback onTap;

  const _CharacterTagSelectorField({
    required this.label,
    required this.value,
    required this.accentColor,
    this.selectedColor,
    this.isRequired = false,
    this.showError = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.trim().isNotEmpty;
    final effectiveColor = selectedColor ?? accentColor;
    final borderColor = showError
        ? const Color(0xFFC96775)
        : Colors.white.withValues(alpha: 0.82);
    final decoration = showError
        ? BoxDecoration(
            color: Colors.white.withValues(alpha: 0.52),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.72),
                const Color(0xFFC96775).withValues(alpha: 0.08),
              ],
            ),
          )
        : _buildCharacterDialogSurfaceDecoration(
            accentColor: effectiveColor,
            selected: hasValue,
            borderRadius: BorderRadius.circular(16),
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 78,
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: decoration,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isRequired ? '$label *' : label,
                      style: const TextStyle(
                        color: Color(0xFF3A3339),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hasValue
                          ? value
                          : showError
                          ? 'Campo obrigatório'
                          : 'Selecionar opção',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: showError
                            ? const Color(0xFFC96775)
                            : hasValue
                            ? _darkenCharacterDialogColor(effectiveColor, 0.2)
                            : const Color(0xFF8E838B),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        fontWeight: hasValue
                            ? FontWeight.w700
                            : FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.56),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.84),
                  ),
                ),
                child: Icon(
                  hasValue ? Icons.edit_rounded : Icons.add_rounded,
                  size: 15,
                  color: _darkenCharacterDialogColor(effectiveColor, 0.16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
