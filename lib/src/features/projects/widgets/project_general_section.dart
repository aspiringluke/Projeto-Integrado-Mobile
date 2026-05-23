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

part 'project_general_section_parts/project_general_section_widgets.dart';

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
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _synopsisController,
                    builder: (context, value, child) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return CreateProjectDialogSynopsisField(
                            controller: _synopsisController,
                            scrollController: _synopsisScrollController,
                            textStyle: _synopsisTextStyle,
                            height: _calculateSynopsisHeight(
                              constraints.maxWidth,
                            ),
                            focusedBorderColor: project.accentColor,
                          );
                        },
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
                ? 'O cartão usa os $projectShowcaseCharacterLimit personagens de maior relevância.'
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
