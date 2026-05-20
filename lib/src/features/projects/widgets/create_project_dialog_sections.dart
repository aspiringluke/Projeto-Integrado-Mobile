import 'package:flutter/material.dart';

import '../../../shared/widgets/synopsis_scroll_box.dart';
import '../controllers/create_project_dialog_controller.dart';
import '../controllers/create_project_dialog_image_controller.dart';
import '../models/create_project_dialog_image_viewport_presets.dart';
import '../models/project_tag_data.dart';
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
  final TextEditingController newTagController;
  final VoidCallback onAddTag;
  final InputDecoration Function({
    required String hintText,
    required Color focusedColor,
  })
  buildInputDecoration;

  const CreateProjectDialogTagsSection({
    super.key,
    required this.controller,
    required this.newTagController,
    required this.onAddTag,
    required this.buildInputDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tags',
              style: TextStyle(
                color: Color(0xFF3A3339),
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const CreateProjectDialogFieldDescription(
              text:
                  'Clique em "+" para cadastrar uma tag no banco de dados. Crie, digite o nome de uma já existente ou toque nas recentes para associá-las ao projeto.',
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (controller.knownTags.isEmpty)
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
              for (final tag in controller.knownTags)
                CreateProjectDialogSelectableTagChip(
                  tag: tag,
                  isSelected: controller.isSelectedTag(tag),
                  onTap: () => controller.toggleTag(tag),
                ),
            ],
          ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: newTagController,
                textInputAction: TextInputAction.done,
                decoration: buildInputDecoration(
                  hintText: 'Nova tag',
                  focusedColor: controller.accentColor,
                ),
                onFieldSubmitted: (_) => onAddTag(),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: onAddTag,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDF6EB8),
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
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: newTagController,
          builder: (context, value, _) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CreateProjectDialogDraftTagPreview(
                  label: value.text.trim().isEmpty
                      ? 'Nova tag'
                      : sanitizeProjectTagLabel(value.text),
                  color: controller.newTagColor,
                ),
                for (final color in projectTagPalette)
                  CreateProjectDialogTagColorSwatch(
                    color: color,
                    isSelected: color == controller.newTagColor,
                    onTap: () => controller.setNewTagColor(color),
                  ),
              ],
            );
          },
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
