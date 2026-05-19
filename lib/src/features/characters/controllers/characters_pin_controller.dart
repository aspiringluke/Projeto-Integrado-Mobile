import '../models/characters_models.dart';

class CharactersPinController {
  const CharactersPinController();

  List<CharacterListItem> toListItems(List<CharacterCardData> characters) {
    final now = DateTime.now();
    return characters.indexed
        .map(
          (entry) => CharacterListItem(
            projectId: 0,
            data: entry.$2,
            unpinnedIndex: entry.$1,
            createdAt: now,
            lastModified: now,
            lastAccessed: now,
          ),
        )
        .toList(growable: true);
  }

  void togglePinned(
    List<CharacterListItem> characters,
    CharacterListItem character,
  ) {
    final currentIndex = characters.indexOf(character);
    if (currentIndex == -1) return;

    if (!character.isPinned) {
      character.unpinnedIndex = _unpinnedIndexAt(characters, currentIndex);
    }

    characters.removeAt(currentIndex);
    character.isPinned = !character.isPinned;

    if (character.isPinned) {
      characters.insert(0, character);
      return;
    }

    final pinnedCount = characters.where((item) => item.isPinned).length;
    final unpinnedCount = characters.length - pinnedCount;
    final targetUnpinnedIndex = character.unpinnedIndex.clamp(0, unpinnedCount);
    characters.insert(pinnedCount + targetUnpinnedIndex, character);
    _updateUnpinnedSlots(characters);
  }

  int _unpinnedIndexAt(List<CharacterListItem> characters, int listIndex) {
    var count = 0;

    for (var index = 0; index < listIndex; index += 1) {
      if (!characters[index].isPinned) {
        count += 1;
      }
    }

    return count;
  }

  void _updateUnpinnedSlots(List<CharacterListItem> characters) {
    var unpinnedIndex = 0;

    for (final character in characters) {
      if (!character.isPinned) {
        character.unpinnedIndex = unpinnedIndex;
        unpinnedIndex += 1;
      }
    }
  }
}
