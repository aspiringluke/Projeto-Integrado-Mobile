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
}) async {
  final titleController = TextEditingController(text: initialTitle ?? '');
  var selectedColor = initialColor;

  final result = await showDialog<FolderFormData>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 12),
              FolderColorPicker(
                selected: selectedColor,
                onSelect: (color) => setState(() => selectedColor = color),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                FolderFormData(
                  title: titleController.text,
                  color: selectedColor,
                ),
              ),
              child: Text(submitLabel),
            ),
          ],
        );
      },
    ),
  );

  titleController.dispose();
  return result;
}

Future<NoteFormData?> showNoteFormDialog(BuildContext context) async {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final result = await showDialog<NoteFormData>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Nova nota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(
              NoteFormData(
                title: titleController.text,
                description: descriptionController.text,
              ),
            ),
            child: const Text('Criar'),
          ),
        ],
      );
    },
  );

  titleController.dispose();
  descriptionController.dispose();
  return result;
}

Future<bool> showDeleteFolderConfirmation(
  BuildContext context, {
  required String folderTitle,
}) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Excluir pasta'),
      content: Text('Deseja excluir "$folderTitle"?'),
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
