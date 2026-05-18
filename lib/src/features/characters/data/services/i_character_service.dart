import 'package:projeto_integrado_mobile/src/features/characters/models/characters_models.dart';

abstract interface class ICharacterService {
  Future<(bool, CharacterListItem?, String?)> createCharacter(
    CharacterListItem character,
  );
  Future<(bool, String)> updateCharacter(CharacterListItem character);
  Future<(bool, CharacterListItem?, String?)> getCharacter(int id);
  Future<(bool, List<CharacterListItem>?, String?)> listCharactersForProject(
    int projectId,
  );
  Future<(bool, List<CharacterListItem>?, String?)> listAllCharacters();
  Future<(bool, String)> touchCharacter(int id);
}
