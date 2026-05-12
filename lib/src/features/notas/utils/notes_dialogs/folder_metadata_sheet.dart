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
  late final TextEditingController _groupTitleController;
  late Color _draftGroupColor;
  bool _composerExpanded = false;

  @override
  void initState() {
    super.initState();
    _metadata = widget.initialMetadata;
    _groupTitleController = TextEditingController();
    _draftGroupColor = FolderColorPicker.colors.first;
  }

  @override
  void dispose() {
    _groupTitleController.dispose();
    super.dispose();
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

    final groups = <NoteTagGroup>[
      ..._metadata.tagGroups,
      NoteTagGroup(
        title: title,
        color: _draftGroupColor,
        tags: const <NoteTagItem>[],
      ),
    ];
    _metadata = _metadata.copyWith(tagGroups: groups);
    _groupTitleController.clear();
    setState(() => _composerExpanded = false);
  }

  void _removeGroup(int index) {
    if (index < 0 || index >= _metadata.tagGroups.length) return;
    final groups = _metadata.tagGroups.toList(growable: true)..removeAt(index);
    _metadata = _metadata.copyWith(tagGroups: groups);
    setState(() {});
  }

  void _addTagToGroup({required int groupIndex, required String label}) {
    if (groupIndex < 0 || groupIndex >= _metadata.tagGroups.length) return;
    final sanitized = label.trim();
    if (sanitized.isEmpty) return;

    final groups = _metadata.tagGroups.toList(growable: true);
    final group = groups[groupIndex];
    if (group.tags.any(
      (tag) => tag.label.toLowerCase() == sanitized.toLowerCase(),
    )) {
      return;
    }

    groups[groupIndex] = NoteTagGroup(
      title: group.title,
      color: group.color,
      tags: <NoteTagItem>[
        ...group.tags,
        NoteTagItem(label: sanitized),
      ],
    );
    _metadata = _metadata.copyWith(tagGroups: groups);
    setState(() {});
  }

  void _removeTagFromGroup({required int groupIndex, required int tagIndex}) {
    if (groupIndex < 0 || groupIndex >= _metadata.tagGroups.length) return;
    final group = _metadata.tagGroups[groupIndex];
    if (tagIndex < 0 || tagIndex >= group.tags.length) return;

    final groups = _metadata.tagGroups.toList(growable: true);
    final tags = group.tags.toList(growable: true)..removeAt(tagIndex);
    groups[groupIndex] = NoteTagGroup(
      title: group.title,
      color: group.color,
      tags: tags,
    );
    _metadata = _metadata.copyWith(tagGroups: groups);
    setState(() {});
  }

  Future<void> _editGroup(int index) async {
    if (index < 0 || index >= _metadata.tagGroups.length) return;

    final group = _metadata.tagGroups[index];
    final result = await showDialog<_FolderTagGroupEditData>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (dialogContext) => _FolderTagGroupEditDialog(
        initialTitle: group.title,
        initialColor: group.color,
      ),
    );
    if (!mounted || result == null) return;

    final groups = _metadata.tagGroups.toList(growable: true);
    groups[index] = NoteTagGroup(
      title: result.title,
      color: result.color,
      tags: group.tags,
    );
    _metadata = _metadata.copyWith(tagGroups: groups);
    setState(() {});
  }

  Future<void> _editTag({
    required int groupIndex,
    required int tagIndex,
  }) async {
    if (groupIndex < 0 || groupIndex >= _metadata.tagGroups.length) return;
    final group = _metadata.tagGroups[groupIndex];
    if (tagIndex < 0 || tagIndex >= group.tags.length) return;

    final tag = group.tags[tagIndex];
    final result = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (dialogContext) => _FolderTagEditDialog(initialLabel: tag.label),
    );
    if (!mounted || result == null) return;

    final groups = _metadata.tagGroups.toList(growable: true);
    final tags = group.tags.toList(growable: true);
    tags[tagIndex] = NoteTagItem(label: result.trim());
    groups[groupIndex] = NoteTagGroup(
      title: group.title,
      color: group.color,
      tags: tags,
    );
    _metadata = _metadata.copyWith(tagGroups: groups);
    setState(() {});
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
                          : '${_metadata.tagGroups.length} grupo(s)',
                      hintText:
                          'Crie grupos para organizar tags por intenção e encontrar depois com menos atrito.',
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

class _FolderTagGroupEditData {
  final String title;
  final Color color;

  const _FolderTagGroupEditData({required this.title, required this.color});
}

class _FolderTagGroupEditDialog extends StatefulWidget {
  final String initialTitle;
  final Color initialColor;

  const _FolderTagGroupEditDialog({
    required this.initialTitle,
    required this.initialColor,
  });

  @override
  State<_FolderTagGroupEditDialog> createState() =>
      _FolderTagGroupEditDialogState();
}

class _FolderTagGroupEditDialogState extends State<_FolderTagGroupEditDialog> {
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
    ).pop(_FolderTagGroupEditData(title: title, color: _selectedColor));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
              'Editar classificação',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kNotesText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _titleController,
              decoration: notesInputDecoration(
                labelText: 'Nome da classificação',
                prefixIcon: const Icon(Icons.sell_outlined),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _titleController,
              builder: (context, value, _) {
                final label = value.text.trim();
                return _ClassificationPreviewChip(
                  label: label.isEmpty ? 'Preview' : label,
                  color: _selectedColor,
                );
              },
            ),
            const SizedBox(height: 14),
            const Text(
              'Paleta padrão',
              style: TextStyle(color: kNotesPlum, fontWeight: FontWeight.w700),
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
                    textColor: kNotesPlum,
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

class _FolderTagEditDialog extends StatefulWidget {
  final String initialLabel;

  const _FolderTagEditDialog({required this.initialLabel});

  @override
  State<_FolderTagEditDialog> createState() => _FolderTagEditDialogState();
}

class _FolderTagEditDialogState extends State<_FolderTagEditDialog> {
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
      child: NotesGlassCard(
        elevated: true,
        radius: 24,
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Editar tag',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kNotesText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _labelController,
              decoration: notesInputDecoration(
                labelText: 'Nome da tag',
                prefixIcon: const Icon(Icons.label_outline_rounded),
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
                    textColor: kNotesPlum,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DialogActionButton(
                    label: 'Salvar',
                    tint: kNotesPink,
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

class _FolderLinksBody extends StatelessWidget {
  final List<RegisteredProjectRef> projects;
  final List<RegisteredCharacterRef> characters;
  final String? selectedProjectTitle;
  final String? selectedCharacterName;
  final VoidCallback onClearProject;
  final ValueChanged<RegisteredProjectRef> onSelectProject;
  final VoidCallback onClearCharacter;
  final ValueChanged<RegisteredCharacterRef> onSelectCharacter;

  const _FolderLinksBody({
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
        const Text(
          'Projeto',
          style: TextStyle(color: kNotesPlum, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (projects.isEmpty)
          const Text(
            'Nenhum projeto disponível.',
            style: TextStyle(color: kNotesMutedText, fontSize: 13),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AssociationChoiceChip(
                label: 'Sem vínculo',
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
            'Esse projeto ainda não possui personagens registrados.',
            style: TextStyle(color: kNotesMutedText, fontSize: 13),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AssociationChoiceChip(
                label: 'Sem vínculo',
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

class _FolderTagGroupComposer extends StatelessWidget {
  final TextEditingController titleController;
  final Color selectedColor;
  final ValueChanged<Color> onSelectPresetColor;
  final VoidCallback onCreate;

  const _FolderTagGroupComposer({
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
              decoration: notesInputDecoration(
                labelText: 'Nome da classificação',
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
                        label: label.isEmpty ? 'Preview' : label,
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
              style: TextStyle(color: kNotesPlum, fontWeight: FontWeight.w700),
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

class _FolderTagGroupCard extends StatelessWidget {
  final NoteTagGroup group;
  final VoidCallback onRemoveGroup;
  final VoidCallback onEditGroup;
  final ValueChanged<String> onAddTag;
  final void Function({required int tagIndex}) onEditTag;
  final void Function({required int tagIndex}) onRemoveTag;

  const _FolderTagGroupCard({
    required this.group,
    required this.onRemoveGroup,
    required this.onEditGroup,
    required this.onAddTag,
    required this.onEditTag,
    required this.onRemoveTag,
  });

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
                color: group.color,
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
                        color: group.color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        group.title,
                        style: const TextStyle(
                          color: kNotesText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onEditGroup,
                      icon: const Icon(Icons.edit_outlined),
                      color: kNotesMutedText,
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      onPressed: onRemoveGroup,
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
                      tagIndex < group.tags.length;
                      tagIndex += 1
                    )
                      _TagChip(
                        label: group.tags[tagIndex].label,
                        color: group.color,
                        onEdit: () => onEditTag(tagIndex: tagIndex),
                        onRemove: () => onRemoveTag(tagIndex: tagIndex),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                _InlineTagInput(color: group.color, onSubmit: onAddTag),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
bool _sameColor(Color a, Color b) => a.toARGB32() == b.toARGB32();
