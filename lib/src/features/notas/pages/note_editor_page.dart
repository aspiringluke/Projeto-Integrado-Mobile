import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/scheduler.dart';

import 'package:projeto_integrado_mobile/src/features/notas/controllers/note_editor_controller.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/note_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';
import 'package:projeto_integrado_mobile/src/features/notas/utils/note_color_resolver.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/notes_visuals.dart';
import 'package:projeto_integrado_mobile/src/features/projects/models/project_tag_data.dart';
import 'package:projeto_integrado_mobile/src/features/shared/story_registry.dart';

class NoteEditorPage extends StatefulWidget {
  final int noteId;

  const NoteEditorPage({super.key, required this.noteId});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final NoteEditorController _controller;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
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
    _descriptionController = TextEditingController();
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
                                labelText: 'Titulo',
                                prefixIcon: const Icon(Icons.title_rounded),
                              ),
                              textInputAction: TextInputAction.done,
                              onChanged: (_) => setState(() {}),
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
                                  )
                                : _MarkdownEditorPane(
                                    key: const ValueKey('editor'),
                                    controller: _descriptionController,
                                    focusNode: _descriptionFocusNode,
                                    scrollController: _editorScrollController,
                                    onChanged: () => setState(() {}),
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

class _NoteAssociationSheet extends StatefulWidget {
  final NoteEditorController controller;

  const _NoteAssociationSheet({required this.controller});

  @override
  State<_NoteAssociationSheet> createState() => _NoteAssociationSheetState();
}

class _NoteAssociationSheetState extends State<_NoteAssociationSheet> {
  late final TextEditingController _groupTitleController;
  late Color _draftGroupColor;
  late HSLColor _draftGroupHsl;
  bool _linksExpanded = true;
  bool _classificationsExpanded = true;
  bool _composerExpanded = false;

  @override
  void initState() {
    super.initState();
    _groupTitleController = TextEditingController();
    _draftGroupColor = projectTagPalette.first;
    _draftGroupHsl = HSLColor.fromColor(_draftGroupColor);
  }

  @override
  void dispose() {
    _groupTitleController.dispose();
    super.dispose();
  }

  void _setDraftGroupColor(Color color) {
    setState(() {
      _draftGroupColor = color;
      _draftGroupHsl = HSLColor.fromColor(color);
    });
  }

  void _setDraftHue(double value) {
    setState(() {
      _draftGroupHsl = _draftGroupHsl.withHue(value);
      _draftGroupColor = _draftGroupHsl.toColor();
    });
  }

  void _setDraftSaturation(double value) {
    setState(() {
      _draftGroupHsl = _draftGroupHsl.withSaturation(value);
      _draftGroupColor = _draftGroupHsl.toColor();
    });
  }

  void _setDraftLightness(double value) {
    setState(() {
      _draftGroupHsl = _draftGroupHsl.withLightness(value);
      _draftGroupColor = _draftGroupHsl.toColor();
    });
  }

  void _createGroup() {
    final title = _groupTitleController.text.trim();
    if (title.isEmpty) return;

    FocusScope.of(context).unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.controller.addTagGroup(title: title, color: _draftGroupColor);
      _groupTitleController.clear();
      setState(() => _composerExpanded = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, StoryRegistry.instance]),
      builder: (context, _) {
        final projects = StoryRegistry.instance.projects;
        final characters = StoryRegistry.instance.characters;
        final selectedProject = widget.controller.linkTarget.projectTitle;
        final currentCharacterName = widget.controller.linkTarget.characterName;
        final filteredCharacters = selectedProject == null
            ? characters
            : characters
                  .where(
                    (character) => character.projectTitle == selectedProject,
                  )
                  .toList(growable: false);
        RegisteredCharacterRef? validCharacterValue;
        try {
          validCharacterValue = filteredCharacters.firstWhere(
            (character) => character.name == currentCharacterName,
          );
        } catch (_) {
          validCharacterValue = null;
        }

        return NotesGlassCard(
          elevated: true,
          radius: 24,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tags e vinculos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kNotesText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const _SheetHint(
                  text:
                      'Use vinculos para contextualizar a nota e classificacoes para organizar tags relacionadas.',
                ),
                const SizedBox(height: 16),
                _SheetSection(
                  title: 'Vinculos',
                  subtitle: _buildLinksSubtitle(
                    projectTitle: selectedProject,
                    characterName: validCharacterValue?.name,
                  ),
                  isExpanded: _linksExpanded,
                  onToggle: () =>
                      setState(() => _linksExpanded = !_linksExpanded),
                  child: _LinksSectionBody(
                    projects: projects,
                    characters: filteredCharacters,
                    selectedProjectTitle: selectedProject,
                    selectedCharacterName: validCharacterValue?.name,
                    onClearProject: () => widget.controller.clearProjectLink(),
                    onSelectProject: (project) {
                      widget.controller.setProjectLink(project.title);
                      widget.controller.clearCharacterLink();
                    },
                    onClearCharacter: () =>
                        widget.controller.clearCharacterLink(),
                    onSelectCharacter: (character) {
                      widget.controller.setCharacterLink(
                        characterName: character.name,
                        projectTitle: character.projectTitle,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _SheetSection(
                  title: 'Classificacoes',
                  subtitle: widget.controller.tagGroups.isEmpty
                      ? 'Nenhuma criada'
                      : '${widget.controller.tagGroups.length} grupo(s)',
                  isExpanded: _classificationsExpanded,
                  onToggle: () => setState(
                    () => _classificationsExpanded = !_classificationsExpanded,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CompactActionRow(
                        label: 'Nova classificacao',
                        icon: Icons.add_rounded,
                        onTap: () => setState(
                          () => _composerExpanded = !_composerExpanded,
                        ),
                      ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 180),
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: _TagGroupComposer(
                            titleController: _groupTitleController,
                            selectedColor: _draftGroupColor,
                            hslColor: _draftGroupHsl,
                            onSelectPresetColor: _setDraftGroupColor,
                            onHueChanged: _setDraftHue,
                            onSaturationChanged: _setDraftSaturation,
                            onLightnessChanged: _setDraftLightness,
                            onCreate: _createGroup,
                          ),
                        ),
                        crossFadeState: _composerExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                      ),
                      const SizedBox(height: 12),
                      if (widget.controller.tagGroups.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Nenhuma classificacao criada ainda.',
                            style: TextStyle(color: kNotesMutedText),
                          ),
                        )
                      else
                        Column(
                          children: [
                            for (
                              var index = 0;
                              index < widget.controller.tagGroups.length;
                              index += 1
                            )
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _TagGroupCard(
                                  group: widget.controller.tagGroups[index],
                                  onRemoveGroup: () =>
                                      widget.controller.removeTagGroup(index),
                                  onAddTag: (value) =>
                                      widget.controller.addTagToGroup(
                                        groupIndex: index,
                                        tagLabel: value,
                                      ),
                                  onRemoveTag: ({required int tagIndex}) {
                                    widget.controller.removeTagFromGroup(
                                      groupIndex: index,
                                      tagIndex: tagIndex,
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TagGroupCard extends StatefulWidget {
  final NoteTagGroup group;
  final VoidCallback onRemoveGroup;
  final ValueChanged<String> onAddTag;
  final void Function({required int tagIndex}) onRemoveTag;

  const _TagGroupCard({
    required this.group,
    required this.onRemoveGroup,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  @override
  State<_TagGroupCard> createState() => _TagGroupCardState();
}

class _TagGroupCardState extends State<_TagGroupCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return NotesGlassCard(
      radius: 18,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                        style: const TextStyle(
                          color: kNotesText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          setState(() => _isExpanded = !_isExpanded),
                      icon: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                      ),
                      color: kNotesMutedText,
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
                      _TagChip(
                        label: widget.group.tags[tagIndex].label,
                        color: widget.group.color,
                        onRemove: () => widget.onRemoveTag(tagIndex: tagIndex),
                      ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 180),
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _InlineTagInput(
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

class _SheetSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  const _SheetSection({
    required this.title,
    required this.subtitle,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return NotesGlassCard(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: kNotesText,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: kNotesMutedText,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: kNotesMutedText,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: child,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }
}

class _LinksSectionBody extends StatelessWidget {
  final List<RegisteredProjectRef> projects;
  final List<RegisteredCharacterRef> characters;
  final String? selectedProjectTitle;
  final String? selectedCharacterName;
  final VoidCallback onClearProject;
  final ValueChanged<RegisteredProjectRef> onSelectProject;
  final VoidCallback onClearCharacter;
  final ValueChanged<RegisteredCharacterRef> onSelectCharacter;

  const _LinksSectionBody({
    required this.projects,
    required this.characters,
    required this.selectedProjectTitle,
    required this.selectedCharacterName,
    required this.onClearProject,
    required this.onSelectProject,
    required this.onClearCharacter,
    required this.onSelectCharacter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SheetHint(
          text:
              'Vincule a nota a um projeto ou personagem para manter contexto narrativo e visual.',
        ),
        const SizedBox(height: 10),
        const Text(
          'Projeto',
          style: TextStyle(color: kNotesPlum, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (projects.isEmpty)
          const Text(
            'Nenhum projeto disponivel.',
            style: TextStyle(color: kNotesMutedText, fontSize: 13),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AssociationChoiceChip(
                label: 'Sem vinculo',
                isSelected: selectedProjectTitle == null,
                color: const Color(0xFF8B93A8),
                onTap: onClearProject,
              ),
              ...projects.map(
                (project) => _AssociationChoiceChip(
                  label: project.title,
                  isSelected: selectedProjectTitle == project.title,
                  color: project.accentColor,
                  onTap: () => onSelectProject(project),
                ),
              ),
            ],
          ),
        const SizedBox(height: 14),
        const Text(
          'Personagem',
          style: TextStyle(color: kNotesPlum, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (selectedProjectTitle == null)
          const Text(
            'Selecione um projeto para escolher um personagem.',
            style: TextStyle(color: kNotesMutedText, fontSize: 13),
          )
        else if (characters.isEmpty)
          const Text(
            'Esse projeto ainda nao possui personagens registrados.',
            style: TextStyle(color: kNotesMutedText, fontSize: 13),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AssociationChoiceChip(
                label: 'Sem vinculo',
                isSelected: selectedCharacterName == null,
                color: const Color(0xFF8B93A8),
                onTap: onClearCharacter,
              ),
              ...characters.map(
                (character) => _AssociationChoiceChip(
                  label: character.name,
                  isSelected: selectedCharacterName == character.name,
                  color: character.accentColor,
                  onTap: () => onSelectCharacter(character),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _AssociationChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _AssociationChoiceChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: color.withValues(alpha: isSelected ? 0.92 : 0.24),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(Icons.check_rounded, size: 14, color: color),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : kNotesText,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
              const Expanded(
                child: Text(
                  'Nova classificacao',
                  style: TextStyle(
                    color: kNotesText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: kNotesMutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagGroupComposer extends StatelessWidget {
  final TextEditingController titleController;
  final Color selectedColor;
  final HSLColor hslColor;
  final ValueChanged<Color> onSelectPresetColor;
  final ValueChanged<double> onHueChanged;
  final ValueChanged<double> onSaturationChanged;
  final ValueChanged<double> onLightnessChanged;
  final VoidCallback onCreate;

  const _TagGroupComposer({
    required this.titleController,
    required this.selectedColor,
    required this.hslColor,
    required this.onSelectPresetColor,
    required this.onHueChanged,
    required this.onSaturationChanged,
    required this.onLightnessChanged,
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
            const _SheetHint(
              text:
                  'Classificacoes separam tags por intencao e deixam a nota mais facil de localizar depois.',
            ),
            const SizedBox(height: 10),
            TextField(
              controller: titleController,
              decoration: notesInputDecoration(
                labelText: 'Nome da classificacao',
                prefixIcon: const Icon(Icons.sell_outlined),
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
                      return _ClassificationPreviewChip(
                        label: label.isEmpty
                            ? 'Preview da classificacao'
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
              'Paleta padrao',
              style: TextStyle(color: kNotesPlum, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: projectTagPalette
                  .map(
                    (color) => _TagColorSwatch(
                      color: color,
                      isSelected: _sameColor(selectedColor, color),
                      onTap: () => onSelectPresetColor(color),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 14),
            _CompactHslEditor(
              color: selectedColor,
              hslColor: hslColor,
              onHueChanged: onHueChanged,
              onSaturationChanged: onSaturationChanged,
              onLightnessChanged: onLightnessChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassificationPreviewChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ClassificationPreviewChip({required this.label, required this.color});

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

class _TagColorSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.88),
              width: isSelected ? 2.2 : 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isSelected ? 0.3 : 0.14),
                blurRadius: isSelected ? 12 : 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: isSelected
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

class _CompactHslEditor extends StatelessWidget {
  final Color color;
  final HSLColor hslColor;
  final ValueChanged<double> onHueChanged;
  final ValueChanged<double> onSaturationChanged;
  final ValueChanged<double> onLightnessChanged;

  const _CompactHslEditor({
    required this.color,
    required this.hslColor,
    required this.onHueChanged,
    required this.onSaturationChanged,
    required this.onLightnessChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cor personalizada',
          style: TextStyle(color: kNotesPlum, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Container(
          height: 28,
          decoration: BoxDecoration(
            gradient: _buildAccentPreviewGradient(color),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
          ),
        ),
        const SizedBox(height: 8),
        _HslSliderField(
          label: 'Matiz',
          value: hslColor.hue,
          min: 0,
          max: 360,
          gradient: _buildHueGradient(),
          onChanged: onHueChanged,
        ),
        _HslSliderField(
          label: 'Saturacao',
          value: hslColor.saturation,
          min: 0,
          max: 1,
          gradient: _buildSaturationGradient(hslColor),
          onChanged: onSaturationChanged,
        ),
        _HslSliderField(
          label: 'Luminosidade',
          value: hslColor.lightness,
          min: 0,
          max: 1,
          gradient: _buildLightnessGradient(hslColor),
          onChanged: onLightnessChanged,
        ),
      ],
    );
  }
}

class _HslSliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final Gradient gradient;
  final ValueChanged<double> onChanged;

  const _HslSliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.gradient,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const thumbRadius = 8.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF514752),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              max == 1 ? value.toStringAsFixed(2) : value.toStringAsFixed(1),
              style: const TextStyle(color: Color(0xFF7A7079), fontSize: 11.5),
            ),
          ],
        ),
        const SizedBox(height: 1),
        SizedBox(
          height: 27,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: thumbRadius),
                  child: Center(
                    child: Container(
                      height: 9,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.72),
                          width: 0.9,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 18,
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: const Color(0xFFDF6EB8),
                  overlayColor: const Color(0xFFDF6EB8).withValues(alpha: 0.14),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: thumbRadius,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

LinearGradient _buildAccentPreviewGradient(Color accentColor) {
  final hsl = HSLColor.fromColor(accentColor);
  final lighter = hsl
      .withLightness((hsl.lightness + 0.18).clamp(0.0, 1.0))
      .toColor();

  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.alphaBlend(
        lighter.withValues(alpha: 0.18),
        Colors.white.withValues(alpha: 0.84),
      ),
      Colors.white.withValues(alpha: 0.78),
      Color.alphaBlend(
        accentColor.withValues(alpha: 0.22),
        const Color(0xFFF9F1F5),
      ),
    ],
    stops: const [0.0, 0.52, 1.0],
  );
}

LinearGradient _buildHueGradient() {
  return const LinearGradient(
    colors: [
      Color(0xFFFF6B8B),
      Color(0xFFFFA65A),
      Color(0xFFF3DE67),
      Color(0xFF74D680),
      Color(0xFF5EC8E5),
      Color(0xFF7C88FF),
      Color(0xFFC676E8),
      Color(0xFFFF6B8B),
    ],
  );
}

LinearGradient _buildSaturationGradient(HSLColor color) {
  return LinearGradient(
    colors: [
      color.withSaturation(0).toColor(),
      color.withSaturation(1).toColor(),
    ],
  );
}

LinearGradient _buildLightnessGradient(HSLColor color) {
  return LinearGradient(
    colors: [Colors.black, color.withLightness(0.5).toColor(), Colors.white],
  );
}

bool _sameColor(Color a, Color b) => a.toARGB32() == b.toARGB32();

String _buildLinksSubtitle({
  required String? projectTitle,
  required String? characterName,
}) {
  if (projectTitle == null && characterName == null) {
    return 'Sem vinculos';
  }
  if (projectTitle != null && characterName != null) {
    return '$projectTitle -> $characterName';
  }
  return projectTitle ?? characterName ?? 'Sem vinculos';
}

class _InlineTagInput extends StatefulWidget {
  final Color color;
  final ValueChanged<String> onSubmit;

  const _InlineTagInput({required this.color, required this.onSubmit});

  @override
  State<_InlineTagInput> createState() => _InlineTagInputState();
}

class _InlineTagInputState extends State<_InlineTagInput> {
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
            decoration: notesInputDecoration(
              labelText: 'Nova tag',
              hintText: 'Adicionar tag a esta classificacao',
              prefixIcon: Icon(
                Icons.label_outline_rounded,
                color: widget.color,
              ),
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

class _EditorContextCard extends StatelessWidget {
  final Color accent;
  final NoteMetadata metadata;
  final bool isPreviewMode;
  final VoidCallback onSelectWrite;
  final VoidCallback onSelectPreview;
  final VoidCallback onEditAssociations;

  const _EditorContextCard({
    required this.accent,
    required this.metadata,
    required this.isPreviewMode,
    required this.onSelectWrite,
    required this.onSelectPreview,
    required this.onEditAssociations,
  });

  @override
  Widget build(BuildContext context) {
    return NotesGlassCard(
      accentColor: accent,
      elevated: true,
      radius: 18,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _EditorModeToggle(
                  isPreviewMode: isPreviewMode,
                  onSelectWrite: onSelectWrite,
                  onSelectPreview: onSelectPreview,
                ),
              ),
              const SizedBox(width: 10),
              _HeaderActionButton(
                icon: Icons.sell_outlined,
                tooltip: 'Editar tags e vinculos',
                onTap: onEditAssociations,
                tint: accent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _NoteSummaryRow(metadata: metadata),
        ],
      ),
    );
  }
}

class _EditorModeToggle extends StatelessWidget {
  final bool isPreviewMode;
  final VoidCallback onSelectWrite;
  final VoidCallback onSelectPreview;

  const _EditorModeToggle({
    required this.isPreviewMode,
    required this.onSelectWrite,
    required this.onSelectPreview,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const indicatorWidth = 28.0;
          final tabWidth = constraints.maxWidth / 2;
          final indicatorLeft =
              (isPreviewMode ? 1 : 0) * tabWidth +
              ((tabWidth - indicatorWidth) / 2);

          return Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ModeToggleButton(
                      label: 'Editar',
                      isSelected: !isPreviewMode,
                      onTap: onSelectWrite,
                    ),
                  ),
                  Expanded(
                    child: _ModeToggleButton(
                      label: 'Visualizar',
                      isSelected: isPreviewMode,
                      onTap: onSelectPreview,
                    ),
                  ),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: indicatorLeft,
                bottom: 2,
                child: IgnorePointer(
                  child: Container(
                    width: indicatorWidth,
                    height: 2.6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEB76AE),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFEB76AE,
                          ).withValues(alpha: 0.26),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? kNotesText : kNotesMutedText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                color: foreground,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkdownPreviewPane extends StatelessWidget {
  final String text;
  final ScrollController scrollController;

  const _MarkdownPreviewPane({
    super.key,
    required this.text,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const SizedBox.expand(
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Nada para visualizar ainda.',
              style: TextStyle(
                color: kNotesMutedText,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: _NotesScrollBox(
        controller: scrollController,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                  child: MarkdownBody(
                    data: text,
                    selectable: false,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
                          p: const TextStyle(
                            color: kNotesText,
                            fontSize: 15,
                            height: 1.5,
                          ),
                          h1: const TextStyle(
                            color: kNotesText,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                          h2: const TextStyle(
                            color: kNotesText,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          h3: const TextStyle(
                            color: kNotesPlum,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          blockquote: const TextStyle(
                            color: kNotesMutedText,
                            fontSize: 14,
                            height: 1.45,
                          ),
                          code: const TextStyle(
                            color: Color(0xFF3A3140),
                            backgroundColor: Color(0x14DF6EB8),
                          ),
                        ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MarkdownEditorPane extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final VoidCallback onChanged;

  const _MarkdownEditorPane({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: _NotesScrollBox(
        controller: scrollController,
        childIsScrollable: true,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          scrollController: scrollController,
          scrollPhysics: const ClampingScrollPhysics(),
          expands: true,
          maxLines: null,
          minLines: null,
          textAlignVertical: TextAlignVertical.top,
          decoration: InputDecoration(
            hintText: 'Markdown é suportado.',
            filled: true,
            fillColor: Colors.transparent,
            hintStyle: TextStyle(
              color: kNotesMutedText.withValues(alpha: 0.72),
              height: 1.4,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
          ),
          style: const TextStyle(color: kNotesText, fontSize: 15, height: 1.5),
          onChanged: (_) => onChanged(),
        ),
      ),
    );
  }
}

class _NotesScrollBox extends StatefulWidget {
  final ScrollController controller;
  final Widget child;
  final bool childIsScrollable;

  const _NotesScrollBox({
    required this.controller,
    required this.child,
    this.childIsScrollable = false,
  });

  @override
  State<_NotesScrollBox> createState() => _NotesScrollBoxState();
}

class _NotesScrollBoxState extends State<_NotesScrollBox> {
  bool _refreshScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refreshScrollbar);
    _scheduleMetricsRefresh();
  }

  @override
  void didUpdateWidget(covariant _NotesScrollBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refreshScrollbar);
      widget.controller.addListener(_refreshScrollbar);
      _scheduleMetricsRefresh();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refreshScrollbar);
    super.dispose();
  }

  void _refreshScrollbar() {
    if (!mounted) return;

    final schedulerPhase = SchedulerBinding.instance.schedulerPhase;
    final canRefreshImmediately =
        schedulerPhase == SchedulerPhase.idle ||
        schedulerPhase == SchedulerPhase.postFrameCallbacks;

    if (canRefreshImmediately) {
      setState(() {});
      return;
    }

    if (_refreshScheduled) return;

    _refreshScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _scheduleMetricsRefresh() {
    _refreshScrollbar();
  }

  @override
  Widget build(BuildContext context) {
    final scrollMetrics = _resolveMetrics();
    final scrollBehavior = const _NotesNoScrollbarBehavior().copyWith(
      scrollbars: false,
      overscroll: false,
    );
    final scrollableChild = NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        _refreshScrollbar();
        return false;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (_) {
          _refreshScrollbar();
          return false;
        },
        child: ScrollConfiguration(
          behavior: scrollBehavior,
          child: widget.childIsScrollable
              ? widget.child
              : SingleChildScrollView(
                  controller: widget.controller,
                  physics: const BouncingScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: widget.child,
                  ),
                ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: scrollableChild,
            ),
            if (scrollMetrics.isVisible)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: _NotesScrollIndicator(
                    height: constraints.maxHeight,
                    metrics: scrollMetrics,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  _NotesScrollMetrics _resolveMetrics() {
    if (!widget.controller.hasClients) {
      return const _NotesScrollMetrics(
        isVisible: false,
        thumbExtent: 0,
        thumbOffset: 0,
      );
    }

    final position = widget.controller.position;
    final viewportExtent = position.viewportDimension;
    final maxScrollExtent = position.maxScrollExtent;

    if (viewportExtent <= 0 || maxScrollExtent <= 0) {
      return const _NotesScrollMetrics(
        isVisible: false,
        thumbExtent: 0,
        thumbOffset: 0,
      );
    }

    final totalContentExtent = viewportExtent + maxScrollExtent;
    final thumbExtent = math.max(
      24.0,
      viewportExtent * (viewportExtent / totalContentExtent),
    );
    final availableOffset = viewportExtent - thumbExtent;
    final scrollFraction = (position.pixels / maxScrollExtent).clamp(0.0, 1.0);

    return _NotesScrollMetrics(
      isVisible: true,
      thumbExtent: thumbExtent,
      thumbOffset: availableOffset * scrollFraction,
    );
  }
}

class _NotesNoScrollbarBehavior extends MaterialScrollBehavior {
  const _NotesNoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class _NotesScrollIndicator extends StatelessWidget {
  final double height;
  final _NotesScrollMetrics metrics;

  const _NotesScrollIndicator({required this.height, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 3,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFD8D3D8),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.only(top: metrics.thumbOffset),
            width: 3,
            height: metrics.thumbExtent.clamp(16.0, height),
            decoration: BoxDecoration(
              color: const Color(0xFFDF6EB8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotesScrollMetrics {
  final bool isVisible;
  final double thumbExtent;
  final double thumbOffset;

  const _NotesScrollMetrics({
    required this.isVisible,
    required this.thumbExtent,
    required this.thumbOffset,
  });
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onRemove;

  const _TagChip({
    required this.label,
    required this.color,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onRemove,
        child: Container(
          padding: const EdgeInsets.only(left: 3, right: 8, top: 3, bottom: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.28), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.14),
                ),
                child: Icon(Icons.close_rounded, size: 14, color: color),
              ),
              const SizedBox(width: 7),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHint extends StatelessWidget {
  final String text;

  const _SheetHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: kNotesMutedText,
          fontSize: 12,
          height: 1.3,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _NoteSummaryRow extends StatelessWidget {
  final NoteMetadata metadata;

  const _NoteSummaryRow({required this.metadata});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (metadata.linkTarget.projectTitle != null) {
      chips.add(
        _SummaryChip(
          label: metadata.linkTarget.projectTitle!,
          icon: Icons.work_outline_rounded,
        ),
      );
    }
    if (metadata.linkTarget.characterName != null) {
      chips.add(
        _SummaryChip(
          label: metadata.linkTarget.characterName!,
          icon: Icons.person_outline_rounded,
        ),
      );
    }
    for (final group in metadata.tagGroups) {
      for (final tag in group.tags) {
        chips.add(
          _SummaryChip(
            label: '${group.title}: ${tag.label}',
            icon: Icons.label_outline_rounded,
            tint: group.color,
          ),
        );
      }
    }

    if (chips.isEmpty) {
      return const Text(
        'Sem tags ou vinculos. Use o icone ao lado para classificar a nota.',
        style: TextStyle(color: kNotesMutedText, fontSize: 12.5, height: 1.2),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < chips.length; index += 1) ...[
            if (index > 0) const SizedBox(width: 6),
            chips[index],
          ],
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color tint;

  const _SummaryChip({
    required this.label,
    required this.icon,
    this.tint = kNotesPink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: tint),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: tint,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color? tint;

  const _HeaderActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final color = tint ?? kNotesPlum;
    final foreground = onTap == null ? kNotesMutedText : color;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.82),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 18, color: foreground),
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color accentColor;
  final String label;
  final Widget leading;

  const _PrimaryActionButton({
    required this.onPressed,
    required this.accentColor,
    required this.label,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: 0.88),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: kNotesPlum,
                  fontWeight: FontWeight.w700,
                ),
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
