import 'package:projeto_integrado_mobile/src/features/notas/models/note.dart';

abstract interface class INoteService
{
    (bool, String) createNewNote(String text, int? idPasta);
    (bool, String) updateNote(int id, String newText, int? newIdPasta);
    (bool, Note?, String?) getNote(int id);
    (bool, List<Note>?, String?) listNotes(); 
    (bool, String) deleteNote(int id);
}