import 'dart:ui';

import 'package:projeto_integrado_mobile/src/features/notas/data/services/i_note_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/services/sqlite_note_service.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note.dart';

class NoteRepository
{
    final INoteService service;

    NoteRepository({
        INoteService? service,
    }) : service = service ?? Sqlitefolderservice();

    Future<(bool, int?, String?)> createNewNoteWithId(String titulo, String descricao, int? idPasta, Color color)
    {
        return service.createNewNoteWithId(
            titulo,
            descricao,
            idPasta,
            color.toARGB32().toString(),
        );
    }

    Future<(bool, String)> createNewNote(String titulo, String descricao, int? idPasta, Color color)
    {
        return service.createNewNote(titulo, descricao, idPasta, color.toARGB32().toString());
    }

    Future<(bool, String)> updateNote(int id, String? titulo, String? descricao, int? idPasta, Color? color) async
    {
        final result = await getNote(id);

        if(result.$1 == false)
        {
            return (false, result.$3 ?? "Erro ao buscar nota");
        }

        if(result.$2 == null)
        {
            return (false, "Nota não encontrada");
        }

        final oldValues = result.$2;

        return await service.updateNote(
            id,
            titulo ?? oldValues!.title,
            descricao ?? oldValues!.text,
            idPasta ?? oldValues!.idPasta,
            (color ?? oldValues!.color).toARGB32().toString()
        );
    }

    Future<(bool, Note?, String?)> getNote(int id)
    {
        return service.getNote(id);
    }

    Future<(bool, List<Note>?, String?)> listNotes(int? idPasta)
    {
        return service.listNotes(idPasta);
    }

    Future<(bool, String)> deleteNote(int id) async
    {
        final result = await getNote(id);

        if(result.$1 == false)
        {
            return (false, result.$3 ?? "Erro ao buscar nota");
        }

        if(result.$2 == null)
        {
            return (false, "Nota não encontrada");
        }

        return await service.deleteNote(id);
    }

    Future<(bool, String)> moveNoteToFolder(int id, int? folderId) async
    {
        final result = await getNote(id);

        if(result.$1 == false)
        {
            return (false, result.$3 ?? "Erro ao buscar nota");
        }

        if(result.$2 == null)
        {
            return (false, "Nota não encontrada");
        }

        final oldValues = result.$2!;

        return await service.updateNote(
            id,
            oldValues.title,
            oldValues.text,
            folderId,
            oldValues.color.toARGB32().toString(),
        );
    }
}
