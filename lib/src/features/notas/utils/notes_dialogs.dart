import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/models/content_stats.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/folder_color_picker.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/notes_visuals.dart';
import 'package:projeto_integrado_mobile/src/features/shared/story_registry.dart';

enum NotesCreateAction { note, folder }

class FolderFormData {
  final String title;
  final Color color;
  final NoteMetadata metadata;

  FolderFormData({
    required this.title,
    required this.color,
    required this.metadata,
  });
}

class NoteFormData {
  final String title;
  final String description;

  NoteFormData({required this.title, required this.description});
}

Future<NotesCreateAction?> showNotesCreateActionSheet(BuildContext context) {
  return showModalBottomSheet<NotesCreateAction>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.18),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: NotesGlassCard(
          elevated: true,
          radius: 24,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Stack(
            children: [
              Positioned.fill(
                top: 0,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.38),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.72],
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Criar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kNotesText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Escolha o tipo de item para esta camada da história.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kNotesMutedText.withValues(alpha: 0.92),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  NotesActionPill(
                    icon: Icons.note_add_outlined,
                    label: 'Nova nota',
                    onTap: () =>
                        Navigator.of(context).pop(NotesCreateAction.note),
                  ),
                  const SizedBox(height: 10),
                  NotesActionPill(
                    icon: Icons.create_new_folder_outlined,
                    label: 'Nova pasta',
                    onTap: () =>
                        Navigator.of(context).pop(NotesCreateAction.folder),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<FolderFormData?> showFolderFormDialog(
  BuildContext context, {
  String title = 'Nova pasta',
  String submitLabel = 'Criar',
  String? initialTitle,
  Color initialColor = const Color(0xFF8C5B79),
  NoteMetadata initialMetadata = const NoteMetadata(
    tagGroups: <NoteTagGroup>[],
    linkTarget: NoteLinkTarget(),
  ),
}) {
  return showDialog<FolderFormData>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.22),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: _FolderFormDialog(
        title: title,
        submitLabel: submitLabel,
        initialTitle: initialTitle,
        initialColor: initialColor,
        initialMetadata: initialMetadata,
      ),
    ),
  );
}

Future<NoteFormData?> showNoteFormDialog(BuildContext context) {
  return showDialog<NoteFormData>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.22),
    builder: (dialogContext) => const Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: _NoteFormDialog(),
    ),
  );
}

Future<bool> showDeleteFolderConfirmation(
  BuildContext context, {
  required String folderTitle,
  required bool hasChildren,
  int noteCount = 0,
  required ContentStats stats,
}) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.24),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: _ConfirmDialog(
        title: 'Excluir pasta',
        message: hasChildren
            ? 'A pasta "$folderTitle" possui subpastas e $noteCount nota(s). Excluir também remove tudo que está dentro.'
            : 'A pasta "$folderTitle" possui $noteCount nota(s). Deseja excluir e apagar tudo que está salvo dentro?',
        confirmLabel: 'Excluir',
        confirmColor: const Color(0xFFE05E8A),
        confirmRequiresHold: true,
        body: _DeleteMetricsSummary(stats: stats),
      ),
    ),
  );

  return shouldDelete == true;
}

Future<bool> showDeleteNoteConfirmation(
  BuildContext context, {
  required String noteTitle,
  required ContentStats stats,
}) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.24),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: _ConfirmDialog(
        title: 'Excluir nota',
        message: 'Deseja excluir "$noteTitle"?',
        confirmLabel: 'Excluir',
        confirmColor: const Color(0xFFE05E8A),
        body: _DeleteMetricsSummary(stats: stats),
      ),
    ),
  );

  return shouldDelete == true;
}

Future<bool> showDeleteSelectionConfirmation(
  BuildContext context, {
  required int noteCount,
  required int folderCount,
  required int totalNotesAffected,
  required ContentStats stats,
  List<String> noteTitles = const <String>[],
}) async {
  final message = folderCount > 0
      ? 'Você vai excluir $noteCount nota(s) e $folderCount pasta(s), afetando $totalNotesAffected nota(s) no total. A confirmação abaixo também remove o conteúdo dentro das pastas selecionadas.'
      : _buildDeleteNoteMessage(noteCount, noteTitles);
  final shouldDelete = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.24),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: _ConfirmDialog(
        title: 'Excluir selecionados',
        message: message,
        confirmLabel: 'Excluir',
        confirmColor: const Color(0xFFE05E8A),
        confirmRequiresHold: true,
        body: _DeleteMetricsSummary(stats: stats),
      ),
    ),
  );

  return shouldDelete == true;
}

String _buildDeleteNoteMessage(int noteCount, List<String> noteTitles) {
  final titles = noteTitles
      .map((title) => title.trim())
      .where((title) => title.isNotEmpty)
      .toList(growable: false);

  if (noteCount <= 1) {
    final title = titles.isNotEmpty ? titles.first : 'esta nota';
    return 'Deseja excluir "$title"?';
  }

  if (noteCount == 2 && titles.length >= 2) {
    return 'Deseja excluir "${titles[0]}" e "${titles[1]}"?';
  }

  return 'Deseja excluir $noteCount notas?';
}

Future<int?> showMoveNoteToFolderSheet(
  BuildContext context, {
  required List<Folder> folders,
  int? currentFolderId,
}) {
  return showModalBottomSheet<int?>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.18),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: NotesGlassCard(
          elevated: true,
          radius: 24,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Mover para',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kNotesText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              _MoveTargetTile(
                icon: Icons.home_outlined,
                title: 'Página raiz',
                color: kNotesPlum,
                enabled: currentFolderId != null,
                onTap: currentFolderId == null
                    ? null
                    : () => Navigator.of(context).pop(0),
              ),
              const SizedBox(height: 8),
              ...folders.map(
                (folder) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MoveTargetTile(
                    icon: Icons.folder_outlined,
                    title: folder.title,
                    color: folder.color,
                    enabled: folder.id != currentFolderId,
                    onTap: folder.id == currentFolderId
                        ? null
                        : () => Navigator.of(context).pop(folder.id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

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

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final bool confirmRequiresHold;
  final Widget? body;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    this.confirmRequiresHold = false,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    return NotesGlassCard(
      elevated: true,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kNotesText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: kNotesMutedText, height: 1.35),
          ),
          if (body != null) ...[const SizedBox(height: 14), body!],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DialogActionButton(
                  label: 'Cancelar',
                  tint: Colors.white,
                  textColor: kNotesPlum,
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: confirmRequiresHold
                    ? _HoldToConfirmButton(
                        label: confirmLabel,
                        tint: confirmColor,
                        textColor: Colors.white,
                        onConfirmed: () => Navigator.of(context).pop(true),
                      )
                    : _DialogActionButton(
                        label: confirmLabel,
                        tint: confirmColor,
                        textColor: Colors.white,
                        onTap: () => Navigator.of(context).pop(true),
                      ),
              ),
            ],
          ),
          if (confirmRequiresHold) ...[
            const SizedBox(height: 10),
            Text(
              'Segure o botão "$confirmLabel" por 2 segundos para confirmar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kNotesMutedText.withValues(alpha: 0.88),
                fontSize: 12,
                height: 1.25,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeleteMetricsSummary extends StatelessWidget {
  final ContentStats stats;

  const _DeleteMetricsSummary({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        _DeleteSummaryChip(
          icon: Icons.short_text_rounded,
          label: '${formatCompactCount(stats.words)} palavras',
          tint: const Color(0xFF7A5B86),
        ),
        _DeleteSummaryChip(
          icon: Icons.onetwothree_rounded,
          label: '${formatCompactCount(stats.characters)} caracteres',
          tint: const Color(0xFFB05C8D),
        ),
        _DeleteSummaryChip(
          icon: Icons.alternate_email_rounded,
          label: '${formatCompactCount(stats.mentions)} menções',
          tint: const Color(0xFFDA6A9E),
        ),
      ],
    );
  }
}

class _DeleteSummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color tint;

  const _DeleteSummaryChip({
    required this.icon,
    required this.label,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.15)),
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
              fontSize: 11.1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoldToConfirmButton extends StatefulWidget {
  final String label;
  final Color tint;
  final Color textColor;
  final VoidCallback onConfirmed;

  const _HoldToConfirmButton({
    required this.label,
    required this.tint,
    required this.textColor,
    required this.onConfirmed,
  });

  @override
  State<_HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<_HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  static const Duration _holdDuration = Duration(seconds: 2);
  late final AnimationController _controller;
  bool _isHolding = false;
  bool _hasConfirmed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _holdDuration)
      ..addStatusListener(_handleStatusChanged);
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed || _hasConfirmed) {
      return;
    }

    _hasConfirmed = true;
    widget.onConfirmed();
  }

  void _startHold() {
    if (_controller.isAnimating || _hasConfirmed) return;

    setState(() {
      _isHolding = true;
    });

    _controller.forward(from: 0);
  }

  void _cancelHold() {
    if (_hasConfirmed) return;

    if (_controller.isAnimating || _controller.value > 0) {
      _controller.stop();
      _controller.value = 0;
    }

    if (!mounted || !_isHolding) return;

    setState(() {
      _isHolding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _startHold(),
      onPointerUp: (_) => _cancelHold(),
      onPointerCancel: (_) => _cancelHold(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = _controller.value.clamp(0.0, 1.0);
          final fillTint = _isHolding ? const Color(0xFFF16A9A) : widget.tint;
          final fillGlow = Color.alphaBlend(
            const Color(0xFFFFC3D7).withValues(alpha: 0.42),
            fillTint,
          );
          final contentColor = _isHolding
              ? Colors.white.withValues(alpha: 0.98)
              : widget.textColor;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: null,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.tint.withValues(alpha: 0.98),
                      widget.tint.withValues(alpha: 0.84),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: fillGlow.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  fillGlow.withValues(alpha: 0.98),
                                  fillTint.withValues(alpha: 0.88),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 17,
                            color: contentColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.label,
                            style: TextStyle(
                              color: contentColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MoveTargetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final bool enabled;
  final VoidCallback? onTap;

  const _MoveTargetTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.44,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: color.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.16),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: kNotesText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: kNotesMutedText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _folderMetadataSummary(NoteMetadata metadata) {
  if (metadata.tagGroups.isNotEmpty) {
    return '${metadata.tagGroups.length} grupo(s)';
  }

  return 'Sem tags';
}

String _folderTagsSummary(NoteMetadata metadata) {
  if (metadata.tagGroups.isEmpty) {
    return 'Nenhuma classificação criada';
  }

  final tagCount = metadata.tagGroups.fold<int>(
    0,
    (count, group) => count + group.tags.length,
  );

  return tagCount == 0
      ? '${metadata.tagGroups.length} grupo(s)'
      : '${metadata.tagGroups.length} grupo(s), $tagCount tag(s)';
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: kNotesMutedText, size: 20),
          ),
        ),
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? hintText;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  const _SheetSection({
    required this.title,
    required this.subtitle,
    this.hintText,
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
                          if (hintText != null) ...[
                            const SizedBox(height: 8),
                            _SheetHint(text: hintText!),
                          ],
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
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.72),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : kNotesPlum,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
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
          ),
          child: isSelected
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : null,
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
              hintText: 'Adicionar tag a esta classificação',
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

class _SheetHint extends StatelessWidget {
  final String text;

  const _SheetHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8EEF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: kNotesMutedText,
          fontSize: 12,
          height: 1.35,
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _TagChip({
    required this.label,
    required this.color,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 3, top: 3, bottom: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          _TagChipButton(
            icon: Icons.edit_outlined,
            color: color,
            onTap: onEdit,
          ),
          const SizedBox(width: 2),
          _TagChipButton(
            icon: Icons.close_rounded,
            color: color,
            onTap: onRemove,
            destructive: true,
          ),
        ],
      ),
    );
  }
}

class _TagChipButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool destructive;

  const _TagChipButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final tint = destructive ? const Color(0xFFE05E8A) : color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tint.withValues(alpha: 0.12),
          ),
          child: Icon(icon, size: 12, color: tint),
        ),
      ),
    );
  }
}

Future<NoteMetadata?> showFolderMetadataEditorSheet(
  BuildContext context, {
  required NoteMetadata initialMetadata,
}) {
  return showModalBottomSheet<NoteMetadata>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.18),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: _FolderMetadataEditorSheet(initialMetadata: initialMetadata),
      ),
    ),
  );
}

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

