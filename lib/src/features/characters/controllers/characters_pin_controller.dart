part of '../pages/characters_section.dart';

class _CharactersPinController {
  const _CharactersPinController();

  List<_CharacterListItem> toListItems(List<_CharacterCardData> characters) {
    return characters.indexed
        .map(
          (entry) => _CharacterListItem(
            data: entry.$2,
            unpinnedIndex: entry.$1,
          ),
        )
        .toList(growable: true);
  }

  void togglePinned(List<_CharacterListItem> characters, _CharacterListItem character) {
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

  int _unpinnedIndexAt(List<_CharacterListItem> characters, int listIndex) {
    var count = 0;

    for (var index = 0; index < listIndex; index += 1) {
      if (!characters[index].isPinned) {
        count += 1;
      }
    }

    return count;
  }

  void _updateUnpinnedSlots(List<_CharacterListItem> characters) {
    var unpinnedIndex = 0;

    for (final character in characters) {
      if (!character.isPinned) {
        character.unpinnedIndex = unpinnedIndex;
        unpinnedIndex += 1;
      }
    }
  }
}
