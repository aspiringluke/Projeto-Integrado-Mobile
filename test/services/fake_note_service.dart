import 'dart:ui';

import 'package:projeto_integrado_mobile/src/features/notas/data/services/i_note_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';

class FakeNoteService implements INoteService {
  final Map<int, Note> _notes = <int, Note>{};
  int _nextId = 1;

  @override
  Future<(bool, int?, String?)> createNewNoteWithId(
    String titulo,
    String descricao,
    int? idPasta,
    String color, {
    String? metadataJson,
  }) async {
    final trimmedTitle = titulo.trim();
    if (trimmedTitle.isEmpty) {
      return (false, null, 'O título da nota não pode ser vazio');
    }
    final id = _nextId++;
    _notes[id] = Note(
      id: id,
      title: trimmedTitle,
      text: descricao,
      color: Color(int.parse(color)),
      idPasta: idPasta,
      metadata: const NoteMetadata(
        tagGroups: <NoteTagGroup>[],
        linkTarget: NoteLinkTarget(),
      ),
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      lastAccessed: DateTime.now(),
    );
    return (true, id, null);
  }

  @override
  Future<(bool, String)> createNewNote(
    String titulo,
    String descricao,
    int? idPasta,
    String color, {
    String? metadataJson,
  }) async {
    final trimmedTitle = titulo.trim();
    if (trimmedTitle.isEmpty) {
      return (false, 'O título da nota não pode ser vazio');
    }
    final id = _nextId++;
    _notes[id] = Note(
      id: id,
      title: trimmedTitle,
      text: descricao,
      color: Color(int.parse(color)),
      idPasta: idPasta,
      metadata: const NoteMetadata(
        tagGroups: <NoteTagGroup>[],
        linkTarget: NoteLinkTarget(),
      ),
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      lastAccessed: DateTime.now(),
    );
    return (true, 'OK');
  }

  @override
  Future<(bool, Note?, String?)> getNote(int id) async {
    final note = _notes[id];
    if (note == null) {
      return (false, null, 'Nota não encontrada');
    }
    return (true, note, null);
  }

  @override
  Future<(bool, List<Note>?, String?)> listNotes(int? idPasta) async {
    final notes = _notes.values
        .where((note) {
          if (idPasta == null) return true;
          return note.idPasta == idPasta;
        })
        .toList(growable: false);
    return (true, notes, null);
  }

  @override
  Future<(bool, List<Note>?, String?)> listAllNotes() async {
    return (true, _notes.values.toList(growable: false), null);
  }

  @override
  Future<(bool, List<({Color color, int id, String title})>?, String?)>
  listNoteRegistryRefs() async {
    final refs = _notes.values
        .where((note) => note.id != null)
        .map((note) => (id: note.id!, title: note.title, color: note.color))
        .toList(growable: false);
    return (true, refs, null);
  }

  @override
  Future<(bool, String)> deleteNote(int id) async {
    if (!_notes.containsKey(id)) {
      return (false, 'Nota não encontrada');
    }
    _notes.remove(id);
    return (true, 'OK');
  }

  @override
  Future<(bool, String)> touchNote(int id) async {
    final note = _notes[id];
    if (note == null) {
      return (false, 'Nota não encontrada');
    }
    _notes[id] = Note(
      id: note.id,
      title: note.title,
      text: note.text,
      color: note.color,
      idPasta: note.idPasta,
      metadata: note.metadata,
      createdAt: note.createdAt,
      lastModified: note.lastModified,
      lastAccessed: DateTime.now(),
    );
    return (true, 'OK');
  }

  @override
  Future<(bool, String)> updateNote(
    int id,
    String newTitulo,
    String newDescricao,
    int? newIdPasta,
    String newColor, {
    String? metadataJson,
  }) async {
    final note = _notes[id];
    if (note == null) {
      return (false, 'Nota não encontrada');
    }
    _notes[id] = Note(
      id: id,
      title: newTitulo,
      text: newDescricao,
      color: Color(int.parse(newColor)),
      idPasta: newIdPasta,
      metadata: note.metadata,
      createdAt: note.createdAt,
      lastModified: DateTime.now(),
      lastAccessed: DateTime.now(),
    );
    return (true, 'OK');
  }
}
