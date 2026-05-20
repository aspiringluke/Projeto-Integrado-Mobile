part of 'project_card.dart';

enum _ProjectDateType { lastModified, lastAccessed, createdAt }

class _ProjectDateEntry {
  final String label;
  final DateTime value;

  const _ProjectDateEntry({required this.label, required this.value});
}

class _ProjectDateEntries {
  final _ProjectDateEntry lastModified;
  final _ProjectDateEntry lastAccessed;
  final _ProjectDateEntry createdAt;

  const _ProjectDateEntries({
    required this.lastModified,
    required this.lastAccessed,
    required this.createdAt,
  });

  factory _ProjectDateEntries.fromValues({
    required DateTime createdAt,
    required DateTime lastModified,
    required DateTime lastAccessed,
  }) {
    return _ProjectDateEntries(
      lastModified: _ProjectDateEntry(
        label: '\u00DAltima modifica\u00E7\u00E3o',
        value: lastModified,
      ),
      lastAccessed: _ProjectDateEntry(
        label: '\u00DAltimo acesso',
        value: lastAccessed,
      ),
      createdAt: _ProjectDateEntry(label: 'Criado', value: createdAt),
    );
  }

  _ProjectDateEntry forType(_ProjectDateType type) {
    return switch (type) {
      _ProjectDateType.lastModified => lastModified,
      _ProjectDateType.lastAccessed => lastAccessed,
      _ProjectDateType.createdAt => createdAt,
    };
  }
}

class _ProjectDetails extends StatelessWidget {
  final String projectTitle;
  final int? projectId;
  final String synopsis;
  final _ProjectDateEntry dateEntry;
  final List<ProjectTagData> tags;
  final List<ProjectTagData> availableTags;
  final Color coverColor;
  final Color accentColor;
  final ProjectImageData coverImage;
  final ProjectImageData accentImage;
  final DateTime createdAt;
  final DateTime lastModified;
  final DateTime lastAccessed;
  final bool isPinned;
  final int unpinnedIndex;
  final List<int> featuredCharacterIds;
  final List<CharacterListItem> displayedCharacters;
  final bool isEditing;
  final TextEditingController synopsisController;
  final VoidCallback onCycleDateType;
  final VoidCallback onToggleEditing;
  final ValueChanged<ProjectRecord>? onProjectChanged;
  final VoidCallback? onProjectReloadRequested;
  final ScrollController synopsisScrollController;

  const _ProjectDetails({
    required this.projectTitle,
    required this.projectId,
    required this.synopsis,
    required this.dateEntry,
    required this.tags,
    required this.availableTags,
    required this.coverColor,
    required this.accentColor,
    required this.coverImage,
    required this.accentImage,
    required this.createdAt,
    required this.lastModified,
    required this.lastAccessed,
    required this.isPinned,
    required this.unpinnedIndex,
    required this.featuredCharacterIds,
    required this.displayedCharacters,
    required this.isEditing,
    required this.synopsisController,
    required this.onCycleDateType,
    required this.onToggleEditing,
    required this.onProjectChanged,
    required this.onProjectReloadRequested,
    required this.synopsisScrollController,
  });

  double _calculateSynopsisHeight(
    BuildContext context,
    double maxWidth,
    String synopsisText,
  ) {
    final text = synopsisText.trim().isEmpty
        ? synopsisPlaceholderText
        : synopsisText;
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF8F8990),
          height: 1.4,
        ),
      ),
      textDirection: Directionality.of(context),
      maxLines: null,
    );
    textPainter.layout(maxWidth: maxWidth - 28);
    const verticalPadding = 28.0;
    final estimatedHeight = textPainter.size.height + verticalPadding;
    final minimumHeight = (12 * 1.4) + verticalPadding;
    return estimatedHeight.clamp(minimumHeight, 220.0);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.22),
                width: 0.7,
              ),
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ProjectAccentFill(accentColor: accentColor),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0.04),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.24, 0.6],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _TimeField(
                            accentColor: accentColor,
                            dateEntry: dateEntry,
                            onTapClock: onCycleDateType,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GlassCircleButton(
                          diameter: 36,
                          onTap: onToggleEditing,
                          blurSigma: 8,
                          fillColor: Colors.white.withValues(alpha: 0.32),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.58),
                              accentColor.withValues(alpha: 0.2),
                              _lighten(
                                accentColor,
                                0.22,
                              ).withValues(alpha: 0.16),
                            ],
                          ),
                          borderColor: Colors.white.withValues(alpha: 0.8),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.14),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          child: Icon(
                            isEditing
                                ? Icons.check_rounded
                                : Icons.edit_outlined,
                            size: 18,
                            color: const Color(0xFF544959),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: synopsisController,
                      builder: (context, value, _) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return EditableSynopsisPanel(
                              controller: synopsisController,
                              scrollController: synopsisScrollController,
                              isEditing: isEditing,
                              height: _calculateSynopsisHeight(
                                context,
                                constraints.maxWidth,
                                value.text,
                              ),
                              focusedBorderColor: accentColor,
                              placeholderText: synopsisPlaceholderText,
                              textStyle: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8F8990),
                                height: 1.4,
                              ),
                              fillColor: Colors.white.withValues(alpha: 0.72),
                              blurSigma: 5,
                              backgroundGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.8),
                                  const Color(
                                    0xFFFFF8FC,
                                  ).withValues(alpha: 0.68),
                                  const Color(
                                    0xFFF1E6EE,
                                  ).withValues(alpha: 0.42),
                                ],
                                stops: const [0.0, 0.55, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.78),
                                width: 0.7,
                              ),
                              placeholderStyle: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Color(0xFF8F8990),
                                fontStyle: FontStyle.italic,
                              ),
                              viewerBuilder: (context, text, style) {
                                return _ProjectMarkdownText(
                                  data: text,
                                  style: style,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    if (tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tag in tags)
                            OutlinedTagPill(label: tag.label, color: tag.color),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (displayedCharacters.isEmpty) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () => _showProjectCharacterInfo(
                                    context,
                                    rectFromContext(context),
                                  ),
                                  child: _ProjectInfoButton(
                                    characters: displayedCharacters,
                                  ),
                                );
                              }

                              return _ProjectInfoButton(
                                characters: displayedCharacters,
                                onCharacterTap: (character) =>
                                    _openDisplayedCharacterPage(
                                      context,
                                      character,
                                    ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        GlassCircleButton(
                          diameter: 34,
                          blurSigma: 6,
                          fillColor: accentColor.withValues(alpha: 0.22),
                          borderColor: Colors.white.withValues(alpha: 0.62),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.56),
                              accentColor.withValues(alpha: 0.22),
                              _lighten(
                                accentColor,
                                0.22,
                              ).withValues(alpha: 0.18),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.14),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          child: const Icon(
                            Icons.swap_horiz,
                            color: Color(0xFF544959),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showProjectCharacterInfo(
    BuildContext context,
    Rect anchorRect,
  ) async {
    final recognizer = TapGestureRecognizer()
      ..onTap = () async {
        Navigator.of(context).pop();
        final updatedProject = await Navigator.of(context).push<ProjectRecord>(
          MaterialPageRoute<ProjectRecord>(
            builder: (_) => ProjectPage(
              projectId: projectId,
              title: projectTitle,
              synopsis: synopsis,
              tags: tags,
              availableTags: availableTags,
              accentColor: accentColor,
              coverColor: coverColor,
              coverImage: coverImage,
              accentImage: accentImage,
              createdAt: createdAt,
              lastModified: lastModified,
              lastAccessed: lastAccessed,
              isPinned: isPinned,
              unpinnedIndex: unpinnedIndex,
              featuredCharacterIds: featuredCharacterIds,
              initialSection: ProjectSectionId.configProjeto,
            ),
          ),
        );
        if (updatedProject != null) {
          onProjectChanged?.call(updatedProject);
          return;
        }
        onProjectReloadRequested?.call();
      };

    await _showAnchoredInfoBubble(
      context: context,
      anchorRect: anchorRect,
      width: 260,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayedCharacters.isEmpty
                ? 'Nenhum personagem exibido aqui.'
                : 'Personagens exibidos',
            style: TextStyle(
              color: Color(0xFF3E313A),
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (displayedCharacters.isNotEmpty) ...[
            const SizedBox(height: 9),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final character in displayedCharacters)
                  _ProjectCharacterNamePill(character: character),
              ],
            ),
          ],
          const SizedBox(height: 7),
          Text(
            'Os 3 personagens de maior relevância são automaticamente exibidos, ou você pode escolher manualmente na',
            style: TextStyle(
              color: const Color(0xFF655862),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: const Color(0xFF655862),
                fontSize: 12,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: 'página de configurações do projeto',
                  style: const TextStyle(
                    color: Color(0xFF7C4E63),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFFB97C98),
                    decorationThickness: 1.2,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                  recognizer: recognizer,
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDisplayedCharacterPage(
    BuildContext context,
    CharacterListItem character,
  ) async {
    final repository = CharacterRepository();
    final navigator = Navigator.of(context);
    final characterId = character.id;
    if (characterId != null) {
      character.lastAccessed = DateTime.now();
      await repository.touchCharacter(characterId);
    }

    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => CharacterNotebookPage(
          data: character.data,
          onChanged: (updatedData) async {
            character.data = updatedData;
            character.lastModified = DateTime.now();
            character.lastAccessed = DateTime.now();

            if (characterId == null) {
              return;
            }

            await repository.saveCharacter(
              character.copyWith(
                projectTitle: character.projectTitle ?? projectTitle,
                data: updatedData,
                lastAccessed: character.lastAccessed,
              ),
            );
          },
        ),
      ),
    );

    if (characterId != null) {
      character.lastAccessed = DateTime.now();
      await repository.touchCharacter(characterId);
    }
    onProjectReloadRequested?.call();
  }
}
