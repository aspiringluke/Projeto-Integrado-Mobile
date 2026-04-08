import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../shared/widgets/buttons/botao_voltar.dart';
import '../../../shared/widgets/buttons/glass_circle_button.dart';
import '../../../shared/widgets/outlined_tag_pill.dart';
import '../../../shared/widgets/synopsis_scroll_box.dart';
import '../../projects/widgets/project_bottom_sheet_frame.dart';

part '../utils/characters_utils.dart';
part '../models/characters_models.dart';
part '../widgets/character_card.dart';
part '../widgets/character_fields.dart';
part '../widgets/character_overlays.dart';

class CharactersSection extends StatefulWidget {
  const CharactersSection({super.key});

  static const List<_CharacterCardData> _initialCharacters = <_CharacterCardData>[
    _CharacterCardData(
      name: 'Personagem 1',
      alias: 'Vulgo Personagem 1',
      accent: Color(0xFFE4C2D7),
      avatarColor: Color(0xFFF4B37E),
      icon: Icons.person_rounded,
      birthYear: 2002,
      birthDay: 21,
      birthMonth: 3,
      heightCm: 168,
      weightKg: 58,
      quote: 'Frase de efeito do personagem.',
      synopsis: '',
      seed: 11,
    ),
    _CharacterCardData(
      name: 'Personagem 2',
      alias: 'Vulgo Personagem 2',
      accent: Color(0xFFD9D4E9),
      avatarColor: Color(0xFF7EA7F4),
      icon: Icons.person_rounded,
      birthYear: 1998,
      birthDay: 8,
      birthMonth: 11,
      heightCm: 182,
      weightKg: 74,
      quote: 'Outra frase de efeito do personagem.',
      synopsis: '',
      seed: 23,
    ),
    _CharacterCardData(
      name: 'Personagem 3',
      alias: 'Vulgo Personagem 3',
      accent: Color(0xFFE7E0B7),
      avatarColor: Color(0xFFF4B37E),
      icon: Icons.person_rounded,
      birthYear: 2001,
      birthDay: 19,
      birthMonth: 7,
      heightCm: 175,
      weightKg: 67,
      quote: 'Frase de efeito do personagem.',
      synopsis: '',
      seed: 37,
    ),
  ];

  @override
  State<CharactersSection> createState() => _CharactersSectionState();
}

class _CharactersSectionState extends State<CharactersSection> {
  late List<_CharacterListItem> _characters;

  @override
  void initState() {
    super.initState();
    _characters = CharactersSection._initialCharacters
        .indexed
        .map(
          (entry) => _CharacterListItem(
            data: entry.$2,
            unpinnedIndex: entry.$1,
          ),
        )
        .toList(growable: true);
  }

  void _togglePinned(_CharacterListItem character) {
    setState(() {
      final currentIndex = _characters.indexOf(character);
      if (currentIndex == -1) return;

      if (!character.isPinned) {
        character.unpinnedIndex = _unpinnedIndexAt(currentIndex);
      }

      _characters.removeAt(currentIndex);
      character.isPinned = !character.isPinned;

      if (character.isPinned) {
        _characters.insert(0, character);
      } else {
        final pinnedCount = _characters.where((item) => item.isPinned).length;
        final unpinnedCount = _characters.length - pinnedCount;
        final targetUnpinnedIndex = character.unpinnedIndex.clamp(0, unpinnedCount);
        _characters.insert(pinnedCount + targetUnpinnedIndex, character);
        _updateUnpinnedSlots();
      }
    });
  }

  int _unpinnedIndexAt(int listIndex) {
    var count = 0;

    for (var index = 0; index < listIndex; index += 1) {
      if (!_characters[index].isPinned) {
        count += 1;
      }
    }

    return count;
  }

  void _updateUnpinnedSlots() {
    var unpinnedIndex = 0;

    for (final character in _characters) {
      if (!character.isPinned) {
        character.unpinnedIndex = unpinnedIndex;
        unpinnedIndex += 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 160),
      itemCount: _characters.length,
      itemBuilder: (context, index) {
        final character = _characters[index];
        return _CharacterCard(
          key: ValueKey(character.data.seed),
          data: character.data,
          isPinned: character.isPinned,
          onTogglePinned: () => _togglePinned(character),
        );
      },
    );
  }
}

class _CharacterListItem {
  final _CharacterCardData data;
  bool isPinned = false;
  int unpinnedIndex;

  _CharacterListItem({
    required this.data,
    required this.unpinnedIndex,
  });
}
