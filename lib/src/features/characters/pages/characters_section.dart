import 'package:flutter/material.dart';

import '../models/characters_models.dart';
import '../widgets/character_card.dart';

class CharactersSection extends StatelessWidget {
  final List<CharacterListItem> characters;
  final ValueChanged<CharacterListItem> onTogglePinned;

  const CharactersSection({
    super.key,
    required this.characters,
    required this.onTogglePinned,
  });

  @override
  Widget build(BuildContext context) {
    if (characters.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(32, 20, 32, 160),
          child: Text(
            'Nenhum personagem criado. Clique no "+" para criar um!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF544959),
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 160),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        return CharacterCard(
          key: ValueKey(character.data.seed),
          data: character.data,
          isPinned: character.isPinned,
          onTogglePinned: () => onTogglePinned(character),
        );
      },
    );
  }
}
