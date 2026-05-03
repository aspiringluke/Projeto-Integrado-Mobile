import 'dart:async';

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
  int? _activeFolderId;
  String? _activeFolderTitle;

  Future<void> _bootstrap() async {
    await _folderController.loadFolders();
    await _noteController.loadNotes(folderId: null);
    if (!mounted) return;
    setState(() {
      _activeFolderId = null;
      _activeFolderTitle = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _folderController = FolderController(repository: FolderRepository());
    _noteController = NoteController(repository: NoteRepository());
    unawaited(_bootstrap());
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

    final result = await _folderController.createFolder(draft.title, draft.color);
    if (result.$1) {
      _showSnack('Pasta criada com sucesso');
      return;
    }

    _showSnack(result.$2 ?? 'Falha ao criar pasta');
  }

  Future<void> _createNoteFlow() async {
    final draft = await showNoteFormDialog(context);
    if (!mounted || draft == null) return;

    final result = await _noteController.createNote(
      title: draft.title,
      description: draft.description,
      folderId: _activeFolderId,
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

    final result = await _folderController.updateFolder(
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

    final result = await _folderController.deleteFolder(folderId);
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
    final result = await _noteController.moveNoteToFolder(
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
      currentFolderId: _activeFolderId,
    );

    if (!mounted || selected == null) return;

    final targetFolderId = selected == 0 ? null : selected;
    await _moveNoteToFolder(noteId: noteId, folderId: targetFolderId);
  }

  Future<void> _openFolder(Folder folder) async {
    final folderId = folder.id;
    if (folderId == null) {
      _showSnack('Pasta inválida');
      return;
    }

    final result = await _noteController.loadNotes(folderId: folderId);
    if (!mounted) return;

    if (!result.$1) {
      _showSnack(result.$2 ?? 'Falha ao abrir pasta');
      return;
    }

    setState(() {
      _activeFolderId = folderId;
      _activeFolderTitle = folder.title;
    });
  }

  Future<void> _backToRoot() async {
    final result = await _noteController.loadNotes(folderId: null);
    if (!mounted) return;

    if (!result.$1) {
      _showSnack(result.$2 ?? 'Falha ao voltar para a raiz');
      return;
    }

    setState(() {
      _activeFolderId = null;
      _activeFolderTitle = null;
    });
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
        final isInsideFolder = _activeFolderId != null;

        return Column(
          children: [
            if (isInsideFolder)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _backToRoot,
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: 'Voltar',
                    ),
                    Expanded(
                      child: Text(
                        _activeFolderTitle ?? 'Pasta',
                        style: const TextStyle(
                          color: Color(0xFF5D535A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
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
              if (!isInsideFolder)
                ...folders.map(
                  (folder) => FolderListCard(
                    folder: folder,
                    onTap: () => _openFolder(folder),
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
              if (notes.isEmpty && (isInsideFolder || folders.isEmpty))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    isInsideFolder
                        ? 'Nenhuma nota nesta pasta.'
                        : 'Crie uma nova pasta ou nota clicando no +',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
