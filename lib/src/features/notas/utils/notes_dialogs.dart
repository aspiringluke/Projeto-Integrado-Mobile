import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/folder_color_picker.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/notes_visuals.dart';

enum NotesCreateAction { note, folder }

class FolderFormData {
  final String title;
  final Color color;

  FolderFormData({required this.title, required this.color});
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
          child: Column(
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
                onTap: () => Navigator.of(context).pop(NotesCreateAction.note),
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
            ? 'A pasta "$folderTitle" possui subpastas. Excluir também remove tudo que está dentro.'
            : 'Deseja excluir "$folderTitle"?',
        confirmLabel: 'Excluir',
        confirmColor: const Color(0xFFE05E8A),
      ),
    ),
  );

  return shouldDelete == true;
}

Future<bool> showDeleteNoteConfirmation(
  BuildContext context, {
  required String noteTitle,
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
      ),
    ),
  );

  return shouldDelete == true;
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

  const _FolderFormDialog({
    required this.title,
    required this.submitLabel,
    required this.initialTitle,
    required this.initialColor,
  });

  @override
  State<_FolderFormDialog> createState() => _FolderFormDialogState();
}

class _FolderFormDialogState extends State<_FolderFormDialog> {
  late final TextEditingController _titleController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _titleController.dispose();
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

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
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
                child: _DialogActionButton(
                  label: confirmLabel,
                  tint: confirmColor,
                  textColor: Colors.white,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
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
