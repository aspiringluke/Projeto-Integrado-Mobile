part of '../notes_dialogs.dart';

class _FolderFormDialog extends StatefulWidget {
  final String title;
  final String submitLabel;
  final String? initialTitle;
  final Color initialColor;
  final NoteMetadata initialMetadata;

  const _FolderFormDialog({
    required this.title,
    required this.submitLabel,
    required this.initialTitle,
    required this.initialColor,
    required this.initialMetadata,
  });

  @override
  State<_FolderFormDialog> createState() => _FolderFormDialogState();
}

class _FolderFormDialogState extends State<_FolderFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _groupTitleController;
  late Color _selectedColor;
  late NoteMetadata _metadata;
  late Color _draftGroupColor;
  bool _composerExpanded = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _groupTitleController = TextEditingController();
    _selectedColor = widget.initialColor;
    _metadata = widget.initialMetadata;
    _draftGroupColor = FolderColorPicker.colors.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _groupTitleController.dispose();
    super.dispose();
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
    setState(() {
      _metadata = _metadata.copyWith(tagGroups: groups);
    });
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
    setState(() {
      _metadata = _metadata.copyWith(tagGroups: groups);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotesGlassCard(
      elevated: true,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kNotesText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: notesInputDecoration(
                labelText: 'Título',
                prefixIcon: const Icon(Icons.edit_note_rounded),
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 14),
            const Text(
              'Cor da pasta',
              style: TextStyle(color: kNotesPlum, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            FolderColorPicker(
              selected: _selectedColor,
              onSelect: (color) => setState(() => _selectedColor = color),
            ),
            const SizedBox(height: 18),
            _SheetSection(
              title: 'Tags',
              subtitle: _folderTagsSummary(_metadata),
              hintText: 'Use tags para classificar esta pasta.',
              isExpanded: true,
              onToggle: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CompactActionRow(
                    label: 'Nova classificação',
                    icon: Icons.add_rounded,
                    onTap: () =>
                        setState(() => _composerExpanded = !_composerExpanded),
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
                        onCreate: () {
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
                          setState(() {
                            _metadata = _metadata.copyWith(tagGroups: groups);
                            _groupTitleController.clear();
                            _composerExpanded = false;
                          });
                        },
                      ),
                    ),
                    crossFadeState: _composerExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                  ),
                  const SizedBox(height: 10),
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
                              onRemoveGroup: () {
                                final groups = _metadata.tagGroups.toList(
                                  growable: true,
                                )..removeAt(index);
                                setState(() {
                                  _metadata = _metadata.copyWith(
                                    tagGroups: groups,
                                  );
                                });
                              },
                              onEditGroup: () => _editGroup(index),
                              onAddTag: (value) {
                                final sanitized = value.trim();
                                if (sanitized.isEmpty) return;

                                final groups = _metadata.tagGroups.toList(
                                  growable: true,
                                );
                                final group = groups[index];
                                if (group.tags.any(
                                  (tag) =>
                                      tag.label.toLowerCase() ==
                                      sanitized.toLowerCase(),
                                )) {
                                  return;
                                }

                                groups[index] = NoteTagGroup(
                                  title: group.title,
                                  color: group.color,
                                  tags: <NoteTagItem>[
                                    ...group.tags,
                                    NoteTagItem(label: sanitized),
                                  ],
                                );
                                setState(() {
                                  _metadata = _metadata.copyWith(
                                    tagGroups: groups,
                                  );
                                });
                              },
                              onEditTag: ({required int tagIndex}) => _editTag(
                                groupIndex: index,
                                tagIndex: tagIndex,
                              ),
                              onRemoveTag: ({required int tagIndex}) {
                                final group = _metadata.tagGroups[index];
                                if (tagIndex < 0 ||
                                    tagIndex >= group.tags.length) {
                                  return;
                                }

                                final groups = _metadata.tagGroups.toList(
                                  growable: true,
                                );
                                final tags = group.tags.toList(growable: true)
                                  ..removeAt(tagIndex);
                                groups[index] = NoteTagGroup(
                                  title: group.title,
                                  color: group.color,
                                  tags: tags,
                                );
                                setState(() {
                                  _metadata = _metadata.copyWith(
                                    tagGroups: groups,
                                  );
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
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
                    label: widget.submitLabel,
                    tint: kNotesPink,
                    textColor: Colors.white,
                    onTap: () => Navigator.of(context).pop(
                      FolderFormData(
                        title: _titleController.text,
                        color: _selectedColor,
                        metadata: _metadata,
                      ),
                    ),
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

class _NoteFormDialog extends StatefulWidget {
  const _NoteFormDialog();

  @override
  State<_NoteFormDialog> createState() => _NoteFormDialogState();
}

class _NoteFormDialogState extends State<_NoteFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotesGlassCard(
      elevated: true,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nova nota',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kNotesText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: notesInputDecoration(
                labelText: 'Título',
                prefixIcon: const Icon(Icons.title_rounded),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: notesInputDecoration(
                labelText: 'Descrição',
                prefixIcon: const Icon(Icons.notes_rounded),
              ),
              maxLines: 4,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 18),
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
                    label: 'Criar',
                    tint: kNotesPink,
                    textColor: Colors.white,
                    onTap: () => Navigator.of(context).pop(
                      NoteFormData(
                        title: _titleController.text,
                        description: _descriptionController.text,
                      ),
                    ),
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
