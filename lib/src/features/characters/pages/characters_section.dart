import 'package:flutter/material.dart';

import '../models/characters_models.dart';
import '../widgets/character_card.dart';
import '../widgets/character_card_visuals.dart';
import '../widgets/character_notebook_page.dart';
import '../widgets/character_profile_viewer_dialog.dart';
import '../../../shared/widgets/buttons/glass_circle_button.dart';
import '../../../shared/widgets/multi_select_action_bar.dart';
import '../../../shared/widgets/view_options_bar.dart';

class CharactersSection extends StatefulWidget {
  final List<CharacterListItem> characters;
  final ValueChanged<CharacterListItem> onTogglePinned;
  final ValueChanged<CharacterListItem> onCharacterViewed;
  final void Function(
    CharacterListItem character,
    CharacterCardData updatedData,
  )
  onCharacterEdited;
  final ValueChanged<CharacterListItem> onCharacterDeleted;
  final ValueChanged<List<CharacterListItem>> onCharactersDeleted;
  final bool showAvatarGrid;
  final int avatarGridColumns;
  final VoidCallback onToggleDisplayMode;
  final ValueChanged<int> onChangeAvatarGridColumns;
  final String emptyMessage;

  const CharactersSection({
    super.key,
    required this.characters,
    required this.onTogglePinned,
    required this.onCharacterViewed,
    required this.onCharacterEdited,
    required this.onCharacterDeleted,
    required this.onCharactersDeleted,
    required this.showAvatarGrid,
    required this.avatarGridColumns,
    required this.onToggleDisplayMode,
    required this.onChangeAvatarGridColumns,
    this.emptyMessage =
        'Nenhum personagem criado. Clique no "+" para criar um!',
  });

  @override
  State<CharactersSection> createState() => _CharactersSectionState();
}

class _CharactersSectionState extends State<CharactersSection> {
  bool _selectionMode = false;
  final Set<int> _selectedCharacterIds = <int>{};

  bool get _isSelectionMode => _selectionMode;

  void _toggleSelectionMode() {
    if (_selectionMode || _selectedCharacterIds.isNotEmpty) {
      _clearSelection();
      return;
    }

    setState(() {
      _selectionMode = true;
    });
  }

  void _selectAllCharacters() {
    setState(() {
      _selectionMode = true;
      _selectedCharacterIds
        ..clear()
        ..addAll(
          widget.characters.map((character) => character.id).whereType<int>(),
        );
    });
  }

  void _clearSelection() {
    if (!_selectionMode && _selectedCharacterIds.isEmpty) return;
    setState(() {
      _selectionMode = false;
      _selectedCharacterIds.clear();
    });
  }

  void _toggleCharacterSelection(CharacterListItem character) {
    final characterId = character.id;
    if (characterId == null) return;

    setState(() {
      _selectionMode = true;
      if (!_selectedCharacterIds.add(characterId)) {
        _selectedCharacterIds.remove(characterId);
      }
    });
  }

  bool _isCharacterSelected(CharacterListItem character) {
    final characterId = character.id;
    return characterId != null && _selectedCharacterIds.contains(characterId);
  }

  void _deleteSelectedCharacters() {
    final selectedCharacters = widget.characters
        .where(_isCharacterSelected)
        .toList(growable: false);
    if (selectedCharacters.isEmpty) return;

    widget.onCharactersDeleted(selectedCharacters);
    _clearSelection();
  }

  Future<void> _openCharacterPage(
    BuildContext context,
    CharacterListItem character,
  ) async {
    widget.onCharacterViewed(character);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CharacterNotebookPage(
          data: character.data,
          availableCharacters: widget.characters,
          projectTitle: character.projectTitle,
          onChanged: (updatedData) =>
              widget.onCharacterEdited(character, updatedData),
        ),
      ),
    );
    widget.onCharacterViewed(character);
  }

  Future<void> _openCharacterProfileViewer(
    BuildContext context,
    CharacterListItem character,
  ) async {
    if (character.data.profileImage.bytes == null) {
      return;
    }

    widget.onCharacterViewed(character);
    await showCharacterProfileViewerDialog(
      context,
      characterName: character.data.name,
      profileImage: character.data.profileImage,
    );
    widget.onCharacterViewed(character);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.characters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 160),
          child: Text(
            widget.emptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ViewOptionsBar(
                      title: 'Visualização',
                      modeIcon: widget.showAvatarGrid
                          ? Icons.grid_view_rounded
                          : Icons.view_list_rounded,
                      modeLabel: widget.showAvatarGrid ? 'Grade' : 'Lista',
                      toggleTooltip: widget.showAvatarGrid
                          ? 'Exibir em lista'
                          : 'Exibir em grade',
                      onToggleMode: widget.onToggleDisplayMode,
                    ),
                  ),
                  const SizedBox(width: 8),
                  MultiSelectIconButton(
                    icon: _isSelectionMode
                        ? Icons.close_rounded
                        : Icons.checklist_rounded,
                    tooltip: _isSelectionMode
                        ? 'Sair da seleção'
                        : 'Selecionar',
                    onTap: _toggleSelectionMode,
                  ),
                  const SizedBox(width: 8),
                  MultiSelectIconButton(
                    icon: Icons.select_all_rounded,
                    tooltip: 'Selecionar tudo',
                    onTap: _selectAllCharacters,
                  ),
                ],
              ),
              if (_isSelectionMode) ...[
                const SizedBox(height: 10),
                MultiSelectActionBar(
                  label:
                      '${_selectedCharacterIds.length} personagem(ns) selecionado(s)',
                  onClear: _clearSelection,
                  actions: [
                    MultiSelectAction(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Excluir selecionados',
                      onTap: _deleteSelectedCharacters,
                      destructive: true,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: widget.showAvatarGrid
              ? _buildAvatarGrid()
              : _buildCharacterList(),
        ),
      ],
    );
  }

  Widget _buildCharacterList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 160),
      itemCount: widget.characters.length,
      itemBuilder: (context, index) {
        final character = widget.characters[index];
        final card = CharacterCard(
          key: ValueKey(character.id ?? character.data.seed),
          data: character.data,
          createdAt: character.createdAt,
          lastModified: character.lastModified,
          lastAccessed: character.lastAccessed,
          isPinned: character.isPinned,
          onTogglePinned: () => widget.onTogglePinned(character),
          onViewed: () => widget.onCharacterViewed(character),
          onEdited: (updatedData) =>
              widget.onCharacterEdited(character, updatedData),
          onDelete: () => widget.onCharacterDeleted(character),
        );

        return _CharacterSelectionWrapper(
          selectionMode: _isSelectionMode,
          selected: _isCharacterSelected(character),
          accentColor: character.data.accent,
          onToggleSelection: () => _toggleCharacterSelection(character),
          child: card,
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
      itemCount: widget.characters.length,
      itemBuilder: (context, index) {
        final character = widget.characters[index];
        return Tooltip(
          message: character.data.name,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => _isSelectionMode
                  ? _toggleCharacterSelection(character)
                  : _openCharacterPage(context, character),
              onLongPress: () => _toggleCharacterSelection(character),
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
                        onTap: () => widget.onTogglePinned(character),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _isSelectionMode
                          ? _CharacterSelectionBadge(
                              selected: _isCharacterSelected(character),
                              accentColor: character.data.accent,
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (character.data.profileImage.bytes !=
                                    null) ...[
                                  GlassCircleButton(
                                    diameter: 26,
                                    onTap: () => _openCharacterProfileViewer(
                                      context,
                                      character,
                                    ),
                                    tooltip: 'Ver imagem',
                                    fillColor: Colors.white.withValues(
                                      alpha: 0.16,
                                    ),
                                    borderColor: Colors.white.withValues(
                                      alpha: 0.74,
                                    ),
                                    borderWidth: 0.8,
                                    blurSigma: 12,
                                    child: Icon(
                                      Icons.open_in_full_rounded,
                                      size: 13,
                                      color: Colors.white.withValues(
                                        alpha: 0.96,
                                      ),
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.28,
                                          ),
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
                                  onTap: () =>
                                      widget.onCharacterDeleted(character),
                                  tooltip: 'Excluir personagem',
                                  fillColor: Colors.white.withValues(
                                    alpha: 0.16,
                                  ),
                                  borderColor: Colors.white.withValues(
                                    alpha: 0.74,
                                  ),
                                  borderWidth: 0.8,
                                  blurSigma: 12,
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 13,
                                    color: Colors.white.withValues(alpha: 0.96),
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.28,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                    if (_isSelectionMode && _isCharacterSelected(character))
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: character.data.accent.withValues(
                                  alpha: 0.7,
                                ),
                                width: 2,
                              ),
                              color: character.data.accent.withValues(
                                alpha: 0.08,
                              ),
                            ),
                          ),
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

class _CharacterSelectionWrapper extends StatelessWidget {
  final Widget child;
  final bool selectionMode;
  final bool selected;
  final Color accentColor;
  final VoidCallback onToggleSelection;

  const _CharacterSelectionWrapper({
    required this.child,
    required this.selectionMode,
    required this.selected,
    required this.accentColor,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: onToggleSelection,
      child: Stack(
        children: [
          child,
          if (selectionMode)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onToggleSelection,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: selected
                          ? Border.all(
                              color: accentColor.withValues(alpha: 0.72),
                              width: 2,
                            )
                          : null,
                      color: selected
                          ? accentColor.withValues(alpha: 0.08)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          if (selectionMode)
            Positioned(
              top: 5,
              right: 10,
              child: _CharacterSelectionBadge(
                selected: selected,
                accentColor: accentColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _CharacterSelectionBadge extends StatelessWidget {
  final bool selected;
  final Color accentColor;

  const _CharacterSelectionBadge({
    required this.selected,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.72),
        border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        selected
            ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded,
        size: 18,
        color: selected ? accentColor : const Color(0xFF544959),
      ),
    );
  }
}
