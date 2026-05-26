part of '../note_editor_page.dart';

class _NoteAssociationSheet extends StatefulWidget {
  final NoteEditorController controller;

  const _NoteAssociationSheet({required this.controller});

  @override
  State<_NoteAssociationSheet> createState() => _NoteAssociationSheetState();
}

class _NoteAssociationSheetState extends State<_NoteAssociationSheet> {
  late final TextEditingController _groupTitleController;
  late Color _draftGroupColor;
  bool _linksExpanded = true;
  bool _classificationsExpanded = true;
  bool _composerExpanded = false;

  @override
  void initState() {
    super.initState();
    _groupTitleController = TextEditingController();
    _draftGroupColor = FolderColorPicker.colors.first;
  }

  @override
  void dispose() {
    _groupTitleController.dispose();
    super.dispose();
  }

  void _setDraftGroupColor(Color color) {
    setState(() => _draftGroupColor = color);
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

  Future<void> _editTagGroup(int index) async {
    if (index < 0 || index >= widget.controller.tagGroups.length) return;

    final group = widget.controller.tagGroups[index];
    final result = await showDialog<_TagGroupEditData>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (dialogContext) => _TagGroupEditDialog(
        initialTitle: group.title,
        initialColor: group.color,
      ),
    );
    if (!mounted || result == null) return;

    widget.controller.updateTagGroup(
      groupIndex: index,
      title: result.title,
      color: result.color,
    );
  }

  Future<void> _editTag({
    required int groupIndex,
    required int tagIndex,
  }) async {
    if (groupIndex < 0 || groupIndex >= widget.controller.tagGroups.length) {
      return;
    }

    final group = widget.controller.tagGroups[groupIndex];
    if (tagIndex < 0 || tagIndex >= group.tags.length) return;

    final tag = group.tags[tagIndex];
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (dialogContext) => _TagEditDialog(initialLabel: tag.label),
    );
    if (!mounted || result == null) return;

    widget.controller.updateTag(
      groupIndex: groupIndex,
      tagIndex: tagIndex,
      label: result,
    );
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

        final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.86;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: NotesGlassCard(
            elevated: true,
            radius: 24,
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tags e vínculos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kNotesText,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _HeaderActionButton(
                        icon: Icons.close_rounded,
                        tooltip: 'Fechar',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _SheetHint(
                    text:
                        'Use os vínculos para contexto e as classificações para separar tags sem abrir cada bloco.',
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SheetSection(
                          title: 'Vínculos',
                          subtitle: _buildLinksSubtitle(
                            projectTitle: selectedProject,
                            characterName: validCharacterValue?.name,
                          ),
                          hintText:
                              'Selecione projeto e personagem para manter o contexto da nota visível.',
                          isExpanded: _linksExpanded,
                          onToggle: () =>
                              setState(() => _linksExpanded = !_linksExpanded),
                          child: _LinksSectionBody(
                            projects: projects,
                            characters: filteredCharacters,
                            selectedProjectTitle: selectedProject,
                            selectedCharacterName: validCharacterValue?.name,
                            onClearProject: () =>
                                widget.controller.clearProjectLink(),
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
                          title: 'Classificações',
                          subtitle: widget.controller.tagGroups.isEmpty
                              ? 'Nenhuma criada'
                              : ptBrCount(
                                  widget.controller.tagGroups.length,
                                  singular: 'grupo',
                                  plural: 'grupos',
                                ),
                          hintText:
                              'Crie grupos para organizar tags por intenção e encontrar depois com mais facilidade.',
                          isExpanded: _classificationsExpanded,
                          onToggle: () => setState(
                            () => _classificationsExpanded =
                                !_classificationsExpanded,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _CompactActionRow(
                                label: 'Nova classificação',
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
                                    onSelectPresetColor: _setDraftGroupColor,
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
                                    'Nenhuma classificação criada ainda.',
                                    style: TextStyle(color: kNotesMutedText),
                                  ),
                                )
                              else
                                Column(
                                  children: [
                                    for (
                                      var index = 0;
                                      index <
                                          widget.controller.tagGroups.length;
                                      index += 1
                                    )
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: _TagGroupCard(
                                          group: widget
                                              .controller
                                              .tagGroups[index],
                                          onRemoveGroup: () => widget.controller
                                              .removeTagGroup(index),
                                          onEditGroup: () =>
                                              _editTagGroup(index),
                                          onAddTag: (value) =>
                                              widget.controller.addTagToGroup(
                                                groupIndex: index,
                                                tagLabel: value,
                                              ),
                                          onEditTag:
                                              ({required int tagIndex}) =>
                                                  _editTag(
                                                    groupIndex: index,
                                                    tagIndex: tagIndex,
                                                  ),
                                          onRemoveTag:
                                              ({required int tagIndex}) {
                                                widget.controller
                                                    .removeTagFromGroup(
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
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _DialogActionButton(
                          label: 'OK',
                          tint: kNotesPink,
                          textColor: Colors.white,
                          onTap: () => Navigator.of(context).pop(),
                        ),
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
