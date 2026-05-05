import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/folder_color_picker.dart';

enum NotesCreateAction { note, folder }

class FolderFormData {
  final String title;
  final Color color;

  FolderFormData({
    required this.title,
    required this.color,
  });
}

class NoteFormData {
  final String title;
  final String description;

  NoteFormData({
    required this.title,
    required this.description,
  });
}

Future<NotesCreateAction?> showNotesCreateActionSheet(BuildContext context) {
  return showModalBottomSheet<NotesCreateAction>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.note_add_outlined),
            title: const Text('Nova nota'),
            onTap: () => Navigator.of(context).pop(NotesCreateAction.note),
          ),
          ListTile(
            leading: const Icon(Icons.create_new_folder_outlined),
            title: const Text('Nova pasta'),
            onTap: () => Navigator.of(context).pop(NotesCreateAction.folder),
          ),
        ],
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
    builder: (dialogContext) => _FolderFormDialog(
      title: title,
      submitLabel: submitLabel,
      initialTitle: initialTitle,
      initialColor: initialColor,
    ),
  );
}

Future<NoteFormData?> showNoteFormDialog(BuildContext context) {
  return showDialog<NoteFormData>(
    context: context,
    builder: (dialogContext) => const _NoteFormDialog(),
  );
}

Future<bool> showDeleteFolderConfirmation(
  BuildContext context, {
  required String folderTitle,
  required bool hasChildren,
}) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Excluir pasta'),
      content: Text(
        hasChildren
            ? 'A pasta "$folderTitle" possui subpastas. Excluir também removerá todas as subpastas e notas dentro delas. Deseja continuar?'
            : 'Deseja excluir "$folderTitle"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Excluir'),
        ),
      ],
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
    builder: (dialogContext) => AlertDialog(
      title: const Text('Excluir nota'),
      content: Text('Deseja excluir "$noteTitle"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Excluir'),
        ),
      ],
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
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text(
              'Mover para',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Página raiz'),
            enabled: currentFolderId != null,
            onTap: currentFolderId == null
                ? null
                : () => Navigator.of(context).pop(0),
          ),
          ...folders.map(
            (folder) => ListTile(
              leading: Icon(
                Icons.folder_outlined,
                color: folder.color,
              ),
              title: Text(folder.title),
              enabled: folder.id != currentFolderId,
              onTap: folder.id == currentFolderId
                  ? null
                  : () => Navigator.of(context).pop(folder.id),
            ),
          ),
        ],
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
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 12),
            FolderColorPicker(
              selected: _selectedColor,
              onSelect: (color) => setState(() => _selectedColor = color),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            FolderFormData(
              title: _titleController.text,
              color: _selectedColor,
            ),
          ),
          child: Text(widget.submitLabel),
        ),
      ],
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
    return AlertDialog(
      title: const Text('Nova nota'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            NoteFormData(
              title: _titleController.text,
              description: _descriptionController.text,
            ),
          ),
          child: const Text('Criar'),
        ),
      ],
    );
  }
}
