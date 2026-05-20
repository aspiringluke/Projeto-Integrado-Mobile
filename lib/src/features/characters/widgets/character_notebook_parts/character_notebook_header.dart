part of '../character_notebook_page.dart';

class _NotebookHeader extends StatelessWidget {
  final CharacterCardData data;
  final bool isImageControlsExpanded;
  final VoidCallback onClose;
  final VoidCallback onToggleImageControls;
  final ValueChanged<ProjectImageData> onProfileImageChanged;
  final ValueChanged<double> onProfileScaleChanged;

  const _NotebookHeader({
    required this.data,
    required this.isImageControlsExpanded,
    required this.onClose,
    required this.onToggleImageControls,
    required this.onProfileImageChanged,
    required this.onProfileScaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tags = _buildNotebookHeaderTags(data);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MainHeader(
          asSliver: false,
          title: data.name,
          onBackPressed: onClose,
          onConfigPressed: () {},
          headerHeight: 200,
          contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          titleHorizontalPadding: 60,
          titleShadow: true,
          centerChild: _NotebookHeaderTitleBlock(data: data),
          bottomChild: tags.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
                  child: _NotebookHeaderTagWrap(tags: tags),
                ),
          backgroundChild: Stack(
            fit: StackFit.expand,
            children: [
              _NotebookHeaderCoverBackground(
                data: data,
                isImageControlsExpanded: isImageControlsExpanded,
                onToggleImageControls: onToggleImageControls,
                onProfileImageChanged: onProfileImageChanged,
                onProfileScaleChanged: onProfileScaleChanged,
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          data.accent.withValues(alpha: 0.035),
                          Colors.black.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0.03),
                          Colors.black.withValues(alpha: 0.12),
                          data.accent.withValues(alpha: 0.035),
                        ],
                        stops: const [0.0, 0.18, 0.5, 0.82, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotebookHeaderTagWrap extends StatelessWidget {
  final List<_NotebookHeaderTagItem> tags;

  const _NotebookHeaderTagWrap({required this.tags});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < tags.length; index += 1) ...[
              if (index > 0) const SizedBox(width: 6),
              _MiniChip(
                icon: tags[index].icon,
                label: tags[index].label,
                color: tags[index].color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotebookHeaderTagItem {
  final IconData icon;
  final String label;
  final Color color;

  const _NotebookHeaderTagItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}

List<_NotebookHeaderTagItem> _buildNotebookHeaderTags(CharacterCardData data) {
  final tags = <_NotebookHeaderTagItem>[
    _NotebookHeaderTagItem(
      icon: Icons.star_rounded,
      label: data.relevanceTag.isEmpty ? 'N/A' : data.relevanceTag,
      color: _notebookHeaderRelevanceColor(data.relevanceTag),
    ),
  ];

  void addTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    if (label.trim().isEmpty) return;
    tags.add(_NotebookHeaderTagItem(icon: icon, label: label, color: color));
  }

  addTag(
    icon: Icons.wc_rounded,
    label: data.genderTag,
    color: projectTagColorAt(0),
  );
  addTag(
    icon: Icons.favorite_border_rounded,
    label: data.sexualityTag,
    color: projectTagColorAt(1),
  );
  addTag(
    icon: Icons.groups_2_outlined,
    label: data.ethnicityTag,
    color: projectTagColorAt(2),
  );
  addTag(
    icon: Icons.badge_outlined,
    label: data.functionTag,
    color: projectTagColorAt(3),
  );

  return tags;
}

Color _notebookHeaderRelevanceColor(String label) {
  final normalizedLabel = label
      .trim()
      .toLowerCase()
      .replaceAll('ú', 'u')
      .replaceAll('é', 'e');
  return switch (normalizedLabel) {
    'contorno' => const Color(0xFF8E838B),
    'periferico' => const Color(0xFF8EAFF1),
    'orbital' => const Color(0xFFDF9C53),
    'nucleo' => const Color(0xFFDF6EB8),
    _ => const Color(0xFF8E838B),
  };
}

class _NotebookHeaderInfoPanel extends StatelessWidget {
  final CharacterCardData data;

  const _NotebookHeaderInfoPanel({required this.data});

  @override
  Widget build(BuildContext context) {
    final glowColor = data.accent.withValues(alpha: 0.34);
    final dropShadow = Colors.black.withValues(alpha: 0.22);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Text(
        data.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0xFFF9F5F8),
          fontSize: 24,
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.1,
          shadows: [
            Shadow(color: glowColor, blurRadius: 18),
            Shadow(color: glowColor, blurRadius: 8),
            Shadow(
              color: dropShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotebookHeaderTitleBlock extends StatelessWidget {
  final CharacterCardData data;

  const _NotebookHeaderTitleBlock({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NotebookHeaderInfoPanel(data: data),
          const SizedBox(height: 4),
          Container(
            width: 82,
            height: 1,
            color: Colors.white.withValues(alpha: 0.46),
          ),
          const SizedBox(height: 4),
          if (data.alias.trim().isNotEmpty)
            Text(
              data.alias,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFF1ECF0).withValues(alpha: 0.74),
                fontSize: 12.5,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NotebookHeaderCoverBackground extends StatelessWidget {
  final CharacterCardData data;
  final bool isImageControlsExpanded;
  final VoidCallback onToggleImageControls;
  final ValueChanged<ProjectImageData> onProfileImageChanged;
  final ValueChanged<double> onProfileScaleChanged;

  const _NotebookHeaderCoverBackground({
    required this.data,
    required this.isImageControlsExpanded,
    required this.onToggleImageControls,
    required this.onProfileImageChanged,
    required this.onProfileScaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(
                  data.accent.withValues(alpha: 0.11),
                  data.avatarColor.withValues(alpha: 0.94),
                ),
                Color.alphaBlend(
                  data.avatarColor.withValues(alpha: 0.93),
                  Colors.black.withValues(alpha: 0.06),
                ),
                Color.alphaBlend(
                  data.accent.withValues(alpha: 0.075),
                  Colors.white.withValues(alpha: 0.1),
                ),
              ],
              stops: const [0.0, 0.56, 1.0],
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  data.accent.withValues(alpha: 0.055),
                  Colors.transparent,
                  Colors.transparent,
                  data.accent.withValues(alpha: 0.055),
                ],
                stops: const [0.0, 0.22, 0.78, 1.0],
              ),
            ),
          ),
        ),
        if (data.profileImage.bytes != null) ...[
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final profileImage = data.profileImage;
                final metrics = computeProjectImageViewportMetrics(
                  viewportSize: constraints.biggest,
                  imageWidth: profileImage.width ?? 0,
                  imageHeight: profileImage.height ?? 0,
                  scale: profileImage.scale,
                );

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) {
                    final offset = resolveProjectImageDragOffset(
                      currentOffsetX: profileImage.offsetX,
                      currentOffsetY: profileImage.offsetY,
                      dragDelta: details.delta,
                      metrics: metrics,
                    );
                    onProfileImageChanged(
                      profileImage.copyWith(
                        offsetX: offset.dx,
                        offsetY: offset.dy,
                      ),
                    );
                  },
                  child: _NotebookHeaderCoverImageLayer(
                    profileImage: profileImage,
                    sigma: 0,
                    opacity: 0.9,
                  ),
                );
              },
            ),
          ),
        ] else ...[
          _NotebookHeaderCoverIconLayer(
            accentColor: data.accent,
            sigma: 0,
            opacity: 0.36,
          ),
        ],
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.05),
                    Colors.white.withValues(alpha: 0.16),
                  ],
                  stops: const [0.0, 0.34, 0.76, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.16),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.06),
                  ],
                  stops: const [0.0, 0.52, 1.0],
                ),
              ),
            ),
          ),
        ),
        if (data.profileImage.bytes != null)
          Positioned(
            right: 14,
            bottom: 10,
            child: _NotebookHeaderImageControls(
              accentColor: data.accent,
              isExpanded: isImageControlsExpanded,
              scale: data.profileImage.scale,
              onToggle: onToggleImageControls,
              onScaleChanged: onProfileScaleChanged,
            ),
          ),
      ],
    );
  }
}

class _NotebookHeaderCoverImageLayer extends StatelessWidget {
  final ProjectImageData profileImage;
  final double sigma;
  final double opacity;

  const _NotebookHeaderCoverImageLayer({
    required this.profileImage,
    required this.sigma,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final image = SizedBox.expand(
      child: ProjectImageTransformView(
        imageBytes: profileImage.bytes!,
        imageWidth: profileImage.width ?? 1,
        imageHeight: profileImage.height ?? 1,
        scale: profileImage.scale,
        offsetX: profileImage.offsetX,
        offsetY: profileImage.offsetY,
      ),
    );

    return Opacity(
      opacity: opacity,
      child: sigma <= 0
          ? image
          : ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: image,
            ),
    );
  }
}

class _NotebookHeaderImageControls extends StatelessWidget {
  final Color accentColor;
  final bool isExpanded;
  final double scale;
  final VoidCallback onToggle;
  final ValueChanged<double> onScaleChanged;

  const _NotebookHeaderImageControls({
    required this.accentColor,
    required this.isExpanded,
    required this.scale,
    required this.onToggle,
    required this.onScaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: isExpanded ? 168 : 46,
          height: 42,
          padding: EdgeInsets.only(
            left: 6,
            right: isExpanded ? 10 : 6,
            top: 5,
            bottom: 5,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NotebookHeaderImageControlButton(
                icon: isExpanded
                    ? Icons.keyboard_arrow_right_rounded
                    : Icons.tune_rounded,
                tooltip: isExpanded ? 'Recolher ajuste' : 'Ajustar imagem',
                onTap: onToggle,
              ),
              if (isExpanded) ...[
                const SizedBox(width: 4),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                      activeTrackColor: Colors.white.withValues(alpha: 0.92),
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: scale.clamp(1.0, 3.0).toDouble(),
                      min: 1,
                      max: 3,
                      onChanged: onScaleChanged,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotebookHeaderImageControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _NotebookHeaderImageControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 28,
            height: 28,
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _NotebookHeaderCoverIconLayer extends StatelessWidget {
  final Color accentColor;
  final double sigma;
  final double opacity;

  const _NotebookHeaderCoverIconLayer({
    required this.accentColor,
    required this.sigma,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Align(
      alignment: Alignment.centerLeft,
      child: Transform.translate(
        offset: const Offset(-14, 0),
        child: Icon(
          Icons.person_rounded,
          size: 220,
          color: accentColor.withValues(alpha: 0.96),
        ),
      ),
    );

    return Opacity(
      opacity: opacity,
      child: sigma <= 0
          ? icon
          : ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: icon,
            ),
    );
  }
}
