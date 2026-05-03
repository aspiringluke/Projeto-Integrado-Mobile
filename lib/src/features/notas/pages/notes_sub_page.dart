import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/controllers/folder_controller.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/folder_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/folder_list_card.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/note_list_card.dart';

class NotesSubPage extends StatefulWidget {
  const NotesSubPage({super.key});

  @override
  State<NotesSubPage> createState() => _NotesSubPageState();
}

class _NotesSubPageState extends State<NotesSubPage> {
  late final FolderController _folderController;

  @override
  void initState() {
    super.initState();
    _folderController = FolderController(repository: FolderRepository());
    _folderController.loadFolders();
  }

  @override
  void dispose() {
    _folderController.dispose();
    super.dispose();
  }

  Future<void> _showCreateFolderDialog() async {
    final titleController = TextEditingController();
    var selectedColor = const Color(0xFF8C5B79);

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Nova pasta'),
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
                _FolderColorPicker(
                  selected: selectedColor,
                  onSelect: (color) => setState(() => selectedColor = color),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  final result = _folderController.createFolder(
                    titleController.text,
                    selectedColor,
                  );
                  if (result.$1) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                child: const Text('Criar'),
              ),
            ],
          );
        },
      ),
    );

    titleController.dispose();

    if (!mounted || created != true) return;
    _showSnack('Pasta criada com sucesso');
  }

  Future<void> _showRenameFolderDialog(Folder folder) async {
    final folderId = folder.id;
    if (folderId == null) {
      _showSnack('Pasta inválida para edição');
      return;
    }

    final titleController = TextEditingController(text: folder.title);
    var selectedColor = folder.color;

    final updated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Editar pasta'),
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
                _FolderColorPicker(
                  selected: selectedColor,
                  onSelect: (color) => setState(() => selectedColor = color),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  final result = _folderController.updateFolder(
                    folderId,
                    title: titleController.text,
                    color: selectedColor,
                  );
                  if (result.$1) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );

    titleController.dispose();

    if (!mounted || updated != true) return;
    _showSnack('Pasta atualizada');
  }

  Future<void> _confirmDeleteFolder(Folder folder) async {
    final folderId = folder.id;
    if (folderId == null) {
      _showSnack('Pasta inválida para exclusão');
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir pasta'),
        content: Text('Deseja excluir "${folder.title}"?'),
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

    if (shouldDelete != true) return;

    final result = _folderController.deleteFolder(folderId);
    if (!mounted) return;

    if (result.$1) {
      _showSnack('Pasta excluída');
      return;
    }

    _showSnack(result.$2 ?? 'Falha ao excluir pasta');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _folderController,
      builder: (context, _) {
        final folders = _folderController.folders;
        final errorMessage = _folderController.errorMessage;
        const notesInCurrentFolder = <String>[];
        final hasAnyItem = folders.isNotEmpty || notesInCurrentFolder.isNotEmpty;

        return Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: _showCreateFolderDialog,
                icon: const Icon(Icons.create_new_folder_outlined),
                tooltip: 'Nova pasta',
              ),
            ),
            if (_folderController.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              )
            else ...[
              ...folders.map(
                (folder) => FolderListCard(
                  folder: folder,
                  onTap: () {},
                  onRename: () => _showRenameFolderDialog(folder),
                  onDelete: () => _confirmDeleteFolder(folder),
                ),
              ),
              ...notesInCurrentFolder.map(
                (title) => NoteListCard(title: title),
              ),
              if (!hasAnyItem)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    'Crie uma nova pasta ou nota clicando no +',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7C7279),
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _FolderColorPicker extends StatelessWidget {
  final Color selected;
  final ValueChanged<Color> onSelect;

  const _FolderColorPicker({
    required this.selected,
    required this.onSelect,
  });

  static const List<Color> _colors = [
    Color(0xFF8C5B79),
    Color(0xFFDF6EB8),
    Color(0xFF6D7C9B),
    Color(0xFF668F80),
    Color(0xFFA2785C),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: _colors
          .map(
            (color) => GestureDetector(
              onTap: () => onSelect(color),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected == color ? Colors.black : Colors.white,
                    width: selected == color ? 2 : 1,
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
