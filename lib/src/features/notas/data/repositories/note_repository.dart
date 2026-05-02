import 'package:projeto_integrado_mobile/src/features/notas/data/services/i_note_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note.dart';

abstract interface class NoteRepository
{
    final INoteService service;

    NoteRepository({
        required this.service
    });

    (bool, String) createNewNote(String title, int? idPasta)
    {
        return service.createNewNote(title, idPasta);
    }

    (bool, String) updateNote(int id, String title, int? idPasta)
    {
        return service.updateNote(id, title, idPasta);
    }

    (bool, Note?, String?) getNote(int id)
    {
        return service.getNote(id);
    }

    (bool, List<Note>?, String?) listNotes()
    {
        return service.listNotes();
    }

    (bool, String) deleteNote(int id)
    {
        return service.deleteNote(id);
    }
}