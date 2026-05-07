import 'dart:async';

import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/controllers/folder_controller.dart';
import 'package:projeto_integrado_mobile/src/features/notas/controllers/note_controller.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/folder_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/note_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/notes_drag_payload.dart';
import 'package:projeto_integrado_mobile/src/features/notas/pages/note_editor_page.dart';
import 'package:projeto_integrado_mobile/src/features/notas/utils/note_color_resolver.dart';
import 'package:projeto_integrado_mobile/src/features/notas/utils/notes_dialogs.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/folder_list_card.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/note_list_card.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/notes_visuals.dart';
import 'package:projeto_integrado_mobile/src/features/shared/story_registry.dart';

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
  int? _activeFolderParentId;

  Future<void> _bootstrap() async {
    final foldersResult = await _folderController.loadFolders(
      parentFolderId: null,
    );
    final notesResult = await _noteController.loadNotes(folderId: null);
    if (!mounted) return;

    if (!foldersResult.$1) {
      _showSnack(foldersResult.$2 ?? 'Falha ao carregar pastas');
    }
    if (!notesResult.$1) {
      _showSnack(notesResult.$2 ?? 'Falha ao carregar notas');
    }

    setState(() {
      _activeFolderId = null;
      _activeFolderTitle = null;
      _activeFolderParentId = null;
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

  Future<void> createNoteFromFab() async {
    await _createNoteFlow();
  }

  Future<void> createFolderFromFab() async {
    await _createFolderFlow();
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

    final result = await _folderController.createFolder(
      draft.title,
      draft.color,
      parentFolderId: _activeFolderId,
    );
    if (result.$1) {
      _showSnack('Pasta criada com sucesso');
      return;
    }

    _showSnack(result.$2 ?? 'Falha ao criar pasta');
  }

  Future<void> _createNoteFlow() async {
    final result = await _noteController.createDraftNote(
      folderId: _activeFolderId,
    );
    if (!mounted) return;

    if (!result.$1 || result.$2 == null) {
      _showSnack(result.$3 ?? 'Falha ao criar nota');
      return;
    }

    await _openNoteEditor(result.$2!);
  }

  Future<void> _openNoteEditor(int noteId) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => NoteEditorPage(noteId: noteId)),
    );
    if (!mounted) return;

    if (changed == true) {
      await _noteController.loadNotes(folderId: _activeFolderId);
      return;
    }
    await _noteController.loadNotes(folderId: _activeFolderId);
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

    final hasChildrenResult = await _folderController.hasChildFolders(folderId);
    if (!mounted) return;

    if (!hasChildrenResult.$1) {
      _showSnack(hasChildrenResult.$3 ?? 'Falha ao verificar subpastas');
      return;
    }

    final shouldDelete = await showDeleteFolderConfirmation(
      context,
      folderTitle: folder.title,
      hasChildren: hasChildrenResult.$2,
    );
    if (!mounted || !shouldDelete) return;

    final result = await _folderController.deleteFolder(folderId);
    if (result.$1) {
      _showSnack('Pasta excluída');
      return;
    }

    _showSnack(result.$2 ?? 'Falha ao excluir pasta');
  }

  Future<void> _moveFolderToFolder({
    required int folderId,
    required int? parentFolderId,
  }) async {
    final result = await _folderController.moveFolderToFolder(
      folderId,
      parentFolderId,
    );
    if (!mounted) return;

    if (result.$1) {
      _showSnack('Pasta movida com sucesso');
      return;
    }

    _showSnack(result.$2 ?? 'Falha ao mover pasta');
  }

  Future<void> _moveDraggedItemToParent(NotesDragPayload payload) async {
    if (_activeFolderId == null) return;

    if (payload.type == NotesDragType.note) {
      await _moveNoteToFolder(
        noteId: payload.id,
        folderId: _activeFolderParentId,
      );
      return;
    }

    await _moveFolderToFolder(
      folderId: payload.id,
      parentFolderId: _activeFolderParentId,
    );
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

  Future<void> _deleteNoteFlow(Note note) async {
    final noteId = note.id;
    if (noteId == null) {
      _showSnack('Nota inválida para exclusão');
      return;
    }

    final shouldDelete = await showDeleteNoteConfirmation(
      context,
      noteTitle: note.title,
    );
    if (!mounted || !shouldDelete) return;

    final result = await _noteController.deleteNote(noteId);
    if (result.$1) {
      _showSnack('Nota excluída');
      return;
    }

    _showSnack(result.$2 ?? 'Falha ao excluir nota');
  }

  Future<void> _openFolder(Folder folder) async {
    final folderId = folder.id;
    if (folderId == null) {
      _showSnack('Pasta inválida');
      return;
    }

    final result = await _noteController.loadNotes(folderId: folderId);
    await _folderController.loadFolders(parentFolderId: folderId);
    if (!mounted) return;

    if (!result.$1) {
      _showSnack(result.$2 ?? 'Falha ao abrir pasta');
      return;
    }

    setState(() {
      _activeFolderId = folderId;
      _activeFolderTitle = folder.title;
      _activeFolderParentId = folder.parentFolderId;
    });
  }

  Future<void> _backToParent() async {
    final parentId = _activeFolderParentId;
    final notesResult = await _noteController.loadNotes(folderId: parentId);
    final foldersResult = await _folderController.loadFolders(
      parentFolderId: parentId,
    );
    if (!mounted) return;

    if (!notesResult.$1) {
      _showSnack(notesResult.$2 ?? 'Falha ao voltar');
      return;
    }
    if (!foldersResult.$1) {
      _showSnack(foldersResult.$2 ?? 'Falha ao voltar');
      return;
    }

    String? parentTitle;
    int? grandParentId;
    if (parentId != null) {
      final parent = await _folderController.getFolder(parentId);
      if (!mounted) return;
      if (parent.$1 && parent.$2 != null) {
        parentTitle = parent.$2!.title;
        grandParentId = parent.$2!.parentFolderId;
      }
    }

    setState(() {
      _activeFolderId = parentId;
      _activeFolderTitle = parentTitle;
      _activeFolderParentId = grandParentId;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _folderController,
        _noteController,
        StoryRegistry.instance,
      ]),
      builder: (context, _) {
        final folders = _folderController.folders;
        final notes = _noteController.notes;
        final isLoading =
            _folderController.isLoading || _noteController.isLoading;
        final isInsideFolder = _activeFolderId != null;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: NotesGlassCard(
                elevated: true,
                accentColor: _activeFolderId == null
                    ? kNotesPink
                    : const Color(0xFFB78AA4),
                radius: 22,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0x26DF6EB8), Color(0x14FFFFFF)],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_stories_outlined,
                        color: kNotesPlum,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activeFolderTitle ?? 'Notas',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kNotesText,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isInsideFolder
                                ? 'Notas e pastas dentro desta camada.'
                                : 'Notas, pastas e ações rápidas em um só lugar.',
                            style: const TextStyle(
                              color: kNotesMutedText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.84),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      child: Text(
                        '${notes.length + folders.length}',
                        style: const TextStyle(
                          color: kNotesPlum,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isInsideFolder)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DragTarget<NotesDragPayload>(
                  onWillAcceptWithDetails: (details) {
                    final payload = details.data;
                    if (payload.type == NotesDragType.folder &&
                        payload.id == _activeFolderId) {
                      return false;
                    }
                    return true;
                  },
                  onAcceptWithDetails: (details) {
                    unawaited(_moveDraggedItemToParent(details.data));
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isHoveringParent = candidateData.isNotEmpty;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: isHoveringParent
                            ? [
                                BoxShadow(
                                  color: kNotesPink.withValues(alpha: 0.2),
                                  blurRadius: 18,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: NotesGlassCard(
                        accentColor: isHoveringParent
                            ? kNotesPink
                            : const Color(0xFFB78AA4),
                        elevated: true,
                        radius: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _backToParent,
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: kNotesPlum,
                              tooltip: 'Voltar',
                            ),
                            Expanded(
                              child: Text(
                                _activeFolderTitle ?? 'Pasta',
                                style: const TextStyle(
                                  color: kNotesText,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isHoveringParent)
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.file_download_done_rounded,
                                  color: kNotesPink,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              ...folders.map((folder) {
                final folderId = folder.id;
                final card = FolderListCard(
                  folder: folder,
                  onTap: () => _openFolder(folder),
                  onRename: () => _renameFolderFlow(folder),
                  onDelete: () => _deleteFolderFlow(folder),
                  onAcceptNote: folderId == null
                      ? null
                      : (noteId) => _moveNoteToFolder(
                          noteId: noteId,
                          folderId: folderId,
                        ),
                  onAcceptFolder: folderId == null
                      ? null
                      : (draggedFolderId) => _moveFolderToFolder(
                          folderId: draggedFolderId,
                          parentFolderId: folderId,
                        ),
                );

                if (folderId == null) return card;

                return LongPressDraggable<NotesDragPayload>(
                  data: NotesDragPayload(
                    type: NotesDragType.folder,
                    id: folderId,
                  ),
                  delay: const Duration(milliseconds: 180),
                  feedback: Material(
                    color: Colors.transparent,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Opacity(opacity: 0.9, child: card),
                    ),
                  ),
                  childWhenDragging: Opacity(opacity: 0.35, child: card),
                  child: card,
                );
              }),
              ...notes.map((note) {
                final noteId = note.id;
                final effectiveNoteColor = resolveNoteAccentColor(
                  metadata: note.metadata,
                  fallbackColor: note.color,
                  registry: StoryRegistry.instance,
                );
                final card = NoteListCard(
                  title: note.title,
                  highlightColor: effectiveNoteColor,
                  onTap: noteId == null ? null : () => _openNoteEditor(noteId),
                  onMoveTo: () => _moveNoteByMenuFlow(note),
                  onDelete: () => _deleteNoteFlow(note),
                );

                if (noteId == null) return card;

                return LongPressDraggable<NotesDragPayload>(
                  data: NotesDragPayload(type: NotesDragType.note, id: noteId),
                  delay: const Duration(milliseconds: 180),
                  feedback: Material(
                    color: Colors.transparent,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: NoteListCard(
                        title: note.title,
                        highlightColor: effectiveNoteColor,
                        showActions: false,
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(opacity: 0.35, child: card),
                  child: card,
                );
              }),
              if (notes.isEmpty && (isInsideFolder || folders.isEmpty))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: NotesGlassCard(
                    accentColor: kNotesPink,
                    radius: 20,
                    child: Text(
                      isInsideFolder
                          ? 'Nenhuma nota nesta pasta.'
                          : 'Crie uma nova pasta ou nota clicando no +',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: kNotesMutedText,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
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
