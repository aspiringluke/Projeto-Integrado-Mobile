import 'package:flutter/material.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../../shared/widgets/synopsis_scroll_box.dart';
import '../controllers/create_project_dialog_controller.dart';
import '../models/project_image_data.dart';
import '../models/project_tag_data.dart';
import '../utils/project_image_picker.dart';
import 'create_project_dialog_image_widgets.dart';
import 'create_project_dialog_sections.dart';
import 'project_image_transform_view.dart';

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

class _CreateProjectDialogState extends State<_CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _synopsisController;
  late final TextEditingController _newTagController;
  late final ScrollController _contentScrollController;
  late final ScrollController _synopsisScrollController;
  late final CreateProjectDialogController _dialogController;
  ProjectImageData _coverImage = const ProjectImageData();
  String? _coverImageName;
  ProjectImageData _accentImage = const ProjectImageData();
  String? _accentImageName;

  static const double _synopsisMaxHeight = 196;

  static const TextStyle _synopsisTextStyle = TextStyle(
    fontSize: 12,
    color: Color(0xFF3A3339),
    height: 1.35,
  );

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _synopsisController = TextEditingController();
    _synopsisController.addListener(_onSynopsisTextChanged);
    _newTagController = TextEditingController();
    _contentScrollController = ScrollController();
    _synopsisScrollController = ScrollController();
    _dialogController = CreateProjectDialogController(
      availableTags: widget.availableTags,
    );
    _dialogController.addListener(_onDialogControllerChanged);
  }

  @override
  void dispose() {
    _dialogController.removeListener(_onDialogControllerChanged);
    _dialogController.dispose();
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

  void _onDialogControllerChanged() {
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

  void _addTagFromInput() {
    final didAdd = _dialogController.addTagFromInput(_newTagController.text);
    if (didAdd) {
      _newTagController.clear();
      setState(() {});
    }
  }

  void _submit() {
    if (_newTagController.text.trim().isNotEmpty) {
      _addTagFromInput();
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(
      CreateProjectTextDraft(
        title: _titleController.text.trim(),
        synopsis: _synopsisController.text.trim(),
        tags: _dialogController.selectedTags,
        coverColor: _dialogController.coverColor,
        accentColor: _dialogController.accentColor,
        coverImage: _coverImage,
        accentImage: _accentImage,
      ),
    );
  }

  bool _isCoverTarget(CreateProjectDialogColorTarget target) =>
      target == CreateProjectDialogColorTarget.cover;

  ProjectImageData _imageForTarget(CreateProjectDialogColorTarget target) {
    return _isCoverTarget(target) ? _coverImage : _accentImage;
  }

  String? _imageNameForTarget(CreateProjectDialogColorTarget target) {
    return _isCoverTarget(target) ? _coverImageName : _accentImageName;
  }

  void _setImageStateForTarget(
    CreateProjectDialogColorTarget target, {
    required ProjectImageData image,
    required String? imageName,
  }) {
    if (_isCoverTarget(target)) {
      _coverImage = image;
      _coverImageName = imageName;
      return;
    }

    _accentImage = image;
    _accentImageName = imageName;
  }

  CreateProjectDialogImageEditorViewportPreset _viewportPresetForTarget(
    CreateProjectDialogColorTarget target,
  ) {
    return _isCoverTarget(target)
        ? createProjectDialogCoverViewportPreset
        : createProjectDialogAccentViewportPreset;
  }

  Future<void> _pickImage(CreateProjectDialogColorTarget target) async {
    final result = await pickProjectImage();
    if (result == null) {
      return;
    }

    final imageSize = await _decodeImageSize(result.bytes);
    if (!mounted) {
      return;
    }

    setState(() {
      _setImageStateForTarget(
        target,
        image: ProjectImageData(
          bytes: result.bytes,
          width: imageSize.width,
          height: imageSize.height,
        ),
        imageName: result.name,
      );
    });
  }

  void _removeImage(CreateProjectDialogColorTarget target) {
    setState(() {
      _setImageStateForTarget(
        target,
        image: const ProjectImageData(),
        imageName: null,
      );
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

  ProjectImageViewportMetrics _imageMetricsForTarget(
    CreateProjectDialogColorTarget target,
    double scale,
  ) {
    final image = _imageForTarget(target);
    final viewportPreset = _viewportPresetForTarget(target);

    return computeProjectImageViewportMetrics(
      viewportSize: Size(
        viewportPreset.cropReferenceWidth,
        viewportPreset.cropHeight,
      ),
      imageWidth: image.width ?? 0,
      imageHeight: image.height ?? 0,
      scale: scale,
    );
  }

  void _setImageScale(CreateProjectDialogColorTarget target, double value) {
    final metrics = _imageMetricsForTarget(target, value);
    final image = _imageForTarget(target);

    setState(() {
      _setImageStateForTarget(
        target,
        image: ProjectImageData(
          bytes: image.bytes,
          width: image.width,
          height: image.height,
          scale: value,
          offsetX: clampProjectImageOffset(
            image.offsetX,
            maxTranslation: metrics.maxTranslationX,
          ),
          offsetY: clampProjectImageOffset(
            image.offsetY,
            maxTranslation: metrics.maxTranslationY,
          ),
        ),
        imageName: _imageNameForTarget(target),
      );
    });
  }

  void _setImageOffset(
    CreateProjectDialogColorTarget target,
    double dx,
    double dy,
  ) {
    final image = _imageForTarget(target);
    final metrics = _imageMetricsForTarget(target, image.scale);

    setState(() {
      _setImageStateForTarget(
        target,
        image: ProjectImageData(
          bytes: image.bytes,
          width: image.width,
          height: image.height,
          scale: image.scale,
          offsetX: clampProjectImageOffset(
            dx,
            maxTranslation: metrics.maxTranslationX,
          ),
          offsetY: clampProjectImageOffset(
            dy,
            maxTranslation: metrics.maxTranslationY,
          ),
        ),
        imageName: _imageNameForTarget(target),
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
                          CreateProjectDialogHeader(
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
                          CreateProjectDialogTitleField(
                            controller: _titleController,
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
                          CreateProjectDialogTagsSection(
                            controller: _dialogController,
                            newTagController: _newTagController,
                            onAddTag: _addTagFromInput,
                            onTagInputChanged: () => setState(() {}),
                            buildInputDecoration: _buildInputDecoration,
                          ),
                          const SizedBox(height: 10),
                          CreateProjectDialogColorSection(
                            controller: _dialogController,
                          ),
                          const SizedBox(height: 12),
                          CreateProjectDialogImageSection(
                            controller: _dialogController,
                            coverImage: _coverImage,
                            coverImageName: _coverImageName,
                            accentImage: _accentImage,
                            accentImageName: _accentImageName,
                            onScaleChanged: _setImageScale,
                            onOffsetChanged: _setImageOffset,
                            onPickImage: _pickImage,
                            onRemoveImage: _removeImage,
                          ),
                          const SizedBox(height: 12),
                          CreateProjectDialogActionsRow(
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
