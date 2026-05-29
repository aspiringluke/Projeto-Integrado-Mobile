import 'package:projeto_integrado_mobile/src/features/characters/data/services/i_character_service.dart';
import 'package:projeto_integrado_mobile/src/features/characters/models/characters_models.dart';

class FakeCharacterService implements ICharacterService {
  final Map<int, CharacterListItem> _characters = {};
  int _nextId = 1;

  @override
  Future<(bool, CharacterListItem?, String?)> createCharacter(
    CharacterListItem character,
  ) async {
    if (character.data.name.isEmpty) {
      return (false, null, 'Informe um nome para o personagem.');
    }
    final id = _nextId++;
    final newCharacter = character.copyWith(id: id);
    _characters[id] = newCharacter;
    return (true, newCharacter, null);
  }

  @override
  Future<(bool, String)> deleteCharacter(int id) async {
    if (!_characters.containsKey(id)) {
      return (false, 'Personagem não encontrado');
    }
    _characters.remove(id);
    return (true, 'Personagem removido com sucesso');
  }

  @override
  Future<(bool, CharacterListItem?, String?)> getCharacter(int id) async {
    final character = _characters[id];
    if (character == null) {
      return (false, null, 'Personagem não encontrado');
    }
    return (true, character, null);
  }

  @override
  Future<(bool, List<CharacterListItem>?, String?)> listAllCharacters() async {
    return (true, _characters.values.toList(), null);
  }

  @override
  Future<(bool, List<CharacterListItem>?, String?)> listCharactersForProject(
    int projectId,
  ) async {
    final list =
        _characters.values
            .where((c) => c.projectId == projectId)
            .toList();
    return (true, list, null);
  }

  @override
  Future<(bool, String)> touchCharacter(int id) async {
    final character = _characters[id];
    if (character == null) {
      return (false, 'Personagem não encontrado');
    }
    _characters[id] = character.copyWith(lastAccessed: DateTime.now());
    return (true, 'Sucesso');
  }

  @override
  Future<(bool, String)> updateCharacter(CharacterListItem character) async {
    if (character.id == null || !_characters.containsKey(character.id)) {
      return (false, 'Personagem não encontrado');
    }
    if (character.data.name.isEmpty) {
      return (false, 'O nome do personagem não pode estar vazio.');
    }
    _characters[character.id!] = character.copyWith(
      lastModified: DateTime.now(),
    );
    return (true, 'Personagem atualizado com sucesso');
  }
}
