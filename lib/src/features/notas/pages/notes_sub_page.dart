import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/controllers/folder_controller.dart';
import 'package:projeto_integrado_mobile/src/features/notas/controllers/note_controller.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/folder_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/note_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note.dart';
import 'package:projeto_integrado_mobile/src/features/notas/utils/notes_dialogs.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/folder_list_card.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/note_list_card.dart';

class NotesSubPage extends StatefulWidget {
  const NotesSubPage({super.key});

  @override
  State<NotesSubPage> createState() => NotesSubPageState();
}

class NotesSubPageState extends State<NotesSubPage> {
  late final FolderController _folderController;
  late final NoteController _noteController;

  @override
  void initState() {
    super.initState();
    _folderController = FolderController(repository: FolderRepository());
    _noteController = NoteController(repository: NoteRepository());
    _folderController.loadFolders();
    _noteController.loadNotes(folderId: null);
  }

  @override
  void dispose() {
    _folderController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> onPrimaryActionPressed() async {
    final selected = await showNotesCreateActionSheet(context);
    if (!mounted || selected == null) return;

    if (selected == NotesCreateAction.note) {
      await _createNoteFlow();
      return;
    }

    await _createFolderFlow();
  }

  Future<void> _createFolderFlow() async {
    final draft = await showFolderFormDialog(context);
    if (!mounted || draft == null) return;

    final result = _folderController.createFolder(draft.title, draft.color);
    if (result.$1) {
      _showSnack('Pasta criada com sucesso');
      return;
    }

    _showSnack(result.$2 ?? 'Falha ao criar pasta');
  }

  Future<void> _createNoteFlow() async {
    final draft = await showNoteFormDialog(context);
    if (!mounted || draft == null) return;

    final result = _noteController.createNote(
      title: draft.title,
      description: draft.description,
      folderId: null,
    );

    if (result.$1) {
      _showSnack('Nota criada com sucesso');
      return;
    }

    _showSnack(result.$2 ?? 'Falha ao criar nota');
  }

  Future<void> _renameFolderFlow(Folder folder) async {
    final folderId = folder.id;
    if (folderId == null) {
      _showSnack('Pasta inválida para edição');
      return;
    }

    final draft = await showFolderFormDialog(
      context,
      title: 'Editar pasta',
      submitLabel: 'Salvar',
      initialTitle: folder.title,
      initialColor: folder.color,
    );

    if (!mounted || draft == null) return;

    final result = _folderController.updateFolder(
      folderId,
      title: draft.title,
      color: draft.color,
    );

    if (result.$1) {
      _showSnack('Pasta atualizada');
      return;
    }

    _showSnack(result.$2 ?? 'Falha ao atualizar pasta');
  }

  Future<void> _deleteFolderFlow(Folder folder) async {
    final folderId = folder.id;
    if (folderId == null) {
      _showSnack('Pasta inválida para exclusão');
      return;
    }

    final shouldDelete = await showDeleteFolderConfirmation(
      context,
      folderTitle: folder.title,
    );
    if (!mounted || !shouldDelete) return;

    final result = _folderController.deleteFolder(folderId);
    if (result.$1) {
      _showSnack('Pasta excluída');
      return;
    }

    _showSnack(result.$2 ?? 'Falha ao excluir pasta');
  }

  Future<void> _moveNoteToFolder({
    required int noteId,
    required int? folderId,
  }) async {
    final result = _noteController.moveNoteToFolder(
      noteId: noteId,
      folderId: folderId,
    );

    if (result.$1) {
      _showSnack('Nota movida com sucesso');
      return;
    }

    _showSnack(result.$2 ?? 'Falha ao mover nota');
  }

  Future<void> _moveNoteByMenuFlow(Note note) async {
    final noteId = note.id;
    if (noteId == null) {
      _showSnack('Nota inválida para mover');
      return;
    }

    final selected = await showMoveNoteToFolderSheet(
      context,
      folders: _folderController.folders,
      currentFolderId: note.idPasta,
    );

    if (!mounted || selected == null) return;

    final targetFolderId = selected == 0 ? null : selected;
    await _moveNoteToFolder(noteId: noteId, folderId: targetFolderId);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_folderController, _noteController]),
      builder: (context, _) {
        final folders = _folderController.folders;
        final notes = _noteController.notes;
        final isLoading = _folderController.isLoading || _noteController.isLoading;
        final errorMessage = _folderController.errorMessage ?? _noteController.errorMessage;

        return Column(
          children: [
            if (isLoading)
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
                  onRename: () => _renameFolderFlow(folder),
                  onDelete: () => _deleteFolderFlow(folder),
                  onAcceptNote: folder.id == null
                      ? null
                      : (noteId) => _moveNoteToFolder(
                            noteId: noteId,
                            folderId: folder.id,
                          ),
                ),
              ),
              ...notes.map((note) {
                final noteId = note.id;
                final card = NoteListCard(
                  title: note.title,
                  onMoveTo: () => _moveNoteByMenuFlow(note),
                );

                if (noteId == null) return card;

                return LongPressDraggable<int>(
                  data: noteId,
                  delay: const Duration(milliseconds: 180),
                  feedback: Material(
                    color: Colors.transparent,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: NoteListCard(
                        title: note.title,
                        showActions: false,
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.35,
                    child: card,
                  ),
                  child: card,
                );
              }),
              if (folders.isEmpty && notes.isEmpty)
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
