import 'package:flutter/material.dart';

import '../controllers/characters_pin_controller.dart';
import '../models/characters_models.dart';
import '../repositories/characters_mock_repository.dart';
import '../widgets/character_card.dart';

class CharactersSection extends StatefulWidget {
  const CharactersSection({super.key});

  @override
  State<CharactersSection> createState() => _CharactersSectionState();
}

class _CharactersSectionState extends State<CharactersSection> {
  final _mockRepository = const CharactersMockRepository();
  final _pinController = const CharactersPinController();
  late List<CharacterListItem> _characters;

  @override
  void initState() {
    super.initState();
    _characters = _pinController.toListItems(_mockRepository.fetchCharacters());
  }

  void _togglePinned(CharacterListItem character) {
    setState(() {
      _pinController.togglePinned(_characters, character);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 160),
      itemCount: _characters.length,
      itemBuilder: (context, index) {
        final character = _characters[index];
        return CharacterCard(
          key: ValueKey(character.data.seed),
          data: character.data,
          isPinned: character.isPinned,
          onTogglePinned: () => _togglePinned(character),
        );
      },
    );
  }
}
