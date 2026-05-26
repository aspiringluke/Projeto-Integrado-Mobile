import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;

import 'package:projeto_integrado_mobile/src/features/notas/controllers/note_editor_controller.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/note_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';
import 'package:projeto_integrado_mobile/src/features/notas/utils/note_color_resolver.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/folder_color_picker.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/notes_visuals.dart';
import 'package:projeto_integrado_mobile/src/features/projects/pages/project_page.dart';
import 'package:projeto_integrado_mobile/src/features/shared/story_registry.dart';
import 'package:projeto_integrado_mobile/src/shared/utils/pt_br_text.dart';
import 'package:projeto_integrado_mobile/src/shared/widgets/synopsis_scroll_box.dart';

part 'note_editor/note_association_sheet.dart';
part 'note_editor/note_association_sheet_widgets.dart';
part 'note_editor/note_editor_content.dart';
part 'note_editor/mention_rendering.dart';
part 'note_editor/note_editor_shared_widgets.dart';

class _MentionGhost {
  final int start;
  final int end;
  final MentionTargetRef target;
  final String suffix;

  const _MentionGhost({
    required this.start,
    required this.end,
    required this.target,
    required this.suffix,
  });
}

class _MentionAutocompleteTextController extends TextEditingController {
  _MentionGhost? _ghost;
  TapGestureRecognizer? ghostTapRecognizer;

  void updateGhost(_MentionGhost? ghost) {
    if (_sameGhost(_ghost, ghost)) return;
    _ghost = ghost;
    notifyListeners();
  }

  bool _sameGhost(_MentionGhost? left, _MentionGhost? right) {
    if (identical(left, right)) return true;
    if (left == null || right == null) return false;
    return left.start == right.start &&
        left.end == right.end &&
        left.target.uri == right.target.uri &&
        left.suffix == right.suffix;
  }

  bool acceptGhostSuggestion() {
    final ghost = _ghost;
    if (ghost == null) return false;

    final insertText = '@${ghost.target.label} ';
    final updatedText = text.replaceRange(ghost.start, ghost.end, insertText);
    value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(
        offset: ghost.start + insertText.length,
      ),
    );
    return true;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = style ?? const TextStyle();
    final ghost = _ghost;
    if (ghost == null) {
      return super.buildTextSpan(
        context: context,
        style: baseStyle,
        withComposing: withComposing,
      );
    }

    if (ghost.start < 0 ||
        ghost.end < ghost.start ||
        ghost.end > text.length ||
        ghost.start > text.length) {
      return super.buildTextSpan(
        context: context,
        style: baseStyle,
        withComposing: withComposing,
      );
    }

    final prefix = text.substring(0, ghost.start);
    final active = text.substring(ghost.start, ghost.end);
    final suffix = text.substring(ghost.end);
    final ghostStyle = baseStyle.copyWith(
      color: ghost.target.accentColor.withValues(alpha: 0.4),
      fontStyle: FontStyle.italic,
    );
    final recognizer = ghostTapRecognizer;

    return TextSpan(
      style: baseStyle,
      children: [
        if (prefix.isNotEmpty) TextSpan(text: prefix),
        if (active.isNotEmpty) TextSpan(text: active),
        if (ghost.suffix.isNotEmpty)
          TextSpan(
            text: ghost.suffix,
            style: ghostStyle,
            recognizer: recognizer,
          ),
        if (suffix.isNotEmpty) TextSpan(text: suffix),
      ],
    );
  }
}

class NoteEditorPage extends StatefulWidget {
  final int noteId;

  const NoteEditorPage({super.key, required this.noteId});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final NoteEditorController _controller;
  late final TextEditingController _titleController;
  late final _MentionAutocompleteTextController _descriptionController;
  final FocusNode _descriptionFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  final ScrollController _previewScrollController = ScrollController();
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    _controller = NoteEditorController(
      repository: NoteRepository(),
      noteId: widget.noteId,
    );
    _titleController = TextEditingController();
    _descriptionController = _MentionAutocompleteTextController();
    _load();
  }

  Future<void> _load() async {
    final result = await _controller.loadNote();
    if (!mounted) return;

    if (!result.$1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.$2 ?? 'Falha ao carregar nota')),
      );
      return;
    }

    _titleController.text = _controller.title;
    _descriptionController.text = _controller.description;
    setState(() {});
  }

  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    _editorScrollController.dispose();
    _previewScrollController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveAndExit() async {
    _controller.setTitle(_titleController.text);
    _controller.setDescription(_descriptionController.text);

    final result = await _controller.save();
    if (!mounted) return;

    if (!result.$1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.$2 ?? 'Falha ao salvar nota')),
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  Future<void> _deleteNote() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: NotesGlassCard(
          elevated: true,
          radius: 24,
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Excluir nota',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kNotesText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Deseja excluir esta nota?',
                textAlign: TextAlign.center,
                style: TextStyle(color: kNotesMutedText, height: 1.35),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _DialogActionButton(
                      label: 'Cancelar',
                      tint: Colors.white,
                      textColor: kNotesPlum,
                      onTap: () => Navigator.of(dialogContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DialogActionButton(
                      label: 'Excluir',
                      tint: const Color(0xFFE05E8A),
                      textColor: Colors.white,
                      onTap: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldDelete == true) {
      final deleted = await _controller.repository.deleteNote(widget.noteId);
      if (!mounted) return;

      if (deleted.$1) {
        Navigator.of(context).pop(true);
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(deleted.$2)));
    }
  }

  Future<void> _openAssociationSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              4,
              16,
              16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: _NoteAssociationSheet(controller: _controller),
          ),
        );
      },
    );
  }

  Future<void> _handleMentionTap(String? href) async {
    if (href == null || href.trim().isEmpty) {
      return;
    }

    final target = StoryRegistry.instance.findMentionTargetByUri(href);
    if (!mounted || target == null) {
      return;
    }

    switch (target.kind) {
      case MentionTargetKind.project:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProjectPage(
              title: target.label,
              accentColor: target.accentColor,
            ),
          ),
        );
        return;
      case MentionTargetKind.character:
        final projectTitle = target.projectTitle?.trim();
        if (projectTitle == null || projectTitle.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Personagem sem projeto vinculado')),
          );
          return;
        }

        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProjectPage(
              title: projectTitle,
              accentColor: target.accentColor,
              initialSection: ProjectSectionId.characters,
            ),
          ),
        );
        return;
      case MentionTargetKind.note:
        final noteId = target.noteId;
        if (noteId == null || noteId <= 0) {
          return;
        }

        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => NoteEditorPage(noteId: noteId),
          ),
        );
        return;
      case MentionTargetKind.folder:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pasta mencionada: ${target.label}')),
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, StoryRegistry.instance]),
      builder: (context, _) {
        final accent = resolveNoteAccentColor(
          metadata: _controller.metadata,
          fallbackColor: _controller.color,
          registry: StoryRegistry.instance,
        );
        return Scaffold(
          backgroundColor: const Color(0xFFF5F1F4),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
              child: _HeaderActionButton(
                icon: Icons.arrow_back_ios_new_rounded,
                tooltip: 'Voltar',
                onTap: () => Navigator.of(context).pop(false),
              ),
            ),
            leadingWidth: 64,
          ),
          body: SafeArea(
            top: false,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF8F5F7), Color(0xFFF2EDF1)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  children: [
                    NotesGlassCard(
                      elevated: true,
                      accentColor: accent,
                      radius: 20,
                      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _titleController,
                              decoration: notesInputDecoration(
                                labelText: 'Título',
                                prefixIcon: const Icon(Icons.title_rounded),
                              ),
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _HeaderActionButton(
                            icon: Icons.delete_outline_rounded,
                            tooltip: 'Excluir nota',
                            onTap: _deleteNote,
                            tint: const Color(0xFFE05E8A),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _EditorContextCard(
                      accent: accent,
                      metadata: _controller.metadata,
                      isPreviewMode: _isPreviewMode,
                      onSelectWrite: () {
                        if (!_isPreviewMode) return;
                        setState(() => _isPreviewMode = false);
                      },
                      onSelectPreview: () {
                        if (_isPreviewMode) return;
                        setState(() => _isPreviewMode = true);
                      },
                      onEditAssociations: _openAssociationSheet,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: NotesGlassCard(
                        elevated: true,
                        accentColor: accent,
                        radius: 20,
                        padding: const EdgeInsets.all(10),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.64),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.72),
                              width: 0.8,
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.topLeft,
                                children: [...previousChildren, ?currentChild],
                              );
                            },
                            child: _isPreviewMode
                                ? _MarkdownPreviewPane(
                                    key: const ValueKey('preview'),
                                    text: _descriptionController.text,
                                    scrollController: _previewScrollController,
                                    onTapLink: _handleMentionTap,
                                  )
                                : _MarkdownEditorPane(
                                    key: const ValueKey('editor'),
                                    controller: _descriptionController,
                                    focusNode: _descriptionFocusNode,
                                    scrollController: _editorScrollController,
                                    onChanged: () {},
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: _PrimaryActionButton(
                        onPressed: _controller.isSaving ? null : _saveAndExit,
                        accentColor: accent,
                        label: _controller.isSaving
                            ? 'Salvando...'
                            : 'Salvar e sair',
                        leading: _controller.isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_rounded, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
