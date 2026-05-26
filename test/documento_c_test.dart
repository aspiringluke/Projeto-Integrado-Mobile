import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_integrado_mobile/src/features/notas/controllers/folder_controller.dart';
import 'package:projeto_integrado_mobile/src/features/notas/controllers/note_controller.dart';
import 'package:projeto_integrado_mobile/src/features/notas/controllers/note_editor_controller.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/folder_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/note_repository.dart';
import 'package:projeto_integrado_mobile/src/features/shared/story_registry.dart';
import 'services/fake_folder_service.dart';
import 'services/fake_note_service.dart';

void main() {
  setUp(() {
    _resetStoryRegistry();
  });

  group('Documento C - Casos de teste automatizados', () {
    test('TC01 Criação de nota e abertura de edição', () async {
      final noteService = FakeNoteService();
      final folderService = FakeFolderService();
      final noteController = NoteController(
        repository: NoteRepository(service: noteService),
        folderRepository: FolderRepository(service: folderService),
      );

      final createResult = await noteController.createNote(
        title: 'Nova nota',
        description: 'Descrição da nota',
        color: const Color(0xFF8B7D8B),
      );

      expect(createResult.$1, isTrue);
      expect(noteController.notes, hasLength(1));

      final noteId = noteController.notes.first.id!;
      final editor = NoteEditorController(
        repository: NoteRepository(service: noteService),
        folderRepository: FolderRepository(service: folderService),
        noteId: noteId,
      );

      final loadResult = await editor.loadNote();
      expect(loadResult.$1, isTrue);
      expect(editor.title, 'Nova nota');
      expect(editor.description, 'Descrição da nota');
    });

    test('TC02 Criação de pasta com título vazio', () async {
      final folderService = FakeFolderService();
      final controller = FolderController(
        repository: FolderRepository(service: folderService),
      );

      final result = await controller.createFolder('', const Color(0xFF00FF00));
      expect(result.$1, isFalse);
      expect(controller.errorMessage, contains('não pode ser vazio'));
    });

    test('TC03 Exclusão de nota existente', () async {
      final noteService = FakeNoteService();
      final folderService = FakeFolderService();
      final noteController = NoteController(
        repository: NoteRepository(service: noteService),
        folderRepository: FolderRepository(service: folderService),
      );

      final creation = await noteController.createNote(
        title: 'Nota para excluir',
        description: 'Texto',
        color: const Color(0xFF123456),
      );
      expect(creation.$1, isTrue);
      expect(noteController.notes, hasLength(1));

      final noteId = noteController.notes.first.id!;
      final deletion = await noteController.deleteNote(noteId);
      expect(deletion.$1, isTrue);
      expect(noteController.notes, isEmpty);
      final deletedNote = await noteService.getNote(noteId);
      expect(deletedNote.$2, isNull);
    });

    test('TC04 Criação de pasta com nome válido', () async {
      final folderService = FakeFolderService();
      final controller = FolderController(
        repository: FolderRepository(service: folderService),
      );

      final result = await controller.createFolder(
        'Pasta Teste',
        const Color(0xFF0000FF),
      );
      expect(result.$1, isTrue);
      expect(controller.folders, hasLength(1));
      expect(controller.folders.first.title, 'Pasta Teste');
    });

    test('TC05 Exclusão de pasta existente', () async {
      final folderService = FakeFolderService();
      final controller = FolderController(
        repository: FolderRepository(service: folderService),
      );

      final createResult = await controller.createFolder(
        'Pasta para excluir',
        const Color(0xFFFF00FF),
      );
      expect(createResult.$1, isTrue);
      expect(controller.folders, hasLength(1));

      final folderId = controller.folders.first.id!;
      final deleteResult = await controller.deleteFolder(folderId);
      expect(deleteResult.$1, isTrue);
      expect(controller.folders, isEmpty);
    });

    test('TC06 Movimentação de nota para pasta', () async {
      final noteService = FakeNoteService();
      final folderService = FakeFolderService();
      final noteController = NoteController(
        repository: NoteRepository(service: noteService),
        folderRepository: FolderRepository(service: folderService),
      );
      final folderController = FolderController(
        repository: FolderRepository(service: folderService),
      );

      final folderResult = await folderController.createFolder(
        'Pasta Alvo',
        const Color(0xFF00FFFF),
      );
      expect(folderResult.$1, isTrue);
      final folderId = folderController.folders.first.id!;

      final createResult = await noteController.createNote(
        title: 'Nota para mover',
        description: 'Mover para pasta',
        color: const Color(0xFF111111),
      );
      expect(createResult.$1, isTrue);
      final noteId = noteController.notes.first.id!;

      final moveResult = await noteController.moveNoteToFolder(
        noteId: noteId,
        folderId: folderId,
      );
      expect(moveResult.$1, isTrue);

      final noteAfterMove = await noteService.getNote(noteId);
      expect(noteAfterMove.$2?.idPasta, folderId);
    });

    test('TC07 Alteração de cor da nota selecionando bolinha', () async {
      final noteService = FakeNoteService();
      final folderService = FakeFolderService();
      final noteController = NoteController(
        repository: NoteRepository(service: noteService),
        folderRepository: FolderRepository(service: folderService),
      );

      final result = await noteController.createNote(
        title: 'Nota colorida',
        description: 'Cor alterada',
        color: const Color(0xFF112233),
      );
      expect(result.$1, isTrue);
      final noteId = noteController.notes.first.id!;

      final editor = NoteEditorController(
        repository: NoteRepository(service: noteService),
        folderRepository: FolderRepository(service: folderService),
        noteId: noteId,
      );
      await editor.loadNote();
      editor.setColor(const Color(0xFFFF8800));
      final saveResult = await editor.save();

      expect(saveResult.$1, isTrue);
      final savedNote = (await noteService.getNote(noteId)).$2!;
      expect(savedNote.color.value, const Color(0xFFFF8800).value);
    });

    test('TC08 Alteração de cor da pasta selecionando bolinha', () async {
      final folderService = FakeFolderService();
      final controller = FolderController(
        repository: FolderRepository(service: folderService),
      );

      final result = await controller.createFolder(
        'Pasta colorida',
        const Color(0xFF101010),
      );
      expect(result.$1, isTrue);
      final folderId = controller.folders.first.id!;
      final updateResult = await controller.updateFolder(
        folderId,
        color: const Color(0xFF88FF00),
      );
      expect(updateResult.$1, isTrue);

      final folder = (await folderService.getFolder(folderId)).$2!;
      expect(folder.color.value, const Color(0xFF88FF00).value);
    });

    test('TC09 Edição de nota com texto válido', () async {
      final noteService = FakeNoteService();
      final folderService = FakeFolderService();
      final noteController = NoteController(
        repository: NoteRepository(service: noteService),
        folderRepository: FolderRepository(service: folderService),
      );

      final createResult = await noteController.createNote(
        title: 'Nota editável',
        description: 'Texto inicial',
        color: const Color(0xFFCCCCCC),
      );
      expect(createResult.$1, isTrue);
      final noteId = noteController.notes.first.id!;

      final editor = NoteEditorController(
        repository: NoteRepository(service: noteService),
        folderRepository: FolderRepository(service: folderService),
        noteId: noteId,
      );
      await editor.loadNote();
      editor.setTitle('Texto editado');
      editor.setDescription('Texto editado com sucesso');

      final saveResult = await editor.save();
      expect(saveResult.$1, isTrue);
      final updatedNote = (await noteService.getNote(noteId)).$2!;
      expect(updatedNote.text, 'Texto editado com sucesso');
      expect(updatedNote.title, 'Texto editado');
    });

    test('TC10 Edição de nota com texto gigantesco', () async {
      final noteService = FakeNoteService();
      final folderService = FakeFolderService();
      final noteController = NoteController(
        repository: NoteRepository(service: noteService),
        folderRepository: FolderRepository(service: folderService),
      );

      final createResult = await noteController.createNote(
        title: 'Nota grande',
        description: 'Texto curto',
        color: const Color(0xFF000000),
      );
      expect(createResult.$1, isTrue);
      final noteId = noteController.notes.first.id!;

      final editor = NoteEditorController(
        repository: NoteRepository(service: noteService),
        folderRepository: FolderRepository(service: folderService),
        noteId: noteId,
      );
      await editor.loadNote();
      final hugeText = List.filled(5000, 'A').join();
      editor.setTitle('Nota grande');
      editor.setDescription(hugeText);

      final saveResult = await editor.save();
      expect(saveResult.$1, isTrue);
      final updatedNote = (await noteService.getNote(noteId)).$2!;
      expect(updatedNote.text, hugeText);
    });

    test('TC11 Edição de nota deixando título vazio', () async {
      final noteService = FakeNoteService();
      final folderService = FakeFolderService();
      final noteController = NoteController(
        repository: NoteRepository(service: noteService),
        folderRepository: FolderRepository(service: folderService),
      );

      final createResult = await noteController.createNote(
        title: 'Nota existente',
        description: 'Texto original',
        color: const Color(0xFF333333),
      );
      expect(createResult.$1, isTrue);
      final noteId = noteController.notes.first.id!;

      final editor = NoteEditorController(
        repository: NoteRepository(service: noteService),
        folderRepository: FolderRepository(service: folderService),
        noteId: noteId,
      );
      await editor.loadNote();
      editor.setTitle('');
      editor.setDescription('Texto sem título');

      final saveResult = await editor.save();
      expect(saveResult.$1, isTrue);
      final updatedNote = (await noteService.getNote(noteId)).$2!;
      expect(editor.title, isEmpty);
      expect(updatedNote.title, 'Sem título');
    });

    test('TC12 Movimentação de pasta para outra pasta', () async {
      final folderService = FakeFolderService();
      final controller = FolderController(
        repository: FolderRepository(service: folderService),
      );

      final parentResult = await controller.createFolder(
        'Pasta A',
        const Color(0xFF4422CC),
      );
      expect(parentResult.$1, isTrue);
      final childResult = await controller.createFolder(
        'Pasta B',
        const Color(0xFF22CC44),
      );
      expect(childResult.$1, isTrue);
      final folders = controller.folders;
      expect(folders, hasLength(2));

      final folderA = folders.firstWhere((folder) => folder.title == 'Pasta A');
      final folderB = folders.firstWhere((folder) => folder.title == 'Pasta B');

      final moveResult = await controller.moveFolderToFolder(
        folderA.id!,
        folderB.id,
      );
      expect(moveResult.$1, isTrue);

      final updatedFolderA = (await folderService.getFolder(folderA.id!)).$2!;
      expect(updatedFolderA.parentFolderId, folderB.id);
    });
  });
}

void _resetStoryRegistry() {
  final registry = StoryRegistry.instance;
  for (final note in List.of(registry.notes)) {
    registry.removeNote(note.id);
  }
  for (final folder in List.of(registry.folders)) {
    registry.removeFolder(folder.id);
  }
  registry.syncProjectsAndCharacters(
    projects: const <RegisteredProjectRef>[],
    characters: const <RegisteredCharacterRef>[],
  );
}
