import 'package:projeto_integrado_mobile/src/features/notas/models/note.dart';

abstract interface class INoteService
{
    (bool, String) createNewNote(String titulo, String descricao, int? idPasta, String color);
    (bool, String) updateNote(int id, String newTitulo, String newDescricao, int? newIdPasta, String newColor);
    (bool, Note?, String?) getNote(int id);
    (bool, List<Note>?, String?) listNotes(int? idPasta); 
    (bool, String) deleteNote(int id);
}
