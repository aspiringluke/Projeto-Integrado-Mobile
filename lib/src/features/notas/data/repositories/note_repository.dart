import 'dart:ui';

import 'package:projeto_integrado_mobile/src/features/notas/data/services/i_note_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note.dart';

abstract interface class NoteRepository
{
    final INoteService service;

    NoteRepository({
        required this.service
    });

    (bool, String) createNewNote(String titulo, String descricao, int? idPasta, Color color)
    {
        return service.createNewNote(titulo, descricao, idPasta, color.toARGB32().toString());
    }

    (bool, String) updateNote(int id, String? titulo, String? descricao, int? idPasta, Color? color)
    {
        final result = getNote(id);

        if(result.$1 == false)
        {
            return (false, result.$3!);
        }

        if(result.$2 == null)
        {
            return (false, "Nota não encontrada");
        }

        final oldValues = result.$2;

        return service.updateNote(
            id,
            titulo ?? oldValues!.title,
            descricao ?? oldValues!.text,
            idPasta ?? oldValues!.idPasta,
            (color ?? oldValues!.color).toARGB32().toString()
        );
    }

    (bool, Note?, String?) getNote(int id)
    {
        return service.getNote(id);
    }

    (bool, List<Note>?, String?) listNotes(int? idPasta)
    {
        return service.listNotes(idPasta);
    }

    (bool, String) deleteNote(int id)
    {
        final result = getNote(id);

        if(result.$1 == false)
        {
            return (false, result.$3!);
        }

        if(result.$2 == null)
        {
            return (false, "Nota não encontrada");
        }

        return service.deleteNote(id);
    }
}
