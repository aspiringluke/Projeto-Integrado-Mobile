import 'package:flutter/material.dart';

import '../../../shared/widgets/synopsis_scroll_box.dart';
import '../controllers/create_project_dialog_controller.dart';
import '../controllers/create_project_dialog_image_controller.dart';
import '../models/project_image_data.dart';
import '../models/project_tag_data.dart';
import 'create_project_dialog_sections.dart';

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
    _titleController = TextEditingController();
    _synopsisController = TextEditingController();
    _synopsisController.addListener(_onSynopsisTextChanged);
    _newTagController = TextEditingController();
    _contentScrollController = ScrollController();
    _synopsisScrollController = ScrollController();
    _dialogController = CreateProjectDialogController(
      availableTags: widget.availableTags,
    );
    _imageController = CreateProjectDialogImageController();
    _dialogController.addListener(_onDialogControllerChanged);
    _imageController.addListener(_onImageControllerChanged);
  }

  @override
  void dispose() {
    _imageController.removeListener(_onImageControllerChanged);
    _imageController.dispose();
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

  void _onImageControllerChanged() {
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
        coverImage: _imageController.coverImage,
        accentImage: _imageController.accentImage,
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
                            imageController: _imageController,
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
