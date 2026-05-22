import 'dart:async';

import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/controllers/folder_controller.dart';
import 'package:projeto_integrado_mobile/src/features/notas/controllers/note_controller.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/folder_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/note_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/content_stats.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/notes_drag_payload.dart';
import 'package:projeto_integrado_mobile/src/features/notas/pages/note_editor_page.dart';
import 'package:projeto_integrado_mobile/src/features/notas/utils/note_color_resolver.dart';
import 'package:projeto_integrado_mobile/src/features/notas/utils/notes_dialogs.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/folder_list_card.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/note_list_card.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/notes_card_widgets.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/notes_visuals.dart';
import 'package:projeto_integrado_mobile/src/features/shared/story_registry.dart';
import 'package:projeto_integrado_mobile/src/shared/widgets/buttons/glass_circle_button.dart';
import 'package:projeto_integrado_mobile/src/shared/widgets/multi_select_action_bar.dart';
import 'package:projeto_integrado_mobile/src/shared/widgets/pin_badge.dart';
import 'package:projeto_integrado_mobile/src/shared/widgets/view_options_bar.dart';

part 'notes_sub_page_parts/notes_sub_page_models.dart';
part 'notes_sub_page_parts/notes_sub_page_breadcrumb.dart';

class NotesSubPage extends StatefulWidget {
  final NotesSubPageController? controller;

  const NotesSubPage({super.key, this.controller});

  @override
  State<NotesSubPage> createState() => NotesSubPageState();
}

class NotesSubPageState extends State<NotesSubPage>
    implements _NotesSubPageActions {
  static const _contentScopeOrder = <_NotesContentScope>[
    _NotesContentScope.all,
    _NotesContentScope.notes,
    _NotesContentScope.folders,
  ];

  late final FolderController _folderController;
  late final NoteController _noteController;
  int? _activeFolderId;
  String? _activeFolderTitle;
  int? _activeFolderParentId;
  List<Folder> _activeFolderPath = const [];
  _NotesContentScope _contentScope = _NotesContentScope.all;
  _NotesDisplayMode _displayMode = _NotesDisplayMode.list;
  bool _selectionMode = false;
  final ScrollController _contentScrollController = ScrollController();
  final Set<_SelectedItem> _selectedItems = <_SelectedItem>{};
  Map<int, ContentStats> _folderStatsById = <int, ContentStats>{};
  Map<int, int> _folderNoteCountById = <int, int>{};
  Map<int, FolderPreviewData> _folderPreviewById = <int, FolderPreviewData>{};
  int _statsRequestToken = 0;
  bool _showContentDivider = false;

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
      _activeFolderPath = const [];
    });

    await _refreshVisibleStats();
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _folderController = FolderController(repository: FolderRepository());
    _noteController = NoteController(repository: NoteRepository());
    _contentScrollController.addListener(_syncContentDividerVisibility);
    unawaited(_bootstrap());
  }

  @override
  void didUpdateWidget(covariant NotesSubPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;

    oldWidget.controller?._detach(this);
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _contentScrollController.removeListener(_syncContentDividerVisibility);
    _contentScrollController.dispose();
    _folderController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _syncContentDividerVisibility() {
    final shouldShow =
        _contentScrollController.hasClients &&
        _contentScrollController.offset > 0.0;
    if (shouldShow == _showContentDivider || !mounted) return;

    setState(() {
      _showContentDivider = shouldShow;
    });
  }

  @override
  Future<void> createNoteFromFab() async {
    await _createNoteFlow();
  }

  @override
  Future<void> createFolderFromFab() async {
    await _createFolderFlow();
  }

  @override
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
      metadata: draft.metadata,
    );
    if (result.$1) {
      _showSnack('Pasta criada com sucesso');
      await _refreshVisibleStats();
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
      await _folderController.loadFolders(parentFolderId: _activeFolderId);
      await _refreshVisibleStats();
      return;
    }
    await _noteController.loadNotes(folderId: _activeFolderId);
    await _refreshVisibleStats();
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
      initialMetadata: folder.metadata,
    );

    if (!mounted || draft == null) return;

    final result = await _folderController.updateFolder(
      folderId,
      title: draft.title,
      color: draft.color,
      metadata: draft.metadata,
    );

    if (result.$1) {
      _showSnack('Pasta atualizada');
      await _refreshVisibleStats();
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

    final countsResult = await _folderController.countNotesInFolderTree(
      folderId,
    );
    if (!mounted) return;
    if (!countsResult.$1) {
      _showSnack(countsResult.$3 ?? 'Falha ao contar notas');
      return;
    }

    final hasChildrenResult = await _folderController.hasChildFolders(folderId);
    if (!mounted) return;
    if (!hasChildrenResult.$1) {
      _showSnack(hasChildrenResult.$3 ?? 'Falha ao verificar subpastas');
      return;
    }

    final statsResult = await _folderController.getFolderTreeStats(folderId);
    if (!mounted) return;
    if (!statsResult.$1 || statsResult.$2 == null) {
      _showSnack(statsResult.$3 ?? 'Falha ao calcular métricas da pasta');
      return;
    }

    final shouldDelete = await showDeleteFolderConfirmation(
      context,
      folderTitle: folder.title,
      hasChildren: hasChildrenResult.$2,
      noteCount: countsResult.$2,
      stats: statsResult.$2!,
      preserveFolder: folder.isProjectRoot,
    );
    if (!mounted || !shouldDelete) return;

    final result = folder.isProjectRoot
        ? await _folderController.deleteFolderContents(folderId)
        : await _folderController.deleteFolder(folderId);
    if (result.$1) {
      _showSnack(
        folder.isProjectRoot ? 'Conteúdo da pasta apagado' : 'Pasta excluída',
      );
      await _refreshVisibleStats();
      return;
    }

    _showSnack(result.$2 ?? 'Falha ao excluir pasta');
  }

  Future<void> _toggleFolderPin(Folder folder) async {
    final folderId = folder.id;
    if (folderId == null) {
      _showSnack('Pasta inválida para fixar');
      return;
    }

    final result = await _folderController.setFolderPinned(
      folderId: folderId,
      pinned: !folder.metadata.pinned,
    );
    if (!mounted) return;

    if (result.$1) {
      await _refreshVisibleStats();
      return;
    }

    _showSnack(result.$2 ?? 'Falha ao alterar fixação da pasta');
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
      await _refreshVisibleStats();
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
      await _refreshVisibleStats();
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

  Future<void> _toggleNotePin(Note note) async {
    final noteId = note.id;
    if (noteId == null) {
      _showSnack('Nota inválida para fixar');
      return;
    }

    final result = await _noteController.setNotePinned(
      noteId: noteId,
      pinned: !note.metadata.pinned,
    );
    if (!mounted) return;

    if (result.$1) {
      await _refreshVisibleStats();
      return;
    }

    _showSnack(result.$2 ?? 'Falha ao alterar fixação da nota');
  }

  Future<void> _deleteSelectedItems() async {
    if (_selectedItems.isEmpty) return;

    final selectedNotes = _selectedNotes(_noteController.notes);
    final selectedFolders = _selectedFolders(_folderController.folders);
    final summary = await _buildDeleteSelectionSummary(
      selectedNotes: selectedNotes,
      selectedFolders: selectedFolders,
    );
    if (!mounted) return;
    final shouldDelete = await showDeleteSelectionConfirmation(
      context,
      noteCount: summary.noteCount,
      folderCount: summary.folderCount,
      totalNotesAffected: summary.totalNotesAffected,
      stats: summary.stats,
      noteTitles: summary.noteTitles,
    );

    if (shouldDelete != true) return;

    for (final note in selectedNotes) {
      final noteId = note.id;
      if (noteId == null) continue;
      await _noteController.deleteNote(noteId);
    }
    for (final folder in selectedFolders) {
      final folderId = folder.id;
      if (folderId == null) continue;
      if (folder.isProjectRoot) {
        await _folderController.deleteFolderContents(folderId);
      } else {
        await _folderController.deleteFolder(folderId);
      }
    }

    _clearSelection();
    await _noteController.loadNotes(folderId: _activeFolderId);
    await _folderController.loadFolders(parentFolderId: _activeFolderId);
    await _refreshVisibleStats();
  }

  Future<_DeleteSelectionSummary> _buildDeleteSelectionSummary({
    required List<Note> selectedNotes,
    required List<Folder> selectedFolders,
  }) async {
    var stats = const ContentStats.zero();
    var totalNotesAffected = selectedNotes.length;
    final noteTitles = selectedNotes
        .map((note) => note.title)
        .toList(growable: false);

    for (final note in selectedNotes) {
      stats += ContentStats.fromText(note.text);
    }

    final folderIds = selectedFolders
        .map((folder) => folder.id)
        .whereType<int>()
        .toList(growable: false);

    if (folderIds.isNotEmpty) {
      final noteCountResults = await Future.wait(
        folderIds.map(
          (folderId) => _folderController.countNotesInFolderTree(folderId),
        ),
      );
      final statsResults = await Future.wait(
        folderIds.map(
          (folderId) => _folderController.getFolderTreeStats(folderId),
        ),
      );

      for (var index = 0; index < folderIds.length; index += 1) {
        final noteCountResult = noteCountResults[index];
        if (noteCountResult.$1) {
          totalNotesAffected += noteCountResult.$2;
        }

        final statsResult = statsResults[index];
        if (statsResult.$1 && statsResult.$2 != null) {
          stats += statsResult.$2!;
        }
      }
    }

    return _DeleteSelectionSummary(
      noteCount: selectedNotes.length,
      folderCount: selectedFolders.length,
      totalNotesAffected: totalNotesAffected,
      stats: stats,
      noteTitles: noteTitles,
    );
  }

  Future<void> _moveSelectedItemsToFolder() async {
    final selectedNotes = _selectedNotes(_noteController.notes);
    final selectedFolders = _selectedFolders(_folderController.folders);
    if (selectedNotes.isEmpty && selectedFolders.isEmpty) return;

    final selected = await showMoveNoteToFolderSheet(
      context,
      folders: _folderController.folders,
      currentFolderId: _activeFolderId,
    );
    if (!mounted || selected == null) return;

    final targetFolderId = selected == 0 ? null : selected;
    for (final note in selectedNotes) {
      final noteId = note.id;
      if (noteId == null) continue;
      await _moveNoteToFolder(noteId: noteId, folderId: targetFolderId);
    }
    for (final folder in selectedFolders) {
      final folderId = folder.id;
      if (folderId == null || folderId == targetFolderId) continue;
      await _moveFolderToFolder(
        folderId: folderId,
        parentFolderId: targetFolderId,
      );
    }

    _clearSelection();
  }

  Future<void> _deleteNoteFlow(Note note) async {
    final noteId = note.id;
    if (noteId == null) {
      _showSnack('Nota inválida para exclusão');
      return;
    }

    final stats = ContentStats.fromText(note.text);

    final shouldDelete = await showDeleteNoteConfirmation(
      context,
      noteTitle: note.title,
      stats: stats,
    );
    if (!mounted || !shouldDelete) return;

    final result = await _noteController.deleteNote(noteId);
    if (result.$1) {
      _showSnack('Nota excluída');
      await _refreshVisibleStats();
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
    await _folderController.touchFolder(folderId);
    final folderPath = await _buildFolderTrail(folder);
    if (!mounted) return;

    if (!result.$1) {
      _showSnack(result.$2 ?? 'Falha ao abrir pasta');
      return;
    }

    setState(() {
      _activeFolderId = folderId;
      _activeFolderTitle = folder.title;
      _activeFolderParentId = folder.parentFolderId;
      _activeFolderPath = folderPath;
    });

    await _refreshVisibleStats();
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
    Folder? parentFolder;
    if (parentId != null) {
      final parent = await _folderController.getFolder(parentId);
      if (!mounted) return;
      if (parent.$1 && parent.$2 != null) {
        parentFolder = parent.$2!;
        parentTitle = parent.$2!.title;
        grandParentId = parent.$2!.parentFolderId;
      }
    }

    final parentTrail = parentFolder == null
        ? const <Folder>[]
        : await _buildFolderTrail(parentFolder);

    setState(() {
      _activeFolderId = parentId;
      _activeFolderTitle = parentTitle;
      _activeFolderParentId = grandParentId;
      _activeFolderPath = parentTrail;
    });

    await _refreshVisibleStats();
  }

  Future<void> _refreshVisibleStats() async {
    final requestToken = ++_statsRequestToken;
    final folders = _folderController.folders;
    final folderIds = folders
        .map((folder) => folder.id)
        .whereType<int>()
        .toList(growable: false);

    final folderStatsById = <int, ContentStats>{};
    final folderNoteCountById = <int, int>{};
    final folderPreviewById = <int, FolderPreviewData>{};

    if (folderIds.isNotEmpty) {
      final statsFuture = Future.wait(
        folderIds.map(
          (folderId) => _folderController.getFolderTreeStats(folderId),
        ),
      );
      final countFuture = Future.wait(
        folderIds.map(
          (folderId) => _folderController.countNotesInFolderTree(folderId),
        ),
      );
      final previewFuture = Future.wait(
        folderIds.map(
          (folderId) => _folderController.getFolderTreePreview(folderId),
        ),
      );
      final folderResults = await statsFuture;
      final countResults = await countFuture;
      final previewResults = await previewFuture;

      if (!mounted || requestToken != _statsRequestToken) return;

      for (var index = 0; index < folderIds.length; index += 1) {
        final result = folderResults[index];
        final folderId = folderIds[index];
        if (result.$1 && result.$2 != null) {
          folderStatsById[folderId] = result.$2!;
        }

        final countResult = countResults[index];
        if (countResult.$1) {
          folderNoteCountById[folderId] = countResult.$2;
        }

        final previewResult = previewResults[index];
        if (previewResult.$1 && previewResult.$2 != null) {
          folderPreviewById[folderId] = previewResult.$2!;
        }
      }
    }

    if (!mounted || requestToken != _statsRequestToken) return;

    setState(() {
      _folderStatsById = folderStatsById;
      _folderNoteCountById = folderNoteCountById;
      _folderPreviewById = folderPreviewById;
    });
  }

  void _cycleContentScope() {
    setState(() {
      final currentIndex = _contentScopeOrder.indexOf(_contentScope);
      _contentScope =
          _contentScopeOrder[(currentIndex + 1) % _contentScopeOrder.length];
    });
  }

  void _toggleDisplayMode() {
    setState(() {
      _displayMode = _displayMode == _NotesDisplayMode.list
          ? _NotesDisplayMode.grid
          : _NotesDisplayMode.list;
    });
  }

  String _contentScopeNoun({bool plural = false}) {
    return switch (_contentScope) {
      _NotesContentScope.all => plural ? 'itens' : 'item',
      _NotesContentScope.notes => plural ? 'notas' : 'nota',
      _NotesContentScope.folders => plural ? 'pastas' : 'pasta',
    };
  }

  bool get _isSelectionMode => _selectionMode;

  void _enterSelectionMode() {
    if (_selectionMode) return;
    setState(() {
      _selectionMode = true;
    });
  }

  void _toggleSelectionMode() {
    if (_selectionMode || _selectedItems.isNotEmpty) {
      _clearSelection();
      return;
    }

    _enterSelectionMode();
  }

  void _selectAllVisibleItems() {
    final visibleFolders = _visibleFolders(_folderController.folders);
    final visibleNotes = _visibleNotes(_noteController.notes);
    final selectedItems = <_SelectedItem>{
      ...visibleFolders
          .map((folder) => folder.id)
          .whereType<int>()
          .map((id) => _SelectedItem(kind: _SelectionKind.folder, id: id)),
      ...visibleNotes
          .map((note) => note.id)
          .whereType<int>()
          .map((id) => _SelectedItem(kind: _SelectionKind.note, id: id)),
    };

    setState(() {
      _selectionMode = true;
      _selectedItems
        ..clear()
        ..addAll(selectedItems);
    });
  }

  void _clearSelection() {
    if (!_selectionMode && _selectedItems.isEmpty) return;
    setState(() {
      _selectionMode = false;
      _selectedItems.clear();
    });
  }

  void _toggleSelectionItem(_SelectionKind kind, int id) {
    setState(() {
      _selectionMode = true;
      final item = _SelectedItem(kind: kind, id: id);
      if (!_selectedItems.add(item)) {
        _selectedItems.remove(item);
      }
    });
  }

  bool _isSelected(_SelectionKind kind, int id) {
    return _selectedItems.contains(_SelectedItem(kind: kind, id: id));
  }

  List<Note> _selectedNotes(List<Note> notes) {
    final selectedIds = _selectedItems
        .where((item) => item.kind == _SelectionKind.note)
        .map((item) => item.id)
        .toSet();
    return notes
        .where((note) => note.id != null && selectedIds.contains(note.id))
        .toList(growable: false);
  }

  List<Folder> _selectedFolders(List<Folder> folders) {
    final selectedIds = _selectedItems
        .where((item) => item.kind == _SelectionKind.folder)
        .map((item) => item.id)
        .toSet();
    return folders
        .where((folder) => folder.id != null && selectedIds.contains(folder.id))
        .toList(growable: false);
  }

  int _selectedNotesCount(List<Note> notes) => _selectedNotes(notes).length;
  int _selectedFoldersCount(List<Folder> folders) =>
      _selectedFolders(folders).length;

  IconData _contentScopeIcon() {
    return switch (_contentScope) {
      _NotesContentScope.all => Icons.layers_outlined,
      _NotesContentScope.notes => Icons.book_outlined,
      _NotesContentScope.folders => Icons.folder_outlined,
    };
  }

  int _contentScopeCount(List<Folder> folders, List<Note> notes) {
    return switch (_contentScope) {
      _NotesContentScope.all => folders.length + notes.length,
      _NotesContentScope.notes => notes.length,
      _NotesContentScope.folders => folders.length,
    };
  }

  List<Folder> _visibleFolders(List<Folder> folders) {
    if (_contentScope == _NotesContentScope.notes) {
      return const <Folder>[];
    }
    return folders;
  }

  List<Note> _visibleNotes(List<Note> notes) {
    if (_contentScope == _NotesContentScope.folders) {
      return const <Note>[];
    }
    return notes;
  }

  List<Folder> _sortFolders(Iterable<Folder> folders) {
    final sorted = folders.toList(growable: false);
    sorted.sort((left, right) {
      final leftPinned = left.metadata.pinned;
      final rightPinned = right.metadata.pinned;
      if (leftPinned != rightPinned) {
        return leftPinned ? -1 : 1;
      }
      return right.lastAccessed.compareTo(left.lastAccessed);
    });
    return sorted;
  }

  List<Note> _sortNotes(Iterable<Note> notes) {
    final sorted = notes.toList(growable: false);
    sorted.sort((left, right) {
      final leftPinned = left.metadata.pinned;
      final rightPinned = right.metadata.pinned;
      if (leftPinned != rightPinned) {
        return leftPinned ? -1 : 1;
      }
      return right.lastAccessed.compareTo(left.lastAccessed);
    });
    return sorted;
  }

  Future<List<Folder>> _buildFolderTrail(Folder folder) async {
    final trail = <Folder>[folder];
    var parentId = folder.parentFolderId;

    while (parentId != null) {
      final result = await _folderController.getFolder(parentId);
      if (!result.$1 || result.$2 == null) {
        break;
      }

      final parent = result.$2!;
      trail.add(parent);
      parentId = parent.parentFolderId;
    }

    return trail.reversed.toList(growable: false);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildFolderEntry(Folder folder, {bool compact = false}) {
    final folderId = folder.id;
    final card = FolderListCard(
      folder: folder,
      folderStats: _folderStatsById[folderId] ?? const ContentStats.zero(),
      noteCount: folderId == null ? 0 : _folderNoteCountById[folderId] ?? 0,
      preview: folderId == null ? null : _folderPreviewById[folderId],
      onTap: () => _openFolder(folder),
      onRename: () => _renameFolderFlow(folder),
      onDelete: () => _deleteFolderFlow(folder),
      onTogglePinned: () => _toggleFolderPin(folder),
      isPinned: folder.metadata.pinned,
      showActions: !compact,
      selectionMode: _isSelectionMode,
      isSelected:
          folderId != null && _isSelected(_SelectionKind.folder, folderId),
      onToggleSelection: folderId == null
          ? null
          : () => _toggleSelectionItem(_SelectionKind.folder, folderId),
      onAcceptNote: folderId == null
          ? null
          : (noteId) => _moveNoteToFolder(noteId: noteId, folderId: folderId),
      onAcceptFolder: folderId == null
          ? null
          : (draggedFolderId) => _moveFolderToFolder(
              folderId: draggedFolderId,
              parentFolderId: folderId,
            ),
    );

    if (folderId == null || _isSelectionMode) {
      return card;
    }

    return LongPressDraggable<NotesDragPayload>(
      data: NotesDragPayload(type: NotesDragType.folder, id: folderId),
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
  }

  Widget _buildNoteEntry(Note note, {bool compact = false}) {
    final noteId = note.id;
    final effectiveNoteColor = resolveNoteAccentColor(
      metadata: note.metadata,
      fallbackColor: note.color,
      registry: StoryRegistry.instance,
    );
    final card = NoteListCard(
      title: note.title,
      text: note.text,
      highlightColor: effectiveNoteColor,
      metadata: note.metadata,
      createdAt: note.createdAt,
      lastModified: note.lastModified,
      lastAccessed: note.lastAccessed,
      onTap: noteId == null ? null : () => _openNoteEditor(noteId),
      onMoveTo: () => _moveNoteByMenuFlow(note),
      onDelete: () => _deleteNoteFlow(note),
      onTogglePinned: () => _toggleNotePin(note),
      isPinned: note.metadata.pinned,
      showActions: !compact,
      selectionMode: _isSelectionMode,
      isSelected: noteId != null && _isSelected(_SelectionKind.note, noteId),
      onToggleSelection: noteId == null
          ? null
          : () => _toggleSelectionItem(_SelectionKind.note, noteId),
    );

    if (noteId == null || _isSelectionMode) {
      return card;
    }

    return LongPressDraggable<NotesDragPayload>(
      data: NotesDragPayload(type: NotesDragType.note, id: noteId),
      delay: const Duration(milliseconds: 180),
      feedback: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: NoteListCard(
            title: note.title,
            text: note.text,
            highlightColor: effectiveNoteColor,
            metadata: note.metadata,
            createdAt: note.createdAt,
            lastModified: note.lastModified,
            lastAccessed: note.lastAccessed,
            showActions: false,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      child: card,
    );
  }

  Widget _buildEmptyContentState(bool isInsideFolder) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: NotesGlassCard(
        accentColor: kNotesPink,
        radius: 20,
        child: Text(
          isInsideFolder
              ? 'Nenhum item nesta pasta.'
              : 'Crie uma nova pasta ou nota clicando no +',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: kNotesMutedText,
            fontSize: 15,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildContentList({
    required List<Folder> folders,
    required List<Note> notes,
    required bool isInsideFolder,
  }) {
    return ListView(
      controller: _contentScrollController,
      padding: EdgeInsets.zero,
      children: [
        ...folders.map(_buildFolderEntry),
        ...notes.map(_buildNoteEntry),
        if (notes.isEmpty && folders.isEmpty)
          _buildEmptyContentState(isInsideFolder),
      ],
    );
  }

  Widget _buildContentGrid({
    required List<Folder> folders,
    required List<Note> notes,
    required bool isInsideFolder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        const spacing = 10.0;
        const columns = 3;
        const horizontalPadding = 12.0;
        final contentWidth = (width - horizontalPadding * 2).clamp(
          0.0,
          double.infinity,
        );
        final tileWidth = (contentWidth - spacing * (columns - 1)) / columns;
        final entries = <Widget>[
          ...folders.map(_buildCompactFolderTile),
          ...notes.map(_buildCompactNoteTile),
        ];

        return ListView(
          controller: _contentScrollController,
          padding: const EdgeInsets.only(bottom: 160),
          children: [
            if (entries.isEmpty)
              _buildEmptyContentState(isInsideFolder)
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                child: Wrap(
                  spacing: spacing,
                  runSpacing: 10,
                  children: [
                    for (final entry in entries)
                      SizedBox(width: tileWidth, child: entry),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCompactFolderTile(Folder folder) {
    final folderId = folder.id;
    final preview = folderId == null ? null : _folderPreviewById[folderId];
    final previewText = preview == null
        ? ''
        : preview.items
              .map((item) => item.title.trim())
              .where((title) => title.isNotEmpty)
              .take(3)
              .join(' · ');

    return _NotesGridTile(
      title: folder.title,
      body: previewText.isEmpty
          ? '${_folderNoteCountById[folderId] ?? 0} nota(s)'
          : previewText,
      accentColor: folder.color,
      icon: Icons.folder_outlined,
      isPinned: folder.metadata.pinned,
      onTap: () => _openFolder(folder),
      onTogglePinned: () => _toggleFolderPin(folder),
      onDelete: () => _deleteFolderFlow(folder),
    );
  }

  Widget _buildCompactNoteTile(Note note) {
    final effectiveNoteColor = resolveNoteAccentColor(
      metadata: note.metadata,
      fallbackColor: note.color,
      registry: StoryRegistry.instance,
    );

    return _NotesGridTile(
      title: note.title,
      body: buildNotePreview(note.text, maxLength: 160),
      accentColor: effectiveNoteColor,
      icon: Icons.sticky_note_2_outlined,
      isPinned: note.metadata.pinned,
      onTap: note.id == null ? null : () => _openNoteEditor(note.id!),
      onTogglePinned: () => _toggleNotePin(note),
      onDelete: () => _deleteNoteFlow(note),
    );
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
        final folders = _sortFolders(_folderController.folders);
        final notes = _sortNotes(_noteController.notes);
        final visibleFolders = _visibleFolders(folders);
        final visibleNotes = _visibleNotes(notes);
        final isLoading =
            _folderController.isLoading || _noteController.isLoading;
        final isInsideFolder = _activeFolderId != null;
        final breadcrumb = _activeFolderPath.isEmpty
            ? const <Folder>[]
            : _activeFolderPath;
        final scopeCount = _contentScopeCount(folders, notes);

        return LayoutBuilder(
          builder: (context, constraints) {
            final viewportHeight =
                constraints.hasBoundedHeight &&
                    constraints.maxHeight.isFinite &&
                    constraints.maxHeight > 0
                ? constraints.maxHeight
                : MediaQuery.sizeOf(context).height;

            return SizedBox(
              height: viewportHeight,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NotesGlassCard(
                          elevated: false,
                          accentColor: _activeFolderId == null
                              ? kNotesPink
                              : const Color(0xFFB78AA4),
                          radius: 22,
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          boxShadow: const [],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0x26DF6EB8),
                                          Color(0x14FFFFFF),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.88,
                                        ),
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () => unawaited(_bootstrap()),
                                        child: const Icon(
                                          Icons.auto_stories_outlined,
                                          color: kNotesPlum,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _NotesBreadcrumb(
                                      segments: breadcrumb,
                                      onHomeTap: () => unawaited(_bootstrap()),
                                      onFolderTap: (folder) =>
                                          unawaited(_openFolder(folder)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Material(
                                    color: Colors.white.withValues(alpha: 0.58),
                                    borderRadius: BorderRadius.circular(999),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(999),
                                      onTap: _cycleContentScope,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.84,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _contentScopeIcon(),
                                              size: 12,
                                              color: kNotesPlum,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              scopeCount == 1
                                                  ? '1 ${_contentScopeNoun()}'
                                                  : '$scopeCount ${_contentScopeNoun(plural: true)}',
                                              style: const TextStyle(
                                                color: kNotesPlum,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  NotesActionIconButton(
                                    icon: _isSelectionMode
                                        ? Icons.close_rounded
                                        : Icons.checklist_rounded,
                                    tooltip: _isSelectionMode
                                        ? 'Sair da seleção'
                                        : 'Selecionar',
                                    onTap: _toggleSelectionMode,
                                  ),
                                  const SizedBox(width: 8),
                                  NotesActionIconButton(
                                    icon: Icons.select_all_rounded,
                                    tooltip: 'Selecionar tudo',
                                    onTap: _selectAllVisibleItems,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ViewOptionsBar(
                                title: 'VisualizaÃ§Ã£o',
                                modeIcon: _displayMode == _NotesDisplayMode.grid
                                    ? Icons.grid_view_rounded
                                    : Icons.view_list_rounded,
                                modeLabel:
                                    _displayMode == _NotesDisplayMode.grid
                                    ? 'Grade'
                                    : 'Lista',
                                toggleTooltip:
                                    _displayMode == _NotesDisplayMode.grid
                                    ? 'Exibir em lista'
                                    : 'Exibir em grade',
                                onToggleMode: _toggleDisplayMode,
                                accentColor: kNotesPink,
                              ),
                              if (isInsideFolder || _isSelectionMode) ...[
                                const SizedBox(height: 10),
                                if (isInsideFolder)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: DragTarget<NotesDragPayload>(
                                      onWillAcceptWithDetails: (details) {
                                        final payload = details.data;
                                        if (payload.type ==
                                                NotesDragType.folder &&
                                            payload.id == _activeFolderId) {
                                          return false;
                                        }
                                        return true;
                                      },
                                      onAcceptWithDetails: (details) {
                                        unawaited(
                                          _moveDraggedItemToParent(
                                            details.data,
                                          ),
                                        );
                                      },
                                      builder:
                                          (
                                            context,
                                            candidateData,
                                            rejectedData,
                                          ) {
                                            final isHoveringParent =
                                                candidateData.isNotEmpty;
                                            return AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 120,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                boxShadow: isHoveringParent
                                                    ? [
                                                        BoxShadow(
                                                          color: kNotesPink
                                                              .withValues(
                                                                alpha: 0.2,
                                                              ),
                                                          blurRadius: 18,
                                                          offset: const Offset(
                                                            0,
                                                            4,
                                                          ),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                      onPressed: _backToParent,
                                                      icon: const Icon(
                                                        Icons
                                                            .arrow_back_rounded,
                                                      ),
                                                      color: kNotesPlum,
                                                      tooltip: 'Voltar',
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        _activeFolderTitle ??
                                                            'Pasta',
                                                        style: const TextStyle(
                                                          color: kNotesText,
                                                          fontSize: 15.5,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    if (isHoveringParent)
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                              right: 8,
                                                            ),
                                                        child: Icon(
                                                          Icons
                                                              .file_download_done_rounded,
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
                                if (_isSelectionMode)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: MultiSelectActionBar(
                                      accentColor: kNotesPink,
                                      label:
                                          '${_selectedNotesCount(_noteController.notes)} nota(s) e ${_selectedFoldersCount(_folderController.folders)} pasta(s) selecionadas',
                                      onClear: _clearSelection,
                                      actions: [
                                        MultiSelectAction(
                                            icon: Icons.delete_outline_rounded,
                                            tooltip: 'Excluir selecionados',
                                            onTap: _deleteSelectedItems,
                                            destructive: true,
                                          ),
                                        MultiSelectAction(
                                            icon: Icons.drive_file_move_outline,
                                            tooltip: 'Mover selecionados',
                                            onTap: _moveSelectedItemsToFolder,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _showContentDivider ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 160),
                    child: Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.white.withValues(alpha: 0.84),
                    ),
                  ),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _displayMode == _NotesDisplayMode.list
                        ? _buildContentList(
                            folders: visibleFolders,
                            notes: visibleNotes,
                            isInsideFolder: isInsideFolder,
                          )
                        : _buildContentGrid(
                            folders: visibleFolders,
                            notes: visibleNotes,
                            isInsideFolder: isInsideFolder,
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _NotesGridTile extends StatelessWidget {
  final String title;
  final String body;
  final Color accentColor;
  final IconData icon;
  final bool isPinned;
  final VoidCallback? onTap;
  final VoidCallback onTogglePinned;
  final VoidCallback onDelete;

  const _NotesGridTile({
    required this.title,
    required this.body,
    required this.accentColor,
    required this.icon,
    required this.isPinned,
    required this.onTap,
    required this.onTogglePinned,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 120.0;
        final buttonSize = tileWidth < 104 ? 24.0 : 27.0;
        final iconSize = tileWidth < 104 ? 12.0 : 14.0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap,
                child: NotesGlassCard(
                  accentColor: accentColor,
                  elevated: true,
                  radius: 16,
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  child: SizedBox(
                    height: 118,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              child: Icon(icon, size: 13, color: accentColor),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: kNotesText,
                                  fontSize: 12.2,
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            body.trim().isEmpty ? 'Sem conteúdo' : body.trim(),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kNotesMutedText,
                              fontSize: 10.8,
                              height: 1.14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: -4,
              child: PinBadge(isActive: isPinned, onTap: onTogglePinned),
            ),
            Positioned(
              right: 6,
              bottom: 6,
              child: GlassCircleButton(
                diameter: buttonSize,
                onTap: onDelete,
                tooltip: 'Excluir',
                fillColor: Colors.white.withValues(alpha: 0.24),
                borderColor: Colors.white.withValues(alpha: 0.68),
                borderWidth: 0.75,
                blurSigma: 12,
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: iconSize,
                  color: kNotesPlum.withValues(alpha: 0.86),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DeleteSelectionSummary {
  final int noteCount;
  final int folderCount;
  final int totalNotesAffected;
  final ContentStats stats;
  final List<String> noteTitles;

  const _DeleteSelectionSummary({
    required this.noteCount,
    required this.folderCount,
    required this.totalNotesAffected,
    required this.stats,
    required this.noteTitles,
  });
}
