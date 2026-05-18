import 'package:projeto_integrado_mobile/src/features/characters/data/services/i_character_service.dart';
import 'package:projeto_integrado_mobile/src/features/characters/data/services/sqlite_character_service.dart';
import 'package:projeto_integrado_mobile/src/features/characters/models/characters_models.dart';

class CharacterRepository {
  final ICharacterService service;

  CharacterRepository({ICharacterService? service})
    : service = service ?? SqliteCharacterService();

  Future<(bool, CharacterListItem?, String?)> createCharacter(
    CharacterListItem character,
  ) {
    return service.createCharacter(character);
  }

  Future<(bool, CharacterListItem?, String?)> getCharacter(int id) {
    return service.getCharacter(id);
  }

  Future<(bool, List<CharacterListItem>?, String?)> listAllCharacters() {
    return service.listAllCharacters();
  }

  Future<(bool, List<CharacterListItem>?, String?)> listCharactersForProject(
    int projectId,
  ) {
    return service.listCharactersForProject(projectId);
  }

  Future<(bool, String)> touchCharacter(int id) {
    return service.touchCharacter(id);
  }

  Future<(bool, String)> updateCharacter(
    int id, {
    int? projectId,
    String? projectTitle,
    CharacterCardData? data,
    bool? isPinned,
    int? unpinnedIndex,
    DateTime? lastAccessed,
  }) async {
    final current = await getCharacter(id);
    if (!current.$1) {
      return (false, current.$3 ?? 'Erro ao buscar personagem');
    }

    final character = current.$2;
    if (character == null) {
      return (false, 'Personagem não encontrado');
    }

    return service.updateCharacter(
      character.copyWith(
        projectId: projectId ?? character.projectId,
        projectTitle: projectTitle ?? character.projectTitle,
        data: data ?? character.data,
        isPinned: isPinned ?? character.isPinned,
        unpinnedIndex: unpinnedIndex ?? character.unpinnedIndex,
        lastAccessed: lastAccessed ?? character.lastAccessed,
      ),
    );
  }
}
