import 'package:flutter/material.dart';

import '../../../shared/widgets/synopsis_scroll_box.dart';
import '../../notas/models/note_metadata.dart';
import '../../notas/widgets/folder_color_picker.dart';
import '../../notas/widgets/notes_visuals.dart';
import '../controllers/create_project_dialog_controller.dart';
import '../controllers/create_project_dialog_image_controller.dart';
import '../models/create_project_dialog_image_viewport_presets.dart';
import 'create_project_dialog_image_widgets.dart';
import 'create_project_dialog_support_widgets.dart';
import 'project_color_editor.dart';

class CreateProjectDialogHeader extends StatelessWidget {
  final VoidCallback onClose;

  const CreateProjectDialogHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
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
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded),
          color: const Color(0xFF544959),
        ),
      ],
    );
  }
}

class CreateProjectDialogTitleField extends StatelessWidget {
  final TextEditingController controller;
  final Color focusedColor;
  final InputDecoration Function({
    required String hintText,
    required Color focusedColor,
  })
  buildInputDecoration;

  const CreateProjectDialogTitleField({
    super.key,
    required this.controller,
    required this.focusedColor,
    required this.buildInputDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          controller: controller,
          textInputAction: TextInputAction.next,
          decoration: buildInputDecoration(
            hintText: 'Nome do projeto',
            focusedColor: focusedColor,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Informe um nome para o projeto.';
            }

            return null;
          },
        ),
      ],
    );
  }
}

class CreateProjectDialogSynopsisField extends StatelessWidget {
  final TextEditingController controller;
  final ScrollController scrollController;
  final TextStyle textStyle;
  final double height;
  final Color focusedBorderColor;

  const CreateProjectDialogSynopsisField({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.textStyle,
    required this.height,
    required this.focusedBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Síntese',
          style: TextStyle(
            color: Color(0xFF3A3339),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        EditableSynopsisPanel(
          controller: controller,
          scrollController: scrollController,
          isEditing: true,
          placeholderText: synopsisPlaceholderText,
          textStyle: textStyle,
          height: height,
          panelPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          scrollPadding: const EdgeInsets.only(right: 8),
          fillColor: Colors.white.withValues(alpha: 0.56),
          backgroundGradient: null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.74)),
          focusedBorderColor: focusedBorderColor,
          viewerBuilder: (context, text, style) {
            return Text(text, style: style);
          },
        ),
      ],
    );
  }
}

class CreateProjectDialogTagsSection extends StatelessWidget {
  final CreateProjectDialogController controller;
  final TextEditingController groupTitleController;
  final Color selectedColor;
  final bool composerExpanded;
  final VoidCallback onToggleComposer;
  final ValueChanged<Color> onSelectPresetColor;
  final VoidCallback onCreateGroup;
  final Future<void> Function(int index) onEditGroup;
  final Future<void> Function({required int groupIndex, required int tagIndex})
  onEditTag;

  const CreateProjectDialogTagsSection({
    super.key,
    required this.controller,
    required this.groupTitleController,
    required this.selectedColor,
    required this.composerExpanded,
    required this.onToggleComposer,
    required this.onSelectPresetColor,
    required this.onCreateGroup,
    required this.onEditGroup,
    required this.onEditTag,
  });

  @override
  Widget build(BuildContext context) {
    final groups = controller.tagGroups;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Classificações',
          style: TextStyle(
            color: Color(0xFF3A3339),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        const CreateProjectDialogFieldDescription(
          text:
              'Organize as tags em classificações antes de criar o projeto. Isso mantém a estrutura consistente com o editor de notas.',
        ),
        const SizedBox(height: 8),
        if (groups.isEmpty)
          const CreateProjectDialogInfoSurface(
            child: Text(
              'Nenhuma classificação criada ainda.',
              style: TextStyle(color: Color(0xFF6A6167), fontSize: 12),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < groups.length; index += 1) ...[
                _CreateProjectTagGroupCard(
                  group: groups[index],
                  onRemoveGroup: () => controller.removeGroup(index),
                  onEditGroup: () => onEditGroup(index),
                  onAddTag: (value) => controller.addTagToGroup(
                    groupIndex: index,
                    tagLabel: value,
                  ),
                  onEditTag: ({required int tagIndex}) =>
                      onEditTag(groupIndex: index, tagIndex: tagIndex),
                  onRemoveTag: ({required int tagIndex}) =>
                      controller.removeTagFromGroup(
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
          onTap: onToggleComposer,
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _CreateProjectTagGroupComposer(
              titleController: groupTitleController,
              selectedColor: selectedColor,
              onSelectPresetColor: onSelectPresetColor,
              onCreate: onCreateGroup,
            ),
          ),
          crossFadeState: composerExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
        ),
      ],
    );
  }
}

class CreateProjectDialogColorSection extends StatelessWidget {
  final CreateProjectDialogController controller;

  const CreateProjectDialogColorSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CreateProjectDialogColorTargetChip(
                label: 'Capa',
                color: controller.coverColor,
                gradient: buildCreateProjectDialogCoverPreviewGradient(
                  controller.coverColor,
                  controller.accentColor,
                ),
                swatchGradient: buildCreateProjectDialogCoverPreviewGradient(
                  controller.coverColor,
                  controller.accentColor,
                ),
                isSelected:
                    controller.activeColorTarget ==
                    CreateProjectDialogColorTarget.cover,
                onTap: () => controller.setActiveColorTarget(
                  CreateProjectDialogColorTarget.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CreateProjectDialogColorTargetChip(
                label: 'Realce',
                color: controller.accentColor,
                gradient: buildCreateProjectDialogAccentPreviewGradient(
                  controller.accentColor,
                ),
                swatchGradient: buildCreateProjectDialogAccentPreviewGradient(
                  controller.accentColor,
                ),
                isSelected:
                    controller.activeColorTarget ==
                    CreateProjectDialogColorTarget.accent,
                onTap: () => controller.setActiveColorTarget(
                  CreateProjectDialogColorTarget.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ProjectColorEditor(
          title:
              controller.activeColorTarget ==
                  CreateProjectDialogColorTarget.cover
              ? 'Cor da capa'
              : 'Cor de realce',
          description:
              controller.activeColorTarget ==
                  CreateProjectDialogColorTarget.cover
              ? 'Preenche o topo do cartão.'
              : 'Aplica a base cromática do cartão.',
          color: controller.activeColor,
          accentColor: controller.accentColor,
          hslColor: controller.activeHslColor,
          useSolidCoverPreview:
              controller.activeColorTarget ==
              CreateProjectDialogColorTarget.cover,
          onHueChanged: controller.setActiveHue,
          onSaturationChanged: controller.setActiveSaturation,
          onLightnessChanged: controller.setActiveLightness,
        ),
      ],
    );
  }
}

class CreateProjectDialogImageSection extends StatelessWidget {
  final CreateProjectDialogController controller;
  final CreateProjectDialogImageController imageController;

  const CreateProjectDialogImageSection({
    super.key,
    required this.controller,
    required this.imageController,
  });

  @override
  Widget build(BuildContext context) {
    final coverImage = imageController.coverImage;
    final coverImageName = imageController.coverImageName;

    return CreateProjectDialogCoverImagePickerCard(
      title: 'Imagem da capa',
      description:
          'Escolha uma imagem e ajuste o enquadramento. A moldura mostra a area real da capa; o resto indica o que ficara de fora.',
      imageBytes: coverImage.bytes,
      imageWidth: coverImage.width,
      imageHeight: coverImage.height,
      imageName: coverImageName,
      scale: coverImage.scale,
      offsetX: coverImage.offsetX,
      offsetY: coverImage.offsetY,
      backgroundGradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFFF4EDF2), Color(0xFFEAE2E8), Color(0xFFFFFFFF)],
      ),
      viewportPreset: createProjectDialogCoverViewportPreset,
      emptyStateText: 'Nenhuma imagem selecionada',
      footerNote:
          imageController.imageErrorMessage ??
          'Formatos suportados: JPEG, PNG, GIF e WEBP.',
      onScaleChanged: (value) => imageController.setImageScale(
        CreateProjectDialogColorTarget.cover,
        value,
      ),
      onOffsetChanged: (offsetX, offsetY) => imageController.setImageOffset(
        CreateProjectDialogColorTarget.cover,
        offsetX,
        offsetY,
      ),
      onPick: () =>
          imageController.pickImage(CreateProjectDialogColorTarget.cover),
      onRemove: coverImage.bytes == null
          ? null
          : () => imageController.removeImage(
              CreateProjectDialogColorTarget.cover,
            ),
    );
  }
}

class CreateProjectDialogActionsRow extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const CreateProjectDialogActionsRow({
    super.key,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF514752),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.82)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Cancelar'),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            onPressed: onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDF6EB8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Criar projeto'),
            ),
          ),
        ),
      ],
    );
  }
}

class CreateProjectTagGroupEditData {
  final String title;
  final Color color;

  const CreateProjectTagGroupEditData({
    required this.title,
    required this.color,
  });
}

class _CreateProjectTagGroupComposer extends StatelessWidget {
  final TextEditingController titleController;
  final Color selectedColor;
  final ValueChanged<Color> onSelectPresetColor;
  final VoidCallback onCreate;

  const _CreateProjectTagGroupComposer({
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
                      return CreateProjectDialogDraftTagPreview(
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

class _CreateProjectTagGroupCard extends StatefulWidget {
  final NoteTagGroup group;
  final VoidCallback onRemoveGroup;
  final VoidCallback onEditGroup;
  final ValueChanged<String> onAddTag;
  final void Function({required int tagIndex}) onEditTag;
  final void Function({required int tagIndex}) onRemoveTag;

  const _CreateProjectTagGroupCard({
    required this.group,
    required this.onRemoveGroup,
    required this.onEditGroup,
    required this.onAddTag,
    required this.onEditTag,
    required this.onRemoveTag,
  });

  @override
  State<_CreateProjectTagGroupCard> createState() =>
      _CreateProjectTagGroupCardState();
}

class _CreateProjectTagGroupCardState
    extends State<_CreateProjectTagGroupCard> {
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
                      _CreateProjectTagChip(
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
                    child: _CreateProjectInlineTagInput(
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

class _CreateProjectTagChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _CreateProjectTagChip({
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
          _CreateProjectTagChipButton(
            icon: Icons.edit_outlined,
            onTap: onEdit,
            color: color,
          ),
          _CreateProjectTagChipButton(
            icon: Icons.close_rounded,
            onTap: onRemove,
            color: const Color(0xFFE05E8A),
          ),
        ],
      ),
    );
  }
}

class _CreateProjectTagChipButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _CreateProjectTagChipButton({
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

class _CreateProjectInlineTagInput extends StatefulWidget {
  final Color color;
  final ValueChanged<String> onSubmit;

  const _CreateProjectInlineTagInput({
    required this.color,
    required this.onSubmit,
  });

  @override
  State<_CreateProjectInlineTagInput> createState() =>
      _CreateProjectInlineTagInputState();
}

class _CreateProjectInlineTagInputState
    extends State<_CreateProjectInlineTagInput> {
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

class CreateProjectTagGroupEditDialog extends StatefulWidget {
  final String initialTitle;
  final Color initialColor;

  const CreateProjectTagGroupEditDialog({
    super.key,
    required this.initialTitle,
    required this.initialColor,
  });

  @override
  State<CreateProjectTagGroupEditDialog> createState() =>
      CreateProjectTagGroupEditDialogState();
}

class CreateProjectTagGroupEditDialogState
    extends State<CreateProjectTagGroupEditDialog> {
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
    ).pop(CreateProjectTagGroupEditData(title: title, color: _selectedColor));
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
            _CreateProjectTagPreviewChip(
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

class CreateProjectTagEditDialog extends StatefulWidget {
  final String initialLabel;

  const CreateProjectTagEditDialog({super.key, required this.initialLabel});

  @override
  State<CreateProjectTagEditDialog> createState() =>
      CreateProjectTagEditDialogState();
}

class CreateProjectTagEditDialogState
    extends State<CreateProjectTagEditDialog> {
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

class _CreateProjectTagPreviewChip extends StatelessWidget {
  final String label;
  final Color color;

  const _CreateProjectTagPreviewChip({
    required this.label,
    required this.color,
  });

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
