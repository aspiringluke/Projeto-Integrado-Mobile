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
part '../repositories/characters_mock_repository.dart';
part '../controllers/characters_pin_controller.dart';
part '../widgets/character_card.dart';
part '../widgets/character_fields.dart';
part '../widgets/character_overlays.dart';

class CharactersSection extends StatefulWidget {
  const CharactersSection({super.key});

  @override
  State<CharactersSection> createState() => _CharactersSectionState();
}

class _CharactersSectionState extends State<CharactersSection> {
  final _mockRepository = const _CharactersMockRepository();
  final _pinController = const _CharactersPinController();
  late List<_CharacterListItem> _characters;

  @override
  void initState() {
    super.initState();
    _characters = _pinController.toListItems(_mockRepository.fetchCharacters());
  }

  void _togglePinned(_CharacterListItem character) {
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
