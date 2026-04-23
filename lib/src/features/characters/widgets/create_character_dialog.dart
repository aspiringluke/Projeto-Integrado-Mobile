import 'package:flutter/material.dart';

import '../../../shared/widgets/synopsis_scroll_box.dart';
import '../../projects/controllers/create_project_dialog_controller.dart';
import '../../projects/controllers/create_project_dialog_image_controller.dart';
import '../../projects/models/project_image_data.dart';
import '../../projects/widgets/create_project_dialog_image_widgets.dart';
import '../../projects/widgets/create_project_dialog_sections.dart';
import '../../projects/widgets/project_image_transform_view.dart';
import 'character_card_visuals.dart';

Future<CreateCharacterDraft?> showCreateCharacterDialog(
  BuildContext context,
) {
  return showDialog<CreateCharacterDraft>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _CreateCharacterDialog(),
  );
}

class CreateCharacterDraft {
  final String name;
  final String synopsis;
  final Color coverColor;
  final Color accentColor;
  final ProjectImageData profileImage;

  const CreateCharacterDraft({
    required this.name,
    required this.synopsis,
    required this.coverColor,
    required this.accentColor,
    required this.profileImage,
  });
}

class _CreateCharacterDialog extends StatefulWidget {
  const _CreateCharacterDialog();

  @override
  State<_CreateCharacterDialog> createState() => _CreateCharacterDialogState();
}

class _CreateCharacterDialogState extends State<_CreateCharacterDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _synopsisController;
  late final ScrollController _contentScrollController;
  late final ScrollController _synopsisScrollController;
  late final CreateProjectDialogController _dialogController;
  late final CreateProjectDialogImageController _imageController;

  static const double _synopsisMaxHeight = 196;

  static const TextStyle _synopsisTextStyle = TextStyle(
    fontSize: 12,
    color: Color(0xFF3A3339),
    height: 1.35,
  );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _synopsisController = TextEditingController();
    _synopsisController.addListener(_refresh);
    _contentScrollController = ScrollController();
    _synopsisScrollController = ScrollController();
    _dialogController = CreateProjectDialogController(availableTags: const []);
    _dialogController.setActiveColorTarget(CreateProjectDialogColorTarget.accent);
    _imageController = CreateProjectDialogImageController();
    _dialogController.addListener(_refresh);
    _imageController.addListener(_refresh);
  }

  @override
  void dispose() {
    _imageController.removeListener(_refresh);
    _imageController.dispose();
    _dialogController.removeListener(_refresh);
    _dialogController.dispose();
    _synopsisController.removeListener(_refresh);
    _nameController.dispose();
    _synopsisController.dispose();
    _contentScrollController.dispose();
    _synopsisScrollController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
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

    return estimatedHeight.clamp(minimumHeight, _synopsisMaxHeight);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(
      CreateCharacterDraft(
        name: _nameController.text.trim(),
        synopsis: _synopsisController.text.trim(),
        coverColor: _dialogController.coverColor,
        accentColor: _dialogController.accentColor,
        profileImage: _imageController.coverImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.fromLTRB(24, 34, 24, 26),
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
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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
                          _CreateCharacterDialogHeader(
                            onClose: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.94),
                                  const Color(
                                    0xFFDFC7D6,
                                  ).withValues(alpha: 0.82),
                                  Colors.white.withValues(alpha: 0.28),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _CreateCharacterNameField(
                            controller: _nameController,
                            focusedColor: _dialogController.accentColor,
                            buildInputDecoration: _buildInputDecoration,
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return CreateProjectDialogSynopsisField(
                                controller: _synopsisController,
                                scrollController: _synopsisScrollController,
                                textStyle: _synopsisTextStyle,
                                height: _calculateSynopsisHeight(
                                  constraints.maxWidth,
                                ),
                                focusedBorderColor:
                                    _dialogController.accentColor,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _CharacterProfilePhotoSection(
                            imageController: _imageController,
                            coverColor: _dialogController.coverColor,
                            accentColor: _dialogController.accentColor,
                          ),
                          const SizedBox(height: 12),
                          CreateProjectDialogColorSection(
                            controller: _dialogController,
                          ),
                          const SizedBox(height: 12),
                          _CreateCharacterActionsRow(
                            onCancel: () => Navigator.of(context).pop(),
                            onSubmit: _submit,
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

class _CreateCharacterDialogHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _CreateCharacterDialogHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Novo personagem',
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

class _CreateCharacterNameField extends StatelessWidget {
  final TextEditingController controller;
  final Color focusedColor;
  final InputDecoration Function({
    required String hintText,
    required Color focusedColor,
  })
  buildInputDecoration;

  const _CreateCharacterNameField({
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
          'Nome do personagem *',
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
            hintText: 'Nome do personagem',
            focusedColor: focusedColor,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Informe um nome para o personagem.';
            }

            return null;
          },
        ),
      ],
    );
  }
}

class _CharacterProfilePhotoSection extends StatelessWidget {
  final CreateProjectDialogImageController imageController;
  final Color coverColor;
  final Color accentColor;

  const _CharacterProfilePhotoSection({
    required this.imageController,
    required this.coverColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final profileImage = imageController.coverImage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto de perfil',
            style: TextStyle(
              color: Color(0xFF3A3339),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          CreateProjectDialogFieldDescription(
            text:
                'Escolha a imagem principal do personagem. O enquadramento abaixo replica a mesma moldura usada no card.',
          ),
          const SizedBox(height: 8),
          _CharacterProfileImageEditor(
            image: profileImage,
            imageName: imageController.coverImageName,
            coverColor: coverColor,
            accentColor: accentColor,
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
            onRemove: profileImage.bytes == null
                ? null
                : () => imageController.removeImage(
                    CreateProjectDialogColorTarget.cover,
                  ),
          ),
        ],
      ),
    );
  }
}

class _CharacterProfileImageEditor extends StatelessWidget {
  final ProjectImageData image;
  final String? imageName;
  final Color coverColor;
  final Color accentColor;
  final ValueChanged<double> onScaleChanged;
  final void Function(double offsetX, double offsetY) onOffsetChanged;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  const _CharacterProfileImageEditor({
    required this.image,
    required this.imageName,
    required this.coverColor,
    required this.accentColor,
    required this.onScaleChanged,
    required this.onOffsetChanged,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = 22.0;
        final frameWidth = (constraints.maxWidth - (horizontalPadding * 2))
            .clamp(160.0, 230.0)
            .toDouble();
        final frameHeight =
            frameWidth * (characterProfileTileHeight / characterProfileTileWidth);
        final canvasHeight = frameHeight + 44;
        final frameTop = (canvasHeight - frameHeight) / 2;
        final frameLeft = (constraints.maxWidth - frameWidth) / 2;
        final metrics =
            image.bytes != null && image.width != null && image.height != null
            ? computeProjectImageViewportMetrics(
                viewportSize: Size(frameWidth, frameHeight),
                imageWidth: image.width!,
                imageHeight: image.height!,
                scale: image.scale,
              )
            : null;

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
                        coverColor.withValues(alpha: 0.36),
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
                child: image.bytes == null
                    ? Center(
                        child: Text(
                          'Nenhuma foto selecionada',
                          style: TextStyle(
                            color: Colors.black.withValues(alpha: 0.55),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onPanUpdate: (details) {
                          final dx =
                              image.offsetX +
                              ((metrics?.maxTranslationX ?? 0) <= 0
                                  ? 0
                                  : details.delta.dx / metrics!.maxTranslationX);
                          final dy =
                              image.offsetY +
                              ((metrics?.maxTranslationY ?? 0) <= 0
                                  ? 0
                                  : details.delta.dy / metrics!.maxTranslationY);
                          onOffsetChanged(dx, dy);
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
                                    child: Container(
                                      color: Colors.white.withValues(alpha: 0.34),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    height: frameTop,
                                    child: Container(
                                      color: Colors.white.withValues(alpha: 0.34),
                                    ),
                                  ),
                                  Positioned(
                                    left: frameLeft,
                                    top: frameTop,
                                    width: frameWidth,
                                    height: frameHeight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                          topRight: Radius.circular(18),
                                          bottomRight: Radius.circular(18),
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.94,
                                          ),
                                          width: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: frameTop,
                                    bottom: frameTop,
                                    width: frameLeft,
                                    child: Container(
                                      color: Colors.white.withValues(alpha: 0.34),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: frameTop,
                                    bottom: frameTop,
                                    width: frameLeft,
                                    child: Container(
                                      color: Colors.white.withValues(alpha: 0.34),
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
            if (imageName != null) ...[
              const SizedBox(height: 8),
              Text(
                imageName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6A6167),
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (image.bytes != null) ...[
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
                      ),
                      child: Slider(
                        value: image.scale,
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
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPick,
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: Text(
                      image.bytes == null ? 'Escolher foto' : 'Trocar foto',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF514752),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                if (onRemove != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onRemove,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5668),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Remover'),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CreateCharacterActionsRow extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _CreateCharacterActionsRow({
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
            child: const Text('Cancelar'),
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
            child: const Text('Criar personagem'),
          ),
        ),
      ],
    );
  }
}
