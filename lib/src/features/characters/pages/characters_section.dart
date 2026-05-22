import 'package:flutter/material.dart';

import '../models/characters_models.dart';
import '../widgets/character_card.dart';
import '../widgets/character_card_visuals.dart';
import '../widgets/character_notebook_page.dart';
import '../widgets/character_profile_viewer_dialog.dart';
import '../../../shared/widgets/buttons/glass_circle_button.dart';
import '../../../shared/widgets/view_options_bar.dart';

class CharactersSection extends StatelessWidget {
  final List<CharacterListItem> characters;
  final ValueChanged<CharacterListItem> onTogglePinned;
  final ValueChanged<CharacterListItem> onCharacterViewed;
  final void Function(
    CharacterListItem character,
    CharacterCardData updatedData,
  )
  onCharacterEdited;
  final ValueChanged<CharacterListItem> onCharacterDeleted;
  final bool showAvatarGrid;
  final int avatarGridColumns;
  final VoidCallback onToggleDisplayMode;
  final ValueChanged<int> onChangeAvatarGridColumns;

  const CharactersSection({
    super.key,
    required this.characters,
    required this.onTogglePinned,
    required this.onCharacterViewed,
    required this.onCharacterEdited,
    required this.onCharacterDeleted,
    required this.showAvatarGrid,
    required this.avatarGridColumns,
    required this.onToggleDisplayMode,
    required this.onChangeAvatarGridColumns,
  });

  Future<void> _openCharacterPage(
    BuildContext context,
    CharacterListItem character,
  ) async {
    onCharacterViewed(character);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CharacterNotebookPage(
          data: character.data,
          onChanged: (updatedData) => onCharacterEdited(character, updatedData),
        ),
      ),
    );
    onCharacterViewed(character);
  }

  Future<void> _openCharacterProfileViewer(
    BuildContext context,
    CharacterListItem character,
  ) async {
    if (character.data.profileImage.bytes == null) {
      return;
    }

    onCharacterViewed(character);
    await showCharacterProfileViewerDialog(
      context,
      characterName: character.data.name,
      profileImage: character.data.profileImage,
    );
    onCharacterViewed(character);
  }

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
          child: ViewOptionsBar(
            title: 'Visualização',
            modeIcon: showAvatarGrid
                ? Icons.grid_view_rounded
                : Icons.view_list_rounded,
            modeLabel: showAvatarGrid ? 'Grade' : 'Lista',
            toggleTooltip: showAvatarGrid
                ? 'Exibir em lista'
                : 'Exibir em grade',
            onToggleMode: onToggleDisplayMode,
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
          key: ValueKey(character.id ?? character.data.seed),
          data: character.data,
          createdAt: character.createdAt,
          lastModified: character.lastModified,
          lastAccessed: character.lastAccessed,
          isPinned: character.isPinned,
          onTogglePinned: () => onTogglePinned(character),
          onViewed: () => onCharacterViewed(character),
          onEdited: (updatedData) => onCharacterEdited(character, updatedData),
          onDelete: () => onCharacterDeleted(character),
        );
      },
    );
  }

  Widget _buildAvatarGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 160),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.94,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        return Tooltip(
          message: character.data.name,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => _openCharacterPage(context, character),
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
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
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
                                showExpandHint: false,
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
                                        character.data.accent.withValues(
                                          alpha: 0.08,
                                        ),
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
                                      character.data.accent.withValues(
                                        alpha: 0.72,
                                      ),
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
                                      color: Colors.black.withValues(
                                        alpha: 0.16,
                                      ),
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
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
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
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: -4,
                      child: CharacterPinBadge(
                        isActive: character.isPinned,
                        onTap: () => onTogglePinned(character),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (character.data.profileImage.bytes != null) ...[
                            GlassCircleButton(
                              diameter: 26,
                              onTap: () => _openCharacterProfileViewer(
                                context,
                                character,
                              ),
                              tooltip: 'Ver imagem',
                              fillColor: Colors.white.withValues(alpha: 0.16),
                              borderColor: Colors.white.withValues(alpha: 0.74),
                              borderWidth: 0.8,
                              blurSigma: 12,
                              child: Icon(
                                Icons.open_in_full_rounded,
                                size: 13,
                                color: Colors.white.withValues(alpha: 0.96),
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.28),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                          GlassCircleButton(
                            diameter: 26,
                            onTap: () => onCharacterDeleted(character),
                            tooltip: 'Excluir personagem',
                            fillColor: Colors.white.withValues(alpha: 0.16),
                            borderColor: Colors.white.withValues(alpha: 0.74),
                            borderWidth: 0.8,
                            blurSigma: 12,
                            child: Icon(
                              Icons.delete_outline_rounded,
                              size: 13,
                              color: Colors.white.withValues(alpha: 0.96),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.28),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
