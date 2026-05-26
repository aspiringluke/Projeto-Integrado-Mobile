part of '../notes_dialogs.dart';

class _FolderMetadataEditorSheet extends StatefulWidget {
  final NoteMetadata initialMetadata;

  const _FolderMetadataEditorSheet({required this.initialMetadata});

  @override
  State<_FolderMetadataEditorSheet> createState() =>
      _FolderMetadataEditorSheetState();
}

class _FolderMetadataEditorSheetState
    extends State<_FolderMetadataEditorSheet> {
  late NoteMetadata _metadata;
  late final TagGroupController _tagGroupController;
  late final TextEditingController _groupTitleController;
  late Color _draftGroupColor;
  bool _composerExpanded = false;

  @override
  void initState() {
    super.initState();
    _metadata = widget.initialMetadata;
    _tagGroupController = TagGroupController(groups: _metadata.tagGroups);
    _tagGroupController.addListener(_syncTagGroupsToMetadata);
    _groupTitleController = TextEditingController();
    _draftGroupColor = FolderColorPicker.colors.first;
  }

  @override
  void dispose() {
    _tagGroupController.removeListener(_syncTagGroupsToMetadata);
    _tagGroupController.dispose();
    _groupTitleController.dispose();
    super.dispose();
  }

  void _syncTagGroupsToMetadata() {
    _metadata = _metadata.copyWith(tagGroups: _tagGroupController.groups);
    if (mounted) {
      setState(() {});
    }
  }

  void _setProjectLink(String? projectTitle) {
    _metadata = _metadata.copyWith(
      linkTarget: NoteLinkTarget(
        projectTitle: projectTitle == null || projectTitle.trim().isEmpty
            ? null
            : projectTitle.trim(),
        characterName: null,
      ),
    );
    setState(() {});
  }

  void _setCharacterLink({
    required String? characterName,
    required String? projectTitle,
  }) {
    _metadata = _metadata.copyWith(
      linkTarget: NoteLinkTarget(
        projectTitle: projectTitle == null || projectTitle.trim().isEmpty
            ? _metadata.linkTarget.projectTitle
            : projectTitle.trim(),
        characterName: characterName == null || characterName.trim().isEmpty
            ? null
            : characterName.trim(),
      ),
    );
    setState(() {});
  }

  void _clearLinks() {
    _metadata = _metadata.copyWith(linkTarget: const NoteLinkTarget());
    setState(() {});
  }

  void _createGroup() {
    final title = _groupTitleController.text.trim();
    if (title.isEmpty) return;

    _tagGroupController.addGroup(title: title, color: _draftGroupColor);
    _groupTitleController.clear();
    setState(() => _composerExpanded = false);
  }

  void _removeGroup(int index) {
    _tagGroupController.removeGroup(index);
  }

  void _addTagToGroup({required int groupIndex, required String label}) {
    _tagGroupController.addTagToGroup(groupIndex: groupIndex, tagLabel: label);
  }

  void _removeTagFromGroup({required int groupIndex, required int tagIndex}) {
    _tagGroupController.removeTagFromGroup(
      groupIndex: groupIndex,
      tagIndex: tagIndex,
    );
  }

  Future<void> _editGroup(int index) async {
    final groups = _tagGroupController.groups;
    if (index < 0 || index >= groups.length) return;

    final group = groups[index];
    final result = await showDialog<_FolderTagGroupEditData>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (dialogContext) => _FolderTagGroupEditDialog(
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
    final groups = _tagGroupController.groups;
    if (groupIndex < 0 || groupIndex >= groups.length) return;
    final group = groups[groupIndex];
    if (tagIndex < 0 || tagIndex >= group.tags.length) return;

    final tag = group.tags[tagIndex];
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (dialogContext) => _FolderTagEditDialog(initialLabel: tag.label),
    );
    if (!mounted || result == null) return;

    _tagGroupController.updateTag(
      groupIndex: groupIndex,
      tagIndex: tagIndex,
      label: result.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projects = StoryRegistry.instance.projects;
    final characters = StoryRegistry.instance.characters;
    final selectedProject = _metadata.linkTarget.projectTitle;
    final selectedCharacter = _metadata.linkTarget.characterName;
    final filteredCharacters = selectedProject == null
        ? characters
        : characters
              .where((item) => item.projectTitle == selectedProject)
              .toList(growable: false);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.86,
      ),
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
                    'Use vínculos para contexto e tags para classificar a pasta.',
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
                      subtitle: _folderMetadataSummary(_metadata),
                      hintText:
                          'Selecione projeto e personagem para manter o contexto da pasta visível.',
                      isExpanded: true,
                      onToggle: () {},
                      child: _FolderLinksBody(
                        projects: projects,
                        characters: filteredCharacters,
                        selectedProjectTitle: selectedProject,
                        selectedCharacterName: selectedCharacter,
                        onClearProject: _clearLinks,
                        onSelectProject: (project) {
                          _setProjectLink(project.title);
                        },
                        onClearCharacter: () {
                          _setCharacterLink(
                            characterName: null,
                            projectTitle: selectedProject,
                          );
                        },
                        onSelectCharacter: (character) {
                          _setCharacterLink(
                            characterName: character.name,
                            projectTitle: character.projectTitle,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SheetSection(
                      title: 'Classificações',
                      subtitle: _metadata.tagGroups.isEmpty
                          ? 'Nenhuma criada'
                          : ptBrCount(
                              _metadata.tagGroups.length,
                              singular: 'grupo',
                              plural: 'grupos',
                            ),
                      hintText:
                          'Crie grupos para organizar tags por intenção e encontrar depois com mais facilidade.',
                      isExpanded: true,
                      onToggle: () {},
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
                              child: _FolderTagGroupComposer(
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
                          const SizedBox(height: 12),
                          if (_metadata.tagGroups.isEmpty)
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
                                  index < _metadata.tagGroups.length;
                                  index += 1
                                )
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _FolderTagGroupCard(
                                      group: _metadata.tagGroups[index],
                                      onRemoveGroup: () => _removeGroup(index),
                                      onEditGroup: () => _editGroup(index),
                                      onAddTag: (value) => _addTagToGroup(
                                        groupIndex: index,
                                        label: value,
                                      ),
                                      onEditTag: ({required int tagIndex}) =>
                                          _editTag(
                                            groupIndex: index,
                                            tagIndex: tagIndex,
                                          ),
                                      onRemoveTag: ({required int tagIndex}) =>
                                          _removeTagFromGroup(
                                            groupIndex: index,
                                            tagIndex: tagIndex,
                                          ),
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
                      onTap: () => Navigator.of(context).pop(_metadata),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
