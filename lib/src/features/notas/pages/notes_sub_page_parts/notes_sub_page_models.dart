part of '../notes_sub_page.dart';

enum _NotesContentScope { all, notes, folders }

enum _SelectionKind { note, folder }

abstract class _NotesSubPageActions {
  Future<void> createNoteFromFab();
  Future<void> createFolderFromFab();
  Future<void> onPrimaryActionPressed();
}

class NotesSubPageController {
  _NotesSubPageActions? _actions;

  void _attach(_NotesSubPageActions actions) {
    _actions = actions;
  }

  void _detach(_NotesSubPageActions actions) {
    if (identical(_actions, actions)) {
      _actions = null;
    }
  }

  Future<void> createNoteFromFab() async {
    await _actions?.createNoteFromFab();
  }

  Future<void> createFolderFromFab() async {
    await _actions?.createFolderFromFab();
  }

  Future<void> onPrimaryActionPressed() async {
    await _actions?.onPrimaryActionPressed();
  }
}

class _SelectedItem {
  final _SelectionKind kind;
  final int id;

  const _SelectedItem({required this.kind, required this.id});

  @override
  bool operator ==(Object other) {
    return other is _SelectedItem && other.kind == kind && other.id == id;
  }

  @override
  int get hashCode => Object.hash(kind, id);
}
