import '../../characters/models/characters_models.dart';
import '../../characters/utils/character_relevance.dart';

const int projectShowcaseCharacterLimit = 7;

List<CharacterListItem> resolveProjectShowcaseCharacters({
  required List<int> selectedCharacterIds,
  required List<CharacterListItem> characters,
}) {
  if (characters.isEmpty) {
    return const <CharacterListItem>[];
  }

  if (selectedCharacterIds.isNotEmpty) {
    final byId = <int, CharacterListItem>{
      for (final character in characters)
        if (character.id != null) character.id!: character,
    };

    return selectedCharacterIds
        .map((id) => byId[id])
        .whereType<CharacterListItem>()
        .take(projectShowcaseCharacterLimit)
        .toList(growable: false);
  }

  final ranked = characters.toList(growable: false)
    ..sort((a, b) {
      final scoreComparison = characterRelevanceScore(
        b.data,
      ).compareTo(characterRelevanceScore(a.data));
      if (scoreComparison != 0) {
        return scoreComparison;
      }

      return b.lastModified.compareTo(a.lastModified);
    });

  return ranked.take(projectShowcaseCharacterLimit).toList(growable: false);
}

List<int> toggleProjectShowcaseCharacterId({
  required List<int> selectedCharacterIds,
  required int characterId,
}) {
  final next = selectedCharacterIds.toList(growable: true);
  if (next.remove(characterId)) {
    return List<int>.unmodifiable(next);
  }

  if (next.length >= projectShowcaseCharacterLimit) {
    return List<int>.unmodifiable(next);
  }

  next.add(characterId);
  return List<int>.unmodifiable(next);
}
