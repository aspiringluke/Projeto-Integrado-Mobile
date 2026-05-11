import 'package:projeto_integrado_mobile/src/features/notas/models/note.dart';

abstract interface class INoteService {
  Future<(bool, int?, String?)> createNewNoteWithId(
    String titulo,
    String descricao,
    int? idPasta,
    String color, {
    String? metadataJson,
  });
  Future<(bool, String)> createNewNote(
    String titulo,
    String descricao,
    int? idPasta,
    String color, {
    String? metadataJson,
  });
  Future<(bool, String)> updateNote(
    int id,
    String newTitulo,
    String newDescricao,
    int? newIdPasta,
    String newColor, {
    String? metadataJson,
  });
  Future<(bool, Note?, String?)> getNote(int id);
  Future<(bool, List<Note>?, String?)> listNotes(int? idPasta);
  Future<(bool, List<Note>?, String?)> listAllNotes();
  Future<(bool, String)> deleteNote(int id);
  Future<(bool, String)> touchNote(int id);
}
