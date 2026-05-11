part of '../note_editor_page.dart';

class _EditorContextCard extends StatelessWidget {
  final Color accent;
  final NoteMetadata metadata;
  final bool isPreviewMode;
  final VoidCallback onSelectWrite;
  final VoidCallback onSelectPreview;
  final VoidCallback onEditAssociations;

  const _EditorContextCard({
    required this.accent,
    required this.metadata,
    required this.isPreviewMode,
    required this.onSelectWrite,
    required this.onSelectPreview,
    required this.onEditAssociations,
  });

  @override
  Widget build(BuildContext context) {
    return NotesGlassCard(
      accentColor: accent,
      elevated: true,
      radius: 18,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _EditorModeToggle(
                  isPreviewMode: isPreviewMode,
                  onSelectWrite: onSelectWrite,
                  onSelectPreview: onSelectPreview,
                ),
              ),
              const SizedBox(width: 10),
              _HeaderActionButton(
                icon: Icons.sell_outlined,
                tooltip: 'Editar tags e vínculos',
                onTap: onEditAssociations,
                tint: accent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _NoteSummaryRow(metadata: metadata),
        ],
      ),
    );
  }
}

class _EditorModeToggle extends StatelessWidget {
  final bool isPreviewMode;
  final VoidCallback onSelectWrite;
  final VoidCallback onSelectPreview;

  const _EditorModeToggle({
    required this.isPreviewMode,
    required this.onSelectWrite,
    required this.onSelectPreview,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const indicatorWidth = 28.0;
          final tabWidth = constraints.maxWidth / 2;
          final indicatorLeft =
              (isPreviewMode ? 1 : 0) * tabWidth +
              ((tabWidth - indicatorWidth) / 2);

          return Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ModeToggleButton(
                      label: 'Editar',
                      isSelected: !isPreviewMode,
                      onTap: onSelectWrite,
                    ),
                  ),
                  Expanded(
                    child: _ModeToggleButton(
                      label: 'Visualizar',
                      isSelected: isPreviewMode,
                      onTap: onSelectPreview,
                    ),
                  ),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: indicatorLeft,
                bottom: 2,
                child: IgnorePointer(
                  child: Container(
                    width: indicatorWidth,
                    height: 2.6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEB76AE),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFEB76AE,
                          ).withValues(alpha: 0.26),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? kNotesText : kNotesMutedText;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                color: foreground,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkdownPreviewPane extends StatelessWidget {
  final String text;
  final ScrollController scrollController;
  final ValueChanged<String?> onTapLink;

  const _MarkdownPreviewPane({
    super.key,
    required this.text,
    required this.scrollController,
    required this.onTapLink,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const SizedBox.expand(
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Nada para visualizar ainda.',
              style: TextStyle(
                color: kNotesMutedText,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SynopsisScrollBox(
          controller: scrollController,
          height: constraints.maxHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                    child: MarkdownBody(
                      data: text,
                      selectable: false,
                      inlineSyntaxes: <md.InlineSyntax>[
                        _MentionInlineSyntax.fromRegistry(
                          StoryRegistry.instance,
                        ),
                      ],
                      builders: <String, MarkdownElementBuilder>{
                        'mention': _MentionPreviewBuilder(
                          onTapMention: onTapLink,
                        ),
                      },
                      onTapLink: (text, href, title) => onTapLink(href),
                      styleSheet:
                          MarkdownStyleSheet.fromTheme(
                            Theme.of(context),
                          ).copyWith(
                            a: const TextStyle(
                              color: kNotesPink,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w600,
                            ),
                            p: const TextStyle(
                              color: kNotesText,
                              fontSize: 15,
                              height: 1.5,
                            ),
                            h1: const TextStyle(
                              color: kNotesText,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                            h2: const TextStyle(
                              color: kNotesText,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            h3: const TextStyle(
                              color: kNotesPlum,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            blockquote: const TextStyle(
                              color: kNotesMutedText,
                              fontSize: 14,
                              height: 1.45,
                            ),
                            code: const TextStyle(
                              color: Color(0xFF3A3140),
                              backgroundColor: Color(0x14DF6EB8),
                            ),
                          ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MarkdownEditorPane extends StatefulWidget {
  final _MentionAutocompleteTextController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final VoidCallback onChanged;

  const _MarkdownEditorPane({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    required this.onChanged,
  });

  @override
  State<_MarkdownEditorPane> createState() => _MarkdownEditorPaneState();
}

class _MarkdownEditorPaneState extends State<_MarkdownEditorPane> {
  late final TapGestureRecognizer _ghostTapRecognizer;
  String? _mentionQuery;
  List<MentionTargetRef> _mentionOptions = const <MentionTargetRef>[];

  @override
  void initState() {
    super.initState();
    _ghostTapRecognizer = TapGestureRecognizer()..onTap = _acceptGhost;
    widget.controller.ghostTapRecognizer = _ghostTapRecognizer;
    widget.controller.addListener(_syncMentionState);
    widget.focusNode.addListener(_syncMentionState);
    _syncMentionState();
  }

  @override
  void didUpdateWidget(covariant _MarkdownEditorPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncMentionState);
      widget.controller.addListener(_syncMentionState);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_syncMentionState);
      widget.focusNode.addListener(_syncMentionState);
    }
    _syncMentionState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncMentionState);
    widget.focusNode.removeListener(_syncMentionState);
    widget.controller.ghostTapRecognizer = null;
    _ghostTapRecognizer.dispose();
    super.dispose();
  }

  void _syncMentionState() {
    final controller = widget.controller;
    if (!widget.focusNode.hasFocus) {
      _mentionQuery = null;
      _mentionOptions = const <MentionTargetRef>[];
      controller.updateGhost(null);
      return;
    }

    final value = controller.value;
    final selection = value.selection;
    if (!selection.isValid || !selection.isCollapsed) {
      _mentionQuery = null;
      _mentionOptions = const <MentionTargetRef>[];
      controller.updateGhost(null);
      return;
    }

    final query = _extractMentionQuery(value);
    if (query == null) {
      _mentionQuery = null;
      _mentionOptions = const <MentionTargetRef>[];
      controller.updateGhost(null);
      return;
    }

    final atIndex = value.text.lastIndexOf('@', selection.end - 1);
    if (atIndex == -1) {
      _mentionQuery = null;
      _mentionOptions = const <MentionTargetRef>[];
      controller.updateGhost(null);
      return;
    }

    final options = StoryRegistry.instance.searchMentionTargets(
      query,
      limit: 6,
    );
    _mentionQuery = query;
    _mentionOptions = options;
    if (options.isEmpty) {
      controller.updateGhost(null);
      return;
    }

    final target = _resolveGhostTarget(query, options)!;
    final suffix = _resolveGhostSuffix(query, target.label);
    if (suffix.isEmpty) {
      _mentionQuery = query;
      _mentionOptions = options;
      controller.updateGhost(null);
      return;
    }

    controller.updateGhost(
      _MentionGhost(
        start: atIndex,
        end: selection.end,
        target: target,
        suffix: suffix,
      ),
    );
  }

  String? _extractMentionQuery(TextEditingValue value) {
    final selection = value.selection;
    if (!selection.isValid) return null;

    final cursor = selection.end.clamp(0, value.text.length);
    final prefix = value.text.substring(0, cursor);
    final atIndex = prefix.lastIndexOf('@');
    if (atIndex == -1) return null;

    if (atIndex > 0) {
      final previous = prefix[atIndex - 1];
      if (RegExp(r'[A-Za-z0-9_.%+-]').hasMatch(previous)) {
        return null;
      }
    }

    final query = prefix.substring(atIndex + 1);
    if (query.contains(RegExp(r'[\s\r\n]'))) return null;
    return query;
  }

  void _insertMention(MentionTargetRef target) {
    final controller = widget.controller;
    final selection = controller.selection;
    if (!selection.isValid || !selection.isCollapsed) return;

    final cursor = selection.end.clamp(0, controller.text.length);
    final prefix = controller.text.substring(0, cursor);
    final atIndex = prefix.lastIndexOf('@');
    if (atIndex == -1) return;

    final insertText = '@${target.label} ';
    final updatedText = controller.text.replaceRange(
      atIndex,
      cursor,
      insertText,
    );
    controller.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(offset: atIndex + insertText.length),
    );
    widget.onChanged();
    _syncMentionState();
  }

  void _acceptGhost() {
    if (widget.controller.acceptGhostSuggestion()) {
      widget.onChanged();
      _syncMentionState();
    }
  }

  bool _acceptMentionSuggestion() {
    if (widget.controller.acceptGhostSuggestion()) {
      widget.onChanged();
      _syncMentionState();
      return true;
    }

    if (_mentionOptions.isEmpty) {
      return false;
    }

    _insertMention(_mentionOptions.first);
    return true;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (_mentionQuery == null || _mentionOptions.isEmpty) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.tab ||
        event.logicalKey == LogicalKeyboardKey.arrowRight) {
      return _acceptMentionSuggestion()
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        final showSuggestions = _shouldShowMentionPanel();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showSuggestions)
              _MentionSuggestionPanel(
                query: _mentionQuery ?? '',
                options: _mentionOptions,
                onSelected: _insertMention,
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, innerConstraints) {
                  return SynopsisScrollBox(
                    controller: widget.scrollController,
                    childIsScrollable: true,
                    height: innerConstraints.maxHeight,
                    child: Focus(
                      onKeyEvent: _handleKeyEvent,
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        scrollController: widget.scrollController,
                        scrollPhysics: const ClampingScrollPhysics(),
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: 'Markdown é suportado.',
                          filled: true,
                          fillColor: Colors.transparent,
                          hintStyle: TextStyle(
                            color: kNotesMutedText.withValues(alpha: 0.72),
                            height: 1.4,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.fromLTRB(
                            14,
                            14,
                            14,
                            18,
                          ),
                        ),
                        style: const TextStyle(
                          color: kNotesText,
                          fontSize: 15,
                          height: 1.5,
                        ),
                        onChanged: (_) {
                          widget.onChanged();
                          _syncMentionState();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  bool _shouldShowMentionPanel() => _mentionQuery != null;
}
