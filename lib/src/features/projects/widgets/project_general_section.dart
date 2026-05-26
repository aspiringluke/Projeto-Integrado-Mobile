import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../shared/widgets/synopsis_scroll_box.dart';
import '../../characters/models/characters_models.dart';
import '../../notas/models/note_metadata.dart';
import '../../notas/widgets/folder_color_picker.dart';
import '../../notas/widgets/notes_visuals.dart';
import '../../tags/controllers/tag_group_controller.dart';
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
  late final TextEditingController _groupTitleController;
  late final ScrollController _scrollController;
  late final ScrollController _synopsisScrollController;
  late TagGroupController _tagGroupController;
  late Color _draftGroupColor;
  ProjectGeneralColorTarget _activeColorTarget =
      ProjectGeneralColorTarget.accent;
  bool _composerExpanded = false;
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
    _groupTitleController = TextEditingController();
    _scrollController = ScrollController();
    _synopsisScrollController = ScrollController();
    _draftGroupColor = FolderColorPicker.colors.first;
    _tagGroupController = _buildTagGroupController();
    _titleController.addListener(_syncTextDraft);
    _synopsisController.addListener(_syncTextDraft);
    _tagGroupController.addListener(_syncTagsDraft);
  }

  @override
  void didUpdateWidget(covariant ProjectGeneralSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.id != widget.project.id) {
      _titleController.text = widget.project.title;
      _synopsisController.text = widget.project.synopsis;
      _tagGroupController.removeListener(_syncTagsDraft);
      _tagGroupController.dispose();
      _tagGroupController = _buildTagGroupController()
        ..addListener(_syncTagsDraft);
    }
  }

  @override
  void dispose() {
    _tagGroupController.removeListener(_syncTagsDraft);
    _tagGroupController.dispose();
    _titleController.removeListener(_syncTextDraft);
    _synopsisController.removeListener(_syncTextDraft);
    _titleController.dispose();
    _synopsisController.dispose();
    _groupTitleController.dispose();
    _scrollController.dispose();
    _synopsisScrollController.dispose();
    super.dispose();
  }

  TagGroupController _buildTagGroupController() {
    final groups = <String, _ProjectTagGroupDraft>{};
    final groupTitlesById = <int, String>{
      for (final tag in widget.availableTags)
        if (tag.groupId != null && tag.groupTitle?.trim().isNotEmpty == true)
          tag.groupId!: tag.groupTitle!.trim(),
    };
    for (final tag in widget.project.tags) {
      final title = tag.groupTitle?.trim().isNotEmpty == true
          ? tag.groupTitle!.trim()
          : tag.groupId != null
          ? groupTitlesById[tag.groupId!]
          : null;
      final groupTitle = title ?? 'Sem classificação';
      final group = groups.putIfAbsent(
        groupTitle,
        () => _ProjectTagGroupDraft(title: groupTitle, color: tag.color),
      );
      group.tags.add(NoteTagItem(label: tag.label));
      group.color = tag.color;
    }

    return TagGroupController(
      groups: groups.values
          .map(
            (group) => NoteTagGroup(
              title: group.title,
              color: group.color,
              tags: List<NoteTagItem>.unmodifiable(group.tags),
            ),
          )
          .toList(growable: false),
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
    widget.onChanged(widget.project.copyWith(tags: _flattenProjectTags()));
  }

  List<ProjectTagData> _flattenProjectTags() {
    final flattened = <ProjectTagData>[];
    for (final group in _tagGroupController.groups) {
      for (final tag in group.tags) {
        flattened.add(
          ProjectTagData(
            label: tag.label,
            color: group.color,
            groupTitle: group.title,
          ),
        );
      }
    }

    return flattened;
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
    final groups = _tagGroupController.groups;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (groups.isEmpty)
          CreateProjectDialogInfoSurface(
            child: const Text(
              'Nenhuma classificação criada ainda.',
              style: TextStyle(color: Color(0xFF6A6167), fontSize: 12),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < groups.length; index += 1) ...[
                _ProjectTagGroupCard(
                  group: groups[index],
                  onRemoveGroup: () => _tagGroupController.removeGroup(index),
                  onEditGroup: () => _editTagGroup(index),
                  onAddTag: (value) => _tagGroupController.addTagToGroup(
                    groupIndex: index,
                    tagLabel: value,
                  ),
                  onEditTag: ({required int tagIndex}) =>
                      _editTag(groupIndex: index, tagIndex: tagIndex),
                  onRemoveTag: ({required int tagIndex}) =>
                      _tagGroupController.removeTagFromGroup(
                        groupIndex: index,
                        tagIndex: tagIndex,
                      ),
                ),
                if (index < groups.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        const SizedBox(height: 10),
        _CompactActionRow(
          label: 'Nova classificação',
          icon: Icons.add_rounded,
          onTap: () => setState(() => _composerExpanded = !_composerExpanded),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _ProjectTagGroupComposer(
              titleController: _groupTitleController,
              selectedColor: _draftGroupColor,
              onSelectPresetColor: (color) =>
                  setState(() => _draftGroupColor = color),
              onCreate: _createGroup,
            ),
          ),
          crossFadeState: _composerExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
        ),
      ],
    );
  }

  void _createGroup() {
    final title = _groupTitleController.text.trim();
    if (title.isEmpty) return;

    FocusScope.of(context).unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tagGroupController.addGroup(title: title, color: _draftGroupColor);
      _groupTitleController.clear();
      setState(() => _composerExpanded = false);
    });
  }

  Future<void> _editTagGroup(int index) async {
    if (index < 0 || index >= _tagGroupController.groups.length) return;

    final group = _tagGroupController.groups[index];
    final result = await showDialog<_ProjectTagGroupEditData>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (dialogContext) => _ProjectTagGroupEditDialog(
        initialTitle: group.title,
        initialColor: group.color,
      ),
    );
    if (!mounted || result == null) return;

    _tagGroupController.updateGroup(
      groupIndex: index,
      title: result.title,
      color: result.color,
    );
  }

  Future<void> _editTag({
    required int groupIndex,
    required int tagIndex,
  }) async {
    if (groupIndex < 0 || groupIndex >= _tagGroupController.groups.length) {
      return;
    }
    final group = _tagGroupController.groups[groupIndex];
    if (tagIndex < 0 || tagIndex >= group.tags.length) return;

    final tag = group.tags[tagIndex];
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (dialogContext) =>
          _ProjectTagEditDialog(initialLabel: tag.label),
    );
    if (!mounted || result == null) return;

    _tagGroupController.updateTag(
      groupIndex: groupIndex,
      tagIndex: tagIndex,
      label: result,
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

class _ProjectTagGroupDraft {
  final String title;
  Color color;
  final List<NoteTagItem> tags = <NoteTagItem>[];

  _ProjectTagGroupDraft({required this.title, required this.color});
}

class _ProjectTagGroupEditData {
  final String title;
  final Color color;

  const _ProjectTagGroupEditData({required this.title, required this.color});
}

class _ProjectTagGroupComposer extends StatelessWidget {
  final TextEditingController titleController;
  final Color selectedColor;
  final ValueChanged<Color> onSelectPresetColor;
  final VoidCallback onCreate;

  const _ProjectTagGroupComposer({
    required this.titleController,
    required this.selectedColor,
    required this.onSelectPresetColor,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: _ProjectTagInputDecoration.build(
                labelText: 'Nome da classificação',
                prefixIcon: Icons.sell_outlined,
                focusedColor: selectedColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: titleController,
                    builder: (context, value, _) {
                      final label = value.text.trim();
                      return _ProjectTagPreviewChip(
                        label: label.isEmpty
                            ? 'Prévia da classificação'
                            : label,
                        color: selectedColor,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 112,
                  child: _DialogActionButton(
                    label: 'Criar',
                    tint: selectedColor,
                    textColor: Colors.white,
                    onTap: onCreate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Paleta padrão',
              style: TextStyle(
                color: Color(0xFF514752),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            FolderColorPicker(
              selected: selectedColor,
              onSelect: onSelectPresetColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectTagGroupCard extends StatefulWidget {
  final NoteTagGroup group;
  final VoidCallback onRemoveGroup;
  final VoidCallback onEditGroup;
  final ValueChanged<String> onAddTag;
  final void Function({required int tagIndex}) onEditTag;
  final void Function({required int tagIndex}) onRemoveTag;

  const _ProjectTagGroupCard({
    required this.group,
    required this.onRemoveGroup,
    required this.onEditGroup,
    required this.onAddTag,
    required this.onEditTag,
    required this.onRemoveTag,
  });

  @override
  State<_ProjectTagGroupCard> createState() => _ProjectTagGroupCardState();
}

class _ProjectTagGroupCardState extends State<_ProjectTagGroupCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 5,
              decoration: BoxDecoration(
                color: widget.group.color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.group.color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.group.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF3A3339),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onEditGroup,
                      icon: const Icon(Icons.edit_outlined),
                      color: const Color(0xFF7D7179),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      onPressed: () =>
                          setState(() => _isExpanded = !_isExpanded),
                      icon: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                      ),
                      color: const Color(0xFF7D7179),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      onPressed: widget.onRemoveGroup,
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: const Color(0xFFE05E8A),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (
                      var tagIndex = 0;
                      tagIndex < widget.group.tags.length;
                      tagIndex += 1
                    )
                      _ProjectTagChip(
                        label: widget.group.tags[tagIndex].label,
                        color: widget.group.color,
                        onEdit: () => widget.onEditTag(tagIndex: tagIndex),
                        onRemove: () => widget.onRemoveTag(tagIndex: tagIndex),
                      ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 180),
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _InlineProjectTagInput(
                      color: widget.group.color,
                      onSubmit: widget.onAddTag,
                    ),
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectTagChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _ProjectTagChip({
    required this.label,
    required this.color,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 8, 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 4),
          _ProjectTagChipButton(
            icon: Icons.edit_outlined,
            onTap: onEdit,
            color: color,
          ),
          _ProjectTagChipButton(
            icon: Icons.close_rounded,
            onTap: onRemove,
            color: const Color(0xFFE05E8A),
          ),
        ],
      ),
    );
  }
}

class _ProjectTagChipButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ProjectTagChipButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 22,
          height: 22,
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}

class _InlineProjectTagInput extends StatefulWidget {
  final Color color;
  final ValueChanged<String> onSubmit;

  const _InlineProjectTagInput({required this.color, required this.onSubmit});

  @override
  State<_InlineProjectTagInput> createState() => _InlineProjectTagInputState();
}

class _InlineProjectTagInputState extends State<_InlineProjectTagInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    FocusScope.of(context).unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onSubmit(value);
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: _ProjectTagInputDecoration.build(
              labelText: 'Nova tag',
              hintText: 'Adicionar tag a esta classificação',
              prefixIcon: Icons.label_outline_rounded,
              focusedColor: widget.color,
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 46,
          height: 46,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _submit,
              child: Ink(
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.24),
                  ),
                ),
                child: Icon(Icons.add_rounded, color: widget.color),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectTagGroupEditDialog extends StatefulWidget {
  final String initialTitle;
  final Color initialColor;

  const _ProjectTagGroupEditDialog({
    required this.initialTitle,
    required this.initialColor,
  });

  @override
  State<_ProjectTagGroupEditDialog> createState() =>
      _ProjectTagGroupEditDialogState();
}

class _ProjectTagGroupEditDialogState
    extends State<_ProjectTagGroupEditDialog> {
  late final TextEditingController _titleController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    Navigator.of(
      context,
    ).pop(_ProjectTagGroupEditData(title: title, color: _selectedColor));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Editar classificação',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF3A3339),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleController,
              decoration: _ProjectTagInputDecoration.build(
                labelText: 'Nome da classificação',
                prefixIcon: Icons.sell_outlined,
                focusedColor: _selectedColor,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 12),
            _ProjectTagPreviewChip(
              label: _titleController.text.trim().isEmpty
                  ? 'Prévia da classificação'
                  : _titleController.text.trim(),
              color: _selectedColor,
            ),
            const SizedBox(height: 14),
            const Text(
              'Paleta padrão',
              style: TextStyle(
                color: Color(0xFF514752),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            FolderColorPicker(
              selected: _selectedColor,
              onSelect: (color) => setState(() => _selectedColor = color),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DialogActionButton(
                    label: 'Cancelar',
                    tint: Colors.white,
                    textColor: const Color(0xFF514752),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DialogActionButton(
                    label: 'Salvar',
                    tint: _selectedColor,
                    textColor: Colors.white,
                    onTap: _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectTagEditDialog extends StatefulWidget {
  final String initialLabel;

  const _ProjectTagEditDialog({required this.initialLabel});

  @override
  State<_ProjectTagEditDialog> createState() => _ProjectTagEditDialogState();
}

class _ProjectTagEditDialogState extends State<_ProjectTagEditDialog> {
  late final TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.initialLabel);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _save() {
    final label = _labelController.text.trim();
    if (label.isEmpty) return;
    Navigator.of(context).pop(label);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Editar tag',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF3A3339),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _labelController,
              decoration: _ProjectTagInputDecoration.build(
                labelText: 'Nome da tag',
                prefixIcon: Icons.label_outline_rounded,
                focusedColor: const Color(0xFFE85BB8),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DialogActionButton(
                    label: 'Cancelar',
                    tint: Colors.white,
                    textColor: const Color(0xFF514752),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DialogActionButton(
                    label: 'Salvar',
                    tint: const Color(0xFFE85BB8),
                    textColor: Colors.white,
                    onTap: _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectTagPreviewChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ProjectTagPreviewChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectTagInputDecoration {
  static InputDecoration build({
    required String labelText,
    IconData? prefixIcon,
    String? hintText,
    required Color focusedColor,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
    );

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
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

class _CompactActionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CompactActionRow({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.48),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: kNotesPink),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF3A3339),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF7D7179),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  final String label;
  final Color tint;
  final Color textColor;
  final VoidCallback onTap;

  const _DialogActionButton({
    required this.label,
    required this.tint,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint.withValues(alpha: 0.98),
                tint.withValues(alpha: 0.84),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: tint.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
