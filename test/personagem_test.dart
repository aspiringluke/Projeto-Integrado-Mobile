import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_integrado_mobile/src/features/characters/data/repositories/character_repository.dart';
import 'package:projeto_integrado_mobile/src/features/characters/models/characters_models.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/folder_repository.dart';
import 'package:projeto_integrado_mobile/src/features/projects/models/project_image_data.dart';
import 'services/fake_character_service.dart';
import 'services/fake_folder_service.dart';

void main() {
  group('Documento C - Técnicas e Casos de Teste (Personagens)', () {
    late CharacterRepository repository;
    late FakeCharacterService characterService;
    late FakeFolderService folderService;

    setUp(() {
      characterService = FakeCharacterService();
      folderService = FakeFolderService();
      repository = CharacterRepository(
        service: characterService,
        folderRepository: FolderRepository(service: folderService),
      );
    });

    CharacterListItem createBaseCharacter({
      String name = 'Herói',
      int projectId = 1,
      String projectTitle = 'Projeto Teste',
    }) {
      return CharacterListItem(
        projectId: projectId,
        projectTitle: projectTitle,
        unpinnedIndex: 0,
        createdAt: DateTime.now(),
        lastModified: DateTime.now(),
        lastAccessed: DateTime.now(),
        data: CharacterCardData(
          name: name,
          alias: '',
          accent: const Color(0xFF0000FF),
          avatarColor: const Color(0xFF0000FF),
          icon: Icons.person,
          birthYear: 2000,
          birthDay: 1,
          birthMonth: 1,
          heightCm: 180,
          weightKg: 75,
          quote: '',
          synopsis: '',
          seed: 0,
        ),
      );
    }

    test('TC01 Criação de personagem e abertura de edição', () async {
      final character = createBaseCharacter(name: 'Herói');

      final result = await repository.createCharacter(character);

      expect(result.$1, isTrue);
      expect(result.$2, isNotNull);
      expect(result.$2!.data.name, 'Herói');
      
      // Verifica se a pasta do personagem foi criada (requisito implícito no repository)
      final folders = await folderService.listAllFolders();
      expect(folders.$2!.any((f) => f.title.contains('Herói')), isTrue);
    });

    test('TC02 Criação de personagem com nome vazio', () async {
      final character = createBaseCharacter(name: '');

      final result = await repository.createCharacter(character);

      expect(result.$1, isFalse);
      expect(result.$3, contains('Informe um nome'));
    });

    test('TC03 Exclusão de personagem existente', () async {
      final character = createBaseCharacter(name: 'Para Excluir');
      final createResult = await repository.createCharacter(character);
      final id = createResult.$2!.id!;

      final deleteResult = await repository.deleteCharacter(id);

      expect(deleteResult.$1, isTrue);
      final getResult = await repository.getCharacter(id);
      expect(getResult.$1, isFalse);
    });

    test('TC04 Edição de fichas técnicas com dados válidos', () async {
      final character = createBaseCharacter(name: 'Protagonista');
      final createResult = await repository.createCharacter(character);
      final saved = createResult.$2!;

      final updatedData = saved.data.copyWith(
        name: 'Protagonista Atualizado',
        synopsis: 'Personagem principal da história',
      );
      final updateResult = await repository.saveCharacter(
        saved.copyWith(data: updatedData),
      );

      expect(updateResult.$1, isTrue);
      final getResult = await repository.getCharacter(saved.id!);
      expect(getResult.$2!.data.name, 'Protagonista Atualizado');
      expect(getResult.$2!.data.synopsis, 'Personagem principal da história');
    });

    test('TC05 Upload de imagem de perfil de personagem', () async {
      final character = createBaseCharacter(name: 'Herói com Imagem');
      final createResult = await repository.createCharacter(character);
      final saved = createResult.$2!;

      final imageData = ProjectImageData(bytes: Uint8List.fromList([1, 2, 3]));
      final updatedData = saved.data.copyWith(profileImage: imageData);
      
      final updateResult = await repository.saveCharacter(
        saved.copyWith(data: updatedData),
      );

      expect(updateResult.$1, isTrue);
      final getResult = await repository.getCharacter(saved.id!);
      expect(getResult.$2!.data.profileImage.bytes, isNotNull);
    });

    test('TC06 Seleção de personagem para cartão de projeto', () async {
      final character = createBaseCharacter(name: 'Personagem para cartão');
      final createResult = await repository.createCharacter(character);
      final saved = createResult.$2!;

      // Simula a seleção para o cartão (isPinned)
      final updateResult = await repository.updateCharacter(
        saved.id!,
        isPinned: true,
      );

      expect(updateResult.$1, isTrue);
      final getResult = await repository.getCharacter(saved.id!);
      expect(getResult.$2!.isPinned, isTrue);
    });

    test('TC07 Edição de personagem deixando nome vazio', () async {
      final character = createBaseCharacter(name: 'Vilão');
      final createResult = await repository.createCharacter(character);
      final saved = createResult.$2!;

      final updatedData = saved.data.copyWith(name: '');
      final updateResult = await repository.saveCharacter(
        saved.copyWith(data: updatedData),
      );

      expect(updateResult.$1, isFalse);
      expect(updateResult.$2, contains('não pode estar vazio'));
      
      final getResult = await repository.getCharacter(saved.id!);
      expect(getResult.$2!.data.name, 'Vilão');
    });

    test('TC08 Edição de personagem com descrição gigantesca', () async {
      final character = createBaseCharacter(name: 'Grande');
      final createResult = await repository.createCharacter(character);
      final saved = createResult.$2!;

      final hugeSynopsis = List.filled(5000, 'A').join();
      final updatedData = saved.data.copyWith(synopsis: hugeSynopsis);
      
      final updateResult = await repository.saveCharacter(
        saved.copyWith(data: updatedData),
      );

      expect(updateResult.$1, isTrue);
      final getResult = await repository.getCharacter(saved.id!);
      expect(getResult.$2!.data.synopsis, hugeSynopsis);
    });

    test('TC09 Remoção de imagem de personagem', () async {
      final imageData = ProjectImageData(bytes: Uint8List.fromList([1, 2, 3]));
      final character = createBaseCharacter(name: 'Com Imagem').copyWith(
        data: CharacterCardData(
          name: 'Com Imagem',
          alias: '',
          accent: Colors.blue,
          avatarColor: Colors.blue,
          icon: Icons.person,
          birthYear: 2000,
          birthDay: 1,
          birthMonth: 1,
          heightCm: 180,
          weightKg: 75,
          quote: '',
          synopsis: '',
          seed: 0,
          profileImage: imageData,
        ),
      );
      
      final createResult = await repository.createCharacter(character);
      final saved = createResult.$2!;
      expect(saved.data.profileImage.bytes, isNotNull);

      final updatedData = saved.data.copyWith(
        profileImage: saved.data.profileImage.copyWith(clearBytes: true),
      );
      final updateResult = await repository.saveCharacter(
        saved.copyWith(data: updatedData),
      );

      expect(updateResult.$1, isTrue);
      final getResult = await repository.getCharacter(saved.id!);
      expect(getResult.$2!.data.profileImage.bytes, isNull);
    });

    test('TC10 Edição de fichas técnicas com campos opcionais vazios', () async {
      final character = createBaseCharacter(name: 'Sábio');
      final createResult = await repository.createCharacter(character);
      final saved = createResult.$2!;

      // Alias e Motto são opcionais
      final updatedData = saved.data.copyWith(
        alias: '',
        motto: '',
      );
      
      final updateResult = await repository.saveCharacter(
        saved.copyWith(data: updatedData),
      );

      expect(updateResult.$1, isTrue);
      final getResult = await repository.getCharacter(saved.id!);
      expect(getResult.$2!.data.alias, isEmpty);
      expect(getResult.$2!.data.motto, isEmpty);
    });

    test('TC11 Criação de múltiplos personagens', () async {
      await repository.createCharacter(createBaseCharacter(name: 'Herói'));
      await repository.createCharacter(createBaseCharacter(name: 'Vilão'));
      await repository.createCharacter(createBaseCharacter(name: 'Aliado'));

      final listResult = await repository.listAllCharacters();
      expect(listResult.$1, isTrue);
      expect(listResult.$2, hasLength(3));
    });

    test('TC12 Remoção de personagem da seleção de cartão', () async {
      final character = createBaseCharacter(name: 'Selecionado').copyWith(isPinned: true);
      final createResult = await repository.createCharacter(character);
      final id = createResult.$2!.id!;

      final updateResult = await repository.updateCharacter(id, isPinned: false);

      expect(updateResult.$1, isTrue);
      final getResult = await repository.getCharacter(id);
      expect(getResult.$2!.isPinned, isFalse);
    });
  });
}
