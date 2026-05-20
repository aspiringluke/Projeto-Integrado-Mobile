import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../shared/widgets/synopsis_scroll_box.dart';
import '../../characters/models/characters_models.dart';
import '../../tags/controllers/tag_controller.dart';
import '../models/create_project_dialog_image_viewport_presets.dart';
import '../models/project_image_data.dart';
import '../models/project_record.dart';
import '../models/project_tag_data.dart';
import '../utils/project_image_picker.dart';
import '../utils/project_image_picker_result.dart';
import '../utils/project_character_showcase.dart';
import 'project_image_transform_view.dart';
import 'create_project_dialog_image_widgets.dart';
import 'create_project_dialog_sections.dart';
import 'create_project_dialog_support_widgets.dart';
import 'project_color_editor.dart';

enum ProjectGeneralColorTarget { cover, accent }

enum _ProjectGeneralPanel {
  geral,
  tags,
  colors,
  featuredCharacters,
  coverImage,
}

class ProjectGeneralSection extends StatefulWidget {
  final ProjectRecord project;
  final List<ProjectTagData> availableTags;
  final List<CharacterListItem> availableCharacters;
  final bool isLoadingCharacters;
  final ValueChanged<ProjectRecord> onChanged;

  const ProjectGeneralSection({
    super.key,
    required this.project,
    required this.availableTags,
    this.availableCharacters = const <CharacterListItem>[],
    this.isLoadingCharacters = false,
    required this.onChanged,
  });

  @override
  State<ProjectGeneralSection> createState() => _ProjectGeneralSectionState();
}

class _ProjectGeneralSectionState extends State<ProjectGeneralSection> {
  late final TextEditingController _titleController;
  late final TextEditingController _synopsisController;
  late final TextEditingController _newTagController;
  late final ScrollController _scrollController;
  late final ScrollController _synopsisScrollController;
  late TagController _tagController;
  ProjectGeneralColorTarget _activeColorTarget =
      ProjectGeneralColorTarget.accent;
  final Set<_ProjectGeneralPanel> _expandedPanels = {
    _ProjectGeneralPanel.geral,
    _ProjectGeneralPanel.tags,
    _ProjectGeneralPanel.colors,
    _ProjectGeneralPanel.featuredCharacters,
  };

  static const TextStyle _synopsisTextStyle = TextStyle(
    fontSize: 12,
    color: Color(0xFF3A3339),
    height: 1.35,
  );

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project.title);
    _synopsisController = TextEditingController(text: widget.project.synopsis);
    _newTagController = TextEditingController();
    _scrollController = ScrollController();
    _synopsisScrollController = ScrollController();
    _tagController = _buildTagController();
    _titleController.addListener(_syncTextDraft);
    _synopsisController.addListener(_syncTextDraft);
    _tagController.addListener(_syncTagsDraft);
  }

  @override
  void didUpdateWidget(covariant ProjectGeneralSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.id != widget.project.id) {
      _titleController.text = widget.project.title;
      _synopsisController.text = widget.project.synopsis;
      _tagController.removeListener(_syncTagsDraft);
      _tagController.dispose();
      _tagController = _buildTagController()..addListener(_syncTagsDraft);
    }
  }

  @override
  void dispose() {
    _tagController.removeListener(_syncTagsDraft);
    _tagController.dispose();
    _titleController.removeListener(_syncTextDraft);
    _synopsisController.removeListener(_syncTextDraft);
    _titleController.dispose();
    _synopsisController.dispose();
    _newTagController.dispose();
    _scrollController.dispose();
    _synopsisScrollController.dispose();
    super.dispose();
  }

  TagController _buildTagController() {
    final knownTags = <ProjectTagData>[
      ...widget.availableTags,
      ...widget.project.tags,
    ];

    return TagController(
      knownTags: knownTags,
      selectedTagLabels: widget.project.tags.map((tag) => tag.normalizedLabel),
      groupTitle: 'Projetos',
    );
  }

  void _syncTextDraft() {
    final title = _titleController.text.trim();
    final synopsis = _synopsisController.text;
    if (title.isEmpty) {
      return;
    }

    if (title == widget.project.title && synopsis == widget.project.synopsis) {
      return;
    }

    widget.onChanged(widget.project.copyWith(title: title, synopsis: synopsis));
  }

  void _syncTagsDraft() {
    if (!mounted) return;
    setState(() {});
    widget.onChanged(
      widget.project.copyWith(tags: _tagController.selectedTags),
    );
  }

  void _addTagFromInput() {
    final didAdd = _tagController.addTagFromInput(_newTagController.text);
    if (didAdd) {
      _newTagController.clear();
      setState(() {});
    }
  }

  void _updateCoverImage(ProjectImageData image) {
    widget.onChanged(widget.project.copyWith(coverImage: image));
  }

  Future<void> _pickCoverImage() async {
    ProjectImagePickResult? result;
    try {
      result = await pickProjectImage();
    } on ProjectImagePickException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted || result == null) return;

    _updateCoverImage(
      ProjectImageData(
        bytes: result.bytes,
        width: result.width,
        height: result.height,
      ),
    );
  }

  void _removeCoverImage() {
    _updateCoverImage(const ProjectImageData());
  }

  void _toggleFeaturedCharacter(CharacterListItem character) {
    final characterId = character.id;
    if (characterId == null) {
      return;
    }

    widget.onChanged(
      widget.project.copyWith(
        featuredCharacterIds: toggleProjectShowcaseCharacterId(
          selectedCharacterIds: widget.project.featuredCharacterIds,
          characterId: characterId,
        ),
      ),
    );
  }

  void _resetFeaturedCharactersToAutomatic() {
    widget.onChanged(
      widget.project.copyWith(featuredCharacterIds: const <int>[]),
    );
  }

  double _calculateSynopsisHeight(double maxWidth) {
    final text = _synopsisController.text.trim().isEmpty
        ? synopsisPlaceholderText
        : _synopsisController.text;

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: _synopsisTextStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      maxLines: null,
    );

    textPainter.layout(maxWidth: maxWidth - 16);
    const verticalPadding = 16.0;
    final estimatedHeight = textPainter.size.height + verticalPadding;
    final minimumHeight =
        (_synopsisTextStyle.fontSize! * _synopsisTextStyle.height!) +
        verticalPadding;

    return estimatedHeight.clamp(minimumHeight, 220.0);
  }

  void _setActiveColorTarget(ProjectGeneralColorTarget target) {
    if (_activeColorTarget == target) return;
    setState(() {
      _activeColorTarget = target;
    });
  }

  void _setActiveColor(Color color) {
    final next = switch (_activeColorTarget) {
      ProjectGeneralColorTarget.cover => widget.project.copyWith(
        coverColor: color,
      ),
      ProjectGeneralColorTarget.accent => widget.project.copyWith(
        accentColor: color,
      ),
    };
    widget.onChanged(next);
  }

  Color get _activeColor => switch (_activeColorTarget) {
    ProjectGeneralColorTarget.cover => widget.project.coverColor,
    ProjectGeneralColorTarget.accent => widget.project.accentColor,
  };

  bool get _isCoverTarget =>
      _activeColorTarget == ProjectGeneralColorTarget.cover;

  bool _isPanelExpanded(_ProjectGeneralPanel panel) {
    return _expandedPanels.contains(panel);
  }

  void _togglePanel(_ProjectGeneralPanel panel) {
    setState(() {
      if (!_expandedPanels.remove(panel)) {
        _expandedPanels.add(panel);
      }
    });
  }

  Widget _buildPanel({
    required _ProjectGeneralPanel panel,
    required IconData icon,
    required String label,
    required Color accentColor,
    required WidgetBuilder childBuilder,
    Widget? trailing,
  }) {
    return _SectionSurface(
      accentColor: accentColor,
      icon: icon,
      label: label,
      isExpanded: _isPanelExpanded(panel),
      trailing: trailing,
      onToggle: () => _togglePanel(panel),
      childBuilder: childBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final coverImage = project.coverImage;

    return SynopsisScrollBox(
      controller: _scrollController,
      childIsScrollable: true,
      height: double.infinity,
      contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: ClampingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPanel(
              panel: _ProjectGeneralPanel.geral,
              accentColor: project.accentColor,
              icon: Icons.tune_rounded,
              label: 'Geral',
              childBuilder: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CreateProjectDialogTitleField(
                    controller: _titleController,
                    focusedColor: project.accentColor,
                    buildInputDecoration: _buildInputDecoration,
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return CreateProjectDialogSynopsisField(
                        controller: _synopsisController,
                        scrollController: _synopsisScrollController,
                        textStyle: _synopsisTextStyle,
                        height: _calculateSynopsisHeight(constraints.maxWidth),
                        focusedBorderColor: project.accentColor,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildPanel(
              panel: _ProjectGeneralPanel.tags,
              accentColor: project.accentColor,
              icon: Icons.local_offer_outlined,
              label: 'Tags',
              childBuilder: (context) => _buildTagsSection(project),
            ),
            const SizedBox(height: 12),
            _buildPanel(
              panel: _ProjectGeneralPanel.colors,
              accentColor: project.accentColor,
              icon: Icons.palette_outlined,
              label: 'Cores',
              childBuilder: (context) => _buildColorSection(project),
            ),
            const SizedBox(height: 12),
            _buildPanel(
              panel: _ProjectGeneralPanel.featuredCharacters,
              accentColor: project.accentColor,
              icon: Icons.groups_2_outlined,
              label: 'Personagens exibidos',
              trailing: project.featuredCharacterIds.isEmpty
                  ? null
                  : TextButton.icon(
                      onPressed: _resetFeaturedCharactersToAutomatic,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                      label: const Text('Auto'),
                      style: TextButton.styleFrom(
                        foregroundColor: _darken(project.accentColor, 0.16),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
              childBuilder: (context) =>
                  _buildFeaturedCharactersSection(project),
            ),
            const SizedBox(height: 12),
            _buildPanel(
              panel: _ProjectGeneralPanel.coverImage,
              accentColor: project.accentColor,
              icon: Icons.image_outlined,
              label: 'Imagem da capa',
              childBuilder: (context) => CreateProjectDialogCoverImagePickerCard(
                title: 'Imagem da capa',
                description:
                    'Escolha uma imagem e ajuste o enquadramento usado no banner e no cartao.',
                imageBytes: coverImage.bytes,
                imageWidth: coverImage.width,
                imageHeight: coverImage.height,
                imageName: null,
                scale: coverImage.scale,
                offsetX: coverImage.offsetX,
                offsetY: coverImage.offsetY,
                backgroundGradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFF4EDF2),
                    Color(0xFFEAE2E8),
                    Color(0xFFFFFFFF),
                  ],
                ),
                viewportPreset: createProjectDialogCoverViewportPreset,
                emptyStateText: 'Nenhuma imagem selecionada',
                footerNote: 'Formatos suportados: JPEG, PNG, GIF e WEBP.',
                onScaleChanged: (value) =>
                    _updateCoverImage(coverImage.copyWith(scale: value)),
                onOffsetChanged: (offsetX, offsetY) => _updateCoverImage(
                  coverImage.copyWith(offsetX: offsetX, offsetY: offsetY),
                ),
                onPick: _pickCoverImage,
                onRemove: coverImage.bytes == null ? null : _removeCoverImage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(ProjectRecord project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_tagController.knownTags.isEmpty)
          CreateProjectDialogInfoSurface(
            child: const Text(
              'Nenhuma tag cadastrada ainda.',
              style: TextStyle(color: Color(0xFF6A6167), fontSize: 12),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in _tagController.knownTags)
                CreateProjectDialogSelectableTagChip(
                  tag: tag,
                  isSelected: _tagController.isSelected(tag),
                  onTap: () => _tagController.toggle(tag),
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
                  focusedColor: project.accentColor,
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
                  backgroundColor: project.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: const Icon(Icons.add_rounded, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CreateProjectDialogDraftTagPreview(
              label: _newTagController.text.trim().isEmpty
                  ? 'Nova tag'
                  : sanitizeProjectTagLabel(_newTagController.text),
              color: _tagController.draftTagColor,
            ),
            for (final color in projectTagPalette)
              CreateProjectDialogTagColorSwatch(
                color: color,
                isSelected: color == _tagController.draftTagColor,
                onTap: () => _tagController.setDraftTagColor(color),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSection(ProjectRecord project) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CreateProjectDialogColorTargetChip(
                label: 'Capa',
                color: project.coverColor,
                gradient: buildCreateProjectDialogCoverPreviewGradient(
                  project.coverColor,
                  project.accentColor,
                ),
                swatchGradient: buildCreateProjectDialogCoverPreviewGradient(
                  project.coverColor,
                  project.accentColor,
                ),
                isSelected:
                    _activeColorTarget == ProjectGeneralColorTarget.cover,
                onTap: () =>
                    _setActiveColorTarget(ProjectGeneralColorTarget.cover),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CreateProjectDialogColorTargetChip(
                label: 'Realce',
                color: project.accentColor,
                gradient: buildCreateProjectDialogAccentPreviewGradient(
                  project.accentColor,
                ),
                swatchGradient: buildCreateProjectDialogAccentPreviewGradient(
                  project.accentColor,
                ),
                isSelected:
                    _activeColorTarget == ProjectGeneralColorTarget.accent,
                onTap: () =>
                    _setActiveColorTarget(ProjectGeneralColorTarget.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ProjectColorEditor(
          title: _isCoverTarget ? 'Cor da capa' : 'Cor de realce',
          description: _isCoverTarget
              ? 'Preenche o banner e a capa do cartao.'
              : 'Controla os destaques visuais do projeto.',
          color: _activeColor,
          accentColor: project.accentColor,
          hslColor: HSLColor.fromColor(_activeColor),
          useSolidCoverPreview: _isCoverTarget,
          onHueChanged: (value) => _setActiveColor(
            HSLColor.fromColor(_activeColor).withHue(value).toColor(),
          ),
          onSaturationChanged: (value) => _setActiveColor(
            HSLColor.fromColor(_activeColor).withSaturation(value).toColor(),
          ),
          onLightnessChanged: (value) => _setActiveColor(
            HSLColor.fromColor(_activeColor).withLightness(value).toColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCharactersSection(ProjectRecord project) {
    final selectedIds = project.featuredCharacterIds;
    final isAutomatic = selectedIds.isEmpty;
    final showcasedCharacters = resolveProjectShowcaseCharacters(
      selectedCharacterIds: selectedIds,
      characters: widget.availableCharacters,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateProjectDialogInfoSurface(
          child: Text(
            isAutomatic
                ? 'O cartão usa os 3 personagens de maior relevância.'
                : 'O cartão usa os personagens escolhidos abaixo.',
            style: const TextStyle(color: Color(0xFF6A6167), fontSize: 12),
          ),
        ),
        if (widget.isLoadingCharacters) ...[
          const SizedBox(height: 10),
          const LinearProgressIndicator(minHeight: 2),
        ] else if (widget.availableCharacters.isEmpty) ...[
          const SizedBox(height: 10),
          const Text(
            'Nenhum personagem criado neste projeto.',
            style: TextStyle(
              color: Color(0xFF6A6167),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ] else ...[
          const SizedBox(height: 12),
          _FeaturedCharacterPreviewRow(
            accentColor: project.accentColor,
            characters: showcasedCharacters,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final character in widget.availableCharacters)
                _FeaturedCharacterChoiceChip(
                  character: character,
                  accentColor: project.accentColor,
                  selected: selectedIds.contains(character.id),
                  disabled:
                      !isAutomatic &&
                      !selectedIds.contains(character.id) &&
                      selectedIds.length >= projectShowcaseCharacterLimit,
                  automaticPreview:
                      isAutomatic && showcasedCharacters.contains(character),
                  onTap: () => _toggleFeaturedCharacter(character),
                ),
            ],
          ),
        ],
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required Color focusedColor,
  }) {
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
        borderSide: BorderSide(color: focusedColor, width: 1.1),
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

class _SectionSurface extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final String label;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget? trailing;
  final WidgetBuilder childBuilder;

  const _SectionSurface({
    required this.accentColor,
    required this.icon,
    required this.label,
    required this.isExpanded,
    required this.onToggle,
    required this.childBuilder,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.46),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onToggle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SectionTitle(
                            icon: icon,
                            label: label,
                            accentColor: accentColor,
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: 8),
                          trailing!,
                        ],
                        const SizedBox(width: 6),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 23,
                            color: _darken(accentColor, 0.18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: isExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: childBuilder(context),
                      )
                    : const SizedBox(width: double.infinity),
                secondChild: const SizedBox(width: double.infinity),
                crossFadeState: isExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 180),
                sizeCurve: Curves.easeOutCubic,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;

  const _SectionTitle({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _darken(accentColor, 0.18)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF2C262C),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _FeaturedCharacterPreviewRow extends StatelessWidget {
  final Color accentColor;
  final List<CharacterListItem> characters;

  const _FeaturedCharacterPreviewRow({
    required this.accentColor,
    required this.characters,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var index = 0; index < projectShowcaseCharacterLimit; index += 1)
          _FeaturedCharacterAvatar(
            character: index < characters.length ? characters[index] : null,
            accentColor: accentColor,
            size: 38,
          ),
      ],
    );
  }
}

class _FeaturedCharacterChoiceChip extends StatelessWidget {
  final CharacterListItem character;
  final Color accentColor;
  final bool selected;
  final bool disabled;
  final bool automaticPreview;
  final VoidCallback onTap;

  const _FeaturedCharacterChoiceChip({
    required this.character,
    required this.accentColor,
    required this.selected,
    required this.disabled,
    required this.automaticPreview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = character.data.accent;
    final borderColor = selected
        ? effectiveAccent.withValues(alpha: 0.72)
        : automaticPreview
        ? accentColor.withValues(alpha: 0.42)
        : Colors.white.withValues(alpha: 0.82);

    return Opacity(
      opacity: disabled ? 0.46 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: disabled ? null : onTap,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 190),
            padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
            decoration: BoxDecoration(
              color: selected
                  ? effectiveAccent.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.52),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor, width: selected ? 1 : 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FeaturedCharacterAvatar(
                  character: character,
                  accentColor: effectiveAccent,
                  size: 28,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    character.data.name.trim().isEmpty
                        ? 'Sem nome'
                        : character.data.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF2C262C),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 5),
                  Icon(Icons.check_rounded, size: 15, color: effectiveAccent),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedCharacterAvatar extends StatelessWidget {
  final CharacterListItem? character;
  final Color accentColor;
  final double size;

  const _FeaturedCharacterAvatar({
    required this.character,
    required this.accentColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final image = character?.data.profileImage;
    final color = character?.data.avatarColor ?? accentColor;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.92),
            accentColor.withValues(alpha: 0.62),
            Colors.white.withValues(alpha: 0.42),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
      ),
      child: ClipOval(
        child: image?.bytes == null
            ? Icon(
                Icons.person_rounded,
                size: size * 0.56,
                color: const Color(0xFF171419).withValues(alpha: 0.72),
              )
            : ProjectImageTransformView(
                imageBytes: image!.bytes!,
                imageWidth: image.width ?? size,
                imageHeight: image.height ?? size,
                scale: image.scale,
                offsetX: image.offsetX,
                offsetY: image.offsetY,
                viewportWidth: size,
                viewportHeight: size,
              ),
      ),
    );
  }
}

Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}
