import 'package:flutter/material.dart';

import '../models/characters_models.dart';
import '../widgets/character_card.dart';
import '../widgets/character_card_visuals.dart';

class CharactersSection extends StatelessWidget {
  final List<CharacterListItem> characters;
  final ValueChanged<CharacterListItem> onTogglePinned;
  final void Function(
    CharacterListItem character,
    CharacterCardData updatedData,
  )
  onCharacterEdited;
  final bool showAvatarGrid;
  final int avatarGridColumns;
  final VoidCallback onToggleDisplayMode;
  final ValueChanged<int> onChangeAvatarGridColumns;

  const CharactersSection({
    super.key,
    required this.characters,
    required this.onTogglePinned,
    required this.onCharacterEdited,
    required this.showAvatarGrid,
    required this.avatarGridColumns,
    required this.onToggleDisplayMode,
    required this.onChangeAvatarGridColumns,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Visualização',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF544959),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (showAvatarGrid) ...[
                PopupMenuButton<int>(
                  tooltip: 'Configuração da grade',
                  initialValue: avatarGridColumns,
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 3, child: Text('3 colunas')),
                    PopupMenuItem(value: 4, child: Text('4 colunas')),
                    PopupMenuItem(value: 5, child: Text('5 colunas')),
                  ],
                  onSelected: onChangeAvatarGridColumns,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.grid_view,
                        color: Color(0xFF544959),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 82),
                        child: Text(
                          '$avatarGridColumns colunas',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF544959),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
              IconButton(
                onPressed: onToggleDisplayMode,
                icon: Icon(
                  showAvatarGrid ? Icons.view_list : Icons.grid_view,
                  color: const Color(0xFF544959),
                ),
                tooltip: showAvatarGrid ? 'Exibir em lista' : 'Exibir em grade',
              ),
              Text(
                showAvatarGrid ? 'Fotos' : 'Lista',
                style: const TextStyle(color: Color(0xFF544959), fontSize: 14),
              ),
            ],
          ),
        ),
        Expanded(
          child: showAvatarGrid ? _buildAvatarGrid() : _buildCharacterList(),
        ),
      ],
    );
  }

  Widget _buildCharacterList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 160),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        return CharacterCard(
          key: ValueKey(character.data.seed),
          data: character.data,
          isPinned: character.isPinned,
          onTogglePinned: () => onTogglePinned(character),
          onEdited: (updatedData) => onCharacterEdited(character, updatedData),
        );
      },
    );
  }

  Widget _buildAvatarGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 160),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: avatarGridColumns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.94,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        return Tooltip(
          message: character.data.name,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CharacterAvatarTile(
                      accent: character.data.accent,
                      avatarColor: character.data.avatarColor,
                      profileImage: character.data.profileImage,
                      isExpanded: false,
                      onTap: null,
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              character.data.accent.withValues(alpha: 0.08),
                              Colors.transparent,
                              character.data.avatarColor.withValues(
                                alpha: 0.06,
                              ),
                            ],
                            stops: const [0.0, 0.48, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (avatarGridColumns == 3)
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              character.data.accent.withValues(alpha: 0.72),
                              character.data.avatarColor.withValues(
                                alpha: 0.28,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.24),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.16),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  character.data.name.split(' ').first,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => onTogglePinned(character),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.84),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.14),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          character.isPinned
                              ? Icons.push_pin
                              : Icons.push_pin_outlined,
                          size: 18,
                          color: character.isPinned
                              ? const Color(0xFF7C4E63)
                              : const Color(0xFF544959),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
