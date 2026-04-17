import 'package:flutter/material.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../../shared/widgets/synopsis_scroll_box.dart';
import '../models/project_image_data.dart';
import '../models/project_style_defaults.dart';
import '../models/project_tag_data.dart';
import '../utils/project_image_picker.dart';
import 'create_project_dialog_image_widgets.dart';
import 'create_project_dialog_support_widgets.dart';
import 'project_image_transform_view.dart';
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
  final List<ProjectTagData> tags;
  final Color coverColor;
  final Color accentColor;
  final ProjectImageData coverImage;
  final ProjectImageData accentImage;

  const CreateProjectTextDraft({
    required this.title,
    required this.synopsis,
    required this.tags,
    required this.coverColor,
    required this.accentColor,
    this.coverImage = const ProjectImageData(),
    this.accentImage = const ProjectImageData(),
  });
}

class _CreateProjectDialog extends StatefulWidget {
  final List<ProjectTagData> availableTags;

  const _CreateProjectDialog({required this.availableTags});

  @override
  State<_CreateProjectDialog> createState() => _CreateProjectDialogState();
}

enum _ProjectColorTarget { cover, accent }

class _CreateProjectDialogState extends State<_CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _synopsisController;
  late final TextEditingController _newTagController;
  late final ScrollController _contentScrollController;
  late final ScrollController _synopsisScrollController;
  late List<ProjectTagData> _knownTags;
  final Set<String> _selectedTags = <String>{};
  late Color _newTagColor;
  HSLColor _coverColor = HSLColor.fromColor(defaultProjectCoverColor);
  HSLColor _accentColor = HSLColor.fromColor(defaultProjectAccentColor);
  _ProjectColorTarget _activeColorTarget = _ProjectColorTarget.accent;
  Uint8List? _coverImageBytes;
  String? _coverImageName;
  double? _coverImageWidth;
  double? _coverImageHeight;
  double _coverImageScale = 1;
  double _coverImageOffsetX = 0;
  double _coverImageOffsetY = 0;
  Uint8List? _accentImageBytes;
  String? _accentImageName;
  double? _accentImageWidth;
  double? _accentImageHeight;
  double _accentImageScale = 1;
  double _accentImageOffsetX = 0;
  double _accentImageOffsetY = 0;

  static const double _synopsisMaxHeight = 196;

  static const TextStyle _synopsisTextStyle = TextStyle(
    fontSize: 12,
    color: Color(0xFF3A3339),
    height: 1.35,
  );

  Color get _defaultNewTagColor => projectTagColorAt(_knownTags.length);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _synopsisController = TextEditingController();
    _synopsisController.addListener(_onSynopsisTextChanged);
    _newTagController = TextEditingController();
    _contentScrollController = ScrollController();
    _synopsisScrollController = ScrollController();
    _knownTags = List<ProjectTagData>.from(widget.availableTags);
    _newTagColor = _defaultNewTagColor;
  }

  @override
  void dispose() {
    _synopsisController.removeListener(_onSynopsisTextChanged);
    _titleController.dispose();
    _synopsisController.dispose();
    _newTagController.dispose();
    _contentScrollController.dispose();
    _synopsisScrollController.dispose();
    super.dispose();
  }

  void _onSynopsisTextChanged() {
    setState(() {});
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
          color: _newTagColor,
        );

        _knownTags = <ProjectTagData>[..._knownTags, newTag];
        _selectedTags.add(newTag.normalizedLabel);
      }

      _newTagController.clear();
      _newTagColor = _defaultNewTagColor;
    });
  }

  void _submit() {
    if (_newTagController.text.trim().isNotEmpty) {
      _addTagFromInput();
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final selectedTags = _knownTags
        .where((tag) => _selectedTags.contains(tag.normalizedLabel))
        .toList(growable: false);

    Navigator.of(context).pop(
      CreateProjectTextDraft(
        title: _titleController.text.trim(),
        synopsis: _synopsisController.text.trim(),
        tags: selectedTags,
        coverColor: _coverColor.toColor(),
        accentColor: _accentColor.toColor(),
        coverImage: ProjectImageData(
          bytes: _coverImageBytes,
          width: _coverImageWidth,
          height: _coverImageHeight,
          scale: _coverImageScale,
          offsetX: _coverImageOffsetX,
          offsetY: _coverImageOffsetY,
        ),
        accentImage: ProjectImageData(
          bytes: _accentImageBytes,
          width: _accentImageWidth,
          height: _accentImageHeight,
          scale: _accentImageScale,
          offsetX: _accentImageOffsetX,
          offsetY: _accentImageOffsetY,
        ),
      ),
    );
  }

  Future<void> _pickCoverImage() async {
    final result = await pickProjectImage();
    if (result == null) {
      return;
    }

    final imageSize = await _decodeImageSize(result.bytes);
    if (!mounted) {
      return;
    }

    setState(() {
      _coverImageBytes = result.bytes;
      _coverImageName = result.name;
      _coverImageWidth = imageSize.width;
      _coverImageHeight = imageSize.height;
      _coverImageScale = 1;
      _coverImageOffsetX = 0;
      _coverImageOffsetY = 0;
    });
  }

  void _removeCoverImage() {
    setState(() {
      _coverImageBytes = null;
      _coverImageName = null;
      _coverImageWidth = null;
      _coverImageHeight = null;
      _coverImageScale = 1;
      _coverImageOffsetX = 0;
      _coverImageOffsetY = 0;
    });
  }

  Future<void> _pickAccentImage() async {
    final result = await pickProjectImage();
    if (result == null) {
      return;
    }

    final imageSize = await _decodeImageSize(result.bytes);
    if (!mounted) {
      return;
    }

    setState(() {
      _accentImageBytes = result.bytes;
      _accentImageName = result.name;
      _accentImageWidth = imageSize.width;
      _accentImageHeight = imageSize.height;
      _accentImageScale = 1;
      _accentImageOffsetX = 0;
      _accentImageOffsetY = 0;
    });
  }

  void _removeAccentImage() {
    setState(() {
      _accentImageBytes = null;
      _accentImageName = null;
      _accentImageWidth = null;
      _accentImageHeight = null;
      _accentImageScale = 1;
      _accentImageOffsetX = 0;
      _accentImageOffsetY = 0;
    });
  }

  Future<Size> _decodeImageSize(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final size = Size(image.width.toDouble(), image.height.toDouble());
    image.dispose();
    codec.dispose();
    return size;
  }

  ProjectImageViewportMetrics _coverImageMetrics(double scale) {
    return computeProjectImageViewportMetrics(
      viewportSize: Size(
        createProjectDialogCoverViewportPreset.cropReferenceWidth,
        createProjectDialogCoverViewportPreset.cropHeight,
      ),
      imageWidth: _coverImageWidth ?? 0,
      imageHeight: _coverImageHeight ?? 0,
      scale: scale,
    );
  }

  ProjectImageViewportMetrics _accentImageMetrics(double scale) {
    return computeProjectImageViewportMetrics(
      viewportSize: Size(
        createProjectDialogAccentViewportPreset.cropReferenceWidth,
        createProjectDialogAccentViewportPreset.cropHeight,
      ),
      imageWidth: _accentImageWidth ?? 0,
      imageHeight: _accentImageHeight ?? 0,
      scale: scale,
    );
  }

  void _setCoverImageScale(double value) {
    final metrics = _coverImageMetrics(value);

    setState(() {
      _coverImageScale = value;
      _coverImageOffsetX = clampProjectImageOffset(
        _coverImageOffsetX,
        maxTranslation: metrics.maxTranslationX,
      );
      _coverImageOffsetY = clampProjectImageOffset(
        _coverImageOffsetY,
        maxTranslation: metrics.maxTranslationY,
      );
    });
  }

  void _setCoverImageOffset(double dx, double dy) {
    final metrics = _coverImageMetrics(_coverImageScale);

    setState(() {
      _coverImageOffsetX = clampProjectImageOffset(
        dx,
        maxTranslation: metrics.maxTranslationX,
      );
      _coverImageOffsetY = clampProjectImageOffset(
        dy,
        maxTranslation: metrics.maxTranslationY,
      );
    });
  }

  void _setAccentImageScale(double value) {
    final metrics = _accentImageMetrics(value);

    setState(() {
      _accentImageScale = value;
      _accentImageOffsetX = clampProjectImageOffset(
        _accentImageOffsetX,
        maxTranslation: metrics.maxTranslationX,
      );
      _accentImageOffsetY = clampProjectImageOffset(
        _accentImageOffsetY,
        maxTranslation: metrics.maxTranslationY,
      );
    });
  }

  void _setAccentImageOffset(double dx, double dy) {
    final metrics = _accentImageMetrics(_accentImageScale);

    setState(() {
      _accentImageOffsetX = clampProjectImageOffset(
        dx,
        maxTranslation: metrics.maxTranslationX,
      );
      _accentImageOffsetY = clampProjectImageOffset(
        dy,
        maxTranslation: metrics.maxTranslationY,
      );
    });
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
                          Row(
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
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close_rounded),
                                color: const Color(0xFF544959),
                              ),
                            ],
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
                            controller: _titleController,
                            textInputAction: TextInputAction.next,
                            decoration: _buildInputDecoration(
                              hintText: 'Nome do projeto',
                              focusedColor: _accentColor.toColor(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe um nome para o projeto.';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Síntese',
                            style: TextStyle(
                              color: Color(0xFF3A3339),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return EditableSynopsisPanel(
                                controller: _synopsisController,
                                scrollController: _synopsisScrollController,
                                isEditing: true,
                                placeholderText: synopsisPlaceholderText,
                                textStyle: _synopsisTextStyle,
                                height: _calculateSynopsisHeight(
                                  constraints.maxWidth,
                                ),
                                panelPadding: const EdgeInsets.fromLTRB(
                                  12,
                                  8,
                                  12,
                                  8,
                                ),
                                scrollPadding: const EdgeInsets.only(right: 8),
                                fillColor: Colors.white.withValues(alpha: 0.56),
                                backgroundGradient: null,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.74),
                                ),
                                focusedBorderColor: _accentColor.toColor(),
                                viewerBuilder: (context, text, style) {
                                  return Text(text, style: style);
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 12),
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
                          if (_knownTags.isEmpty)
                            CreateProjectDialogInfoSurface(
                              child: const Text(
                                'Nenhuma tag cadastrada ainda.',
                                style: TextStyle(
                                  color: Color(0xFF6A6167),
                                  fontSize: 12,
                                ),
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final tag in _knownTags)
                                  CreateProjectDialogSelectableTagChip(
                                    tag: tag,
                                    isSelected: _selectedTags.contains(
                                      tag.normalizedLabel,
                                    ),
                                    onTap: () => _toggleTag(tag),
                                  ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _newTagController,
                                  textInputAction: TextInputAction.done,
                                  decoration: _buildInputDecoration(
                                    hintText: 'Nova tag',
                                    focusedColor: _accentColor.toColor(),
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
                                    backgroundColor: const Color(0xFFDF6EB8),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add_rounded,
                                    size: 20,
                                  ),
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
                                    : sanitizeProjectTagLabel(
                                        _newTagController.text,
                                      ),
                                color: _newTagColor,
                              ),
                              for (final color in projectTagPalette)
                                CreateProjectDialogTagColorSwatch(
                                  color: color,
                                  isSelected: color == _newTagColor,
                                  onTap: () {
                                    setState(() {
                                      _newTagColor = color;
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: CreateProjectDialogColorTargetChip(
                                  label: 'Capa',
                                  color: _coverColor.toColor(),
                                  gradient:
                                      buildCreateProjectDialogCoverPreviewGradient(
                                        _coverColor.toColor(),
                                      ),
                                  swatchGradient:
                                      buildCreateProjectDialogCoverPreviewGradient(
                                        _coverColor.toColor(),
                                      ),
                                  isSelected:
                                      _activeColorTarget ==
                                      _ProjectColorTarget.cover,
                                  onTap: () {
                                    setState(() {
                                      _activeColorTarget =
                                          _ProjectColorTarget.cover;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CreateProjectDialogColorTargetChip(
                                  label: 'Realce',
                                  color: _accentColor.toColor(),
                                  gradient:
                                      buildCreateProjectDialogAccentPreviewGradient(
                                        _accentColor.toColor(),
                                      ),
                                  swatchGradient:
                                      buildCreateProjectDialogAccentPreviewGradient(
                                        _accentColor.toColor(),
                                      ),
                                  isSelected:
                                      _activeColorTarget ==
                                      _ProjectColorTarget.accent,
                                  onTap: () {
                                    setState(() {
                                      _activeColorTarget =
                                          _ProjectColorTarget.accent;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ProjectColorEditor(
                            title:
                                _activeColorTarget == _ProjectColorTarget.cover
                                ? 'Cor da capa'
                                : 'Cor de realce',
                            description:
                                _activeColorTarget == _ProjectColorTarget.cover
                                ? 'Preenche o topo do cartão.'
                                : 'Aplica a base cromática do cartão.',
                            color:
                                _activeColorTarget == _ProjectColorTarget.cover
                                ? _coverColor.toColor()
                                : _accentColor.toColor(),
                            hslColor:
                                _activeColorTarget == _ProjectColorTarget.cover
                                ? _coverColor
                                : _accentColor,
                            useSolidCoverPreview:
                                _activeColorTarget == _ProjectColorTarget.cover,
                            onHueChanged: (value) {
                              setState(() {
                                if (_activeColorTarget ==
                                    _ProjectColorTarget.cover) {
                                  _coverColor = _coverColor.withHue(value);
                                } else {
                                  _accentColor = _accentColor.withHue(value);
                                }
                              });
                            },
                            onSaturationChanged: (value) {
                              setState(() {
                                if (_activeColorTarget ==
                                    _ProjectColorTarget.cover) {
                                  _coverColor = _coverColor.withSaturation(
                                    value,
                                  );
                                } else {
                                  _accentColor = _accentColor.withSaturation(
                                    value,
                                  );
                                }
                              });
                            },
                            onLightnessChanged: (value) {
                              setState(() {
                                if (_activeColorTarget ==
                                    _ProjectColorTarget.cover) {
                                  _coverColor = _coverColor.withLightness(
                                    value,
                                  );
                                } else {
                                  _accentColor = _accentColor.withLightness(
                                    value,
                                  );
                                }
                              });
                            },
                          ),
                          if (_activeColorTarget ==
                              _ProjectColorTarget.cover) ...[
                            const SizedBox(height: 12),
                            CreateProjectDialogCoverImagePickerCard(
                              title: 'Imagem da capa',
                              description:
                                  'Escolha uma imagem e ajuste o enquadramento. A moldura mostra a área real da capa; o resto indica o que ficará de fora.',
                              imageBytes: _coverImageBytes,
                              imageWidth: _coverImageWidth,
                              imageHeight: _coverImageHeight,
                              imageName: _coverImageName,
                              scale: _coverImageScale,
                              offsetX: _coverImageOffsetX,
                              offsetY: _coverImageOffsetY,
                              backgroundGradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFFF4EDF2),
                                  Color(0xFFEAE2E8),
                                  Color(0xFFFFFFFF),
                                ],
                              ),
                              viewportPreset:
                                  createProjectDialogCoverViewportPreset,
                              emptyStateText: 'Nenhuma imagem selecionada',
                              onScaleChanged: _setCoverImageScale,
                              onOffsetChanged: _setCoverImageOffset,
                              onPick: _pickCoverImage,
                              onRemove: _coverImageBytes == null
                                  ? null
                                  : _removeCoverImage,
                            ),
                          ] else ...[
                            const SizedBox(height: 12),
                            CreateProjectDialogCoverImagePickerCard(
                              title: 'Imagem do realce',
                              description:
                                  'Escolha uma imagem para o fundo do cartão expandido. A cor de realce continua controlando a colorização, a suavização e os gradientes por cima dela.',
                              imageBytes: _accentImageBytes,
                              imageWidth: _accentImageWidth,
                              imageHeight: _accentImageHeight,
                              imageName: _accentImageName,
                              scale: _accentImageScale,
                              offsetX: _accentImageOffsetX,
                              offsetY: _accentImageOffsetY,
                              backgroundGradient:
                                  buildCreateProjectDialogAccentPreviewGradient(
                                    _accentColor.toColor(),
                                  ),
                              viewportPreset:
                                  createProjectDialogAccentViewportPreset,
                              emptyStateText: 'Nenhuma imagem selecionada',
                              onScaleChanged: _setAccentImageScale,
                              onOffsetChanged: _setAccentImageOffset,
                              onPick: _pickAccentImage,
                              onRemove: _accentImageBytes == null
                                  ? null
                                  : _removeAccentImage,
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF514752),
                                    side: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.82,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
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
                                  onPressed: _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFDF6EB8),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
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
