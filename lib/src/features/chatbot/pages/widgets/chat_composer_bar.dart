import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/notes_visuals.dart';
import 'package:projeto_integrado_mobile/src/features/shared/story_registry.dart';

class ChatMentionGhost {
  final int start;
  final int end;
  final MentionTargetRef target;
  final String suffix;

  const ChatMentionGhost({
    required this.start,
    required this.end,
    required this.target,
    required this.suffix,
  });
}

class ChatMentionAutocompleteTextController extends TextEditingController {
  ChatMentionGhost? _ghost;
  TapGestureRecognizer? ghostTapRecognizer;

  void updateGhost(ChatMentionGhost? ghost) {
    if (_sameGhost(_ghost, ghost)) return;
    _ghost = ghost;
    notifyListeners();
  }

  bool _sameGhost(ChatMentionGhost? left, ChatMentionGhost? right) {
    if (identical(left, right)) return true;
    if (left == null || right == null) return false;
    return left.start == right.start &&
        left.end == right.end &&
        left.target.uri == right.target.uri &&
        left.suffix == right.suffix;
  }

  bool acceptGhostSuggestion() {
    final ghost = _ghost;
    if (ghost == null) return false;

    final insertText = '@${ghost.target.label} ';
    final updatedText = text.replaceRange(ghost.start, ghost.end, insertText);
    value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(
        offset: ghost.start + insertText.length,
      ),
    );
    return true;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = style ?? const TextStyle();
    final ghost = _ghost;
    if (ghost == null ||
        ghost.start < 0 ||
        ghost.end < ghost.start ||
        ghost.end > text.length ||
        ghost.start > text.length) {
      return super.buildTextSpan(
        context: context,
        style: baseStyle,
        withComposing: withComposing,
      );
    }

    final prefix = text.substring(0, ghost.start);
    final active = text.substring(ghost.start, ghost.end);
    final suffix = text.substring(ghost.end);
    final ghostStyle = baseStyle.copyWith(
      color: ghost.target.accentColor.withValues(alpha: 0.4),
      fontStyle: FontStyle.italic,
    );

    return TextSpan(
      style: baseStyle,
      children: [
        if (prefix.isNotEmpty) TextSpan(text: prefix),
        if (active.isNotEmpty) TextSpan(text: active),
        if (ghost.suffix.isNotEmpty)
          TextSpan(
            text: ghost.suffix,
            style: ghostStyle,
            recognizer: ghostTapRecognizer,
          ),
        if (suffix.isNotEmpty) TextSpan(text: suffix),
      ],
    );
  }
}

class ChatComposerBar extends StatefulWidget {
  final ChatMentionAutocompleteTextController controller;
  final VoidCallback onSend;

  const ChatComposerBar({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  State<ChatComposerBar> createState() => _ChatComposerBarState();
}

class _ChatComposerBarState extends State<ChatComposerBar> {
  static final RegExp _mentionBoundaryPattern = RegExp(r'[A-Za-z0-9_.%+-]');
  static final RegExp _mentionStopPattern = RegExp(r'[\s\r\n]');

  late final TapGestureRecognizer _ghostTapRecognizer;
  final FocusNode _focusNode = FocusNode();
  String? _mentionQuery;
  List<MentionTargetRef> _mentionOptions = const <MentionTargetRef>[];
  bool _isUpdatingGhost = false;

  @override
  void initState() {
    super.initState();
    _ghostTapRecognizer = TapGestureRecognizer()..onTap = _acceptGhost;
    widget.controller.ghostTapRecognizer = _ghostTapRecognizer;
    widget.controller.addListener(_handleControllerChanged);
    _focusNode.addListener(_syncMentionState);
  }

  @override
  void didUpdateWidget(covariant ChatComposerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      oldWidget.controller.ghostTapRecognizer = null;
      widget.controller.ghostTapRecognizer = _ghostTapRecognizer;
      widget.controller.addListener(_handleControllerChanged);
      _syncMentionState();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    widget.controller.ghostTapRecognizer = null;
    _focusNode.dispose();
    _ghostTapRecognizer.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (_isUpdatingGhost) return;
    _syncMentionState();
  }

  void _syncMentionState() {
    final controller = widget.controller;
    if (!_focusNode.hasFocus) {
      _applyMentionState(
        query: null,
        options: const <MentionTargetRef>[],
        ghost: null,
      );
      return;
    }

    final value = controller.value;
    final selection = value.selection;
    if (!selection.isValid || !selection.isCollapsed) {
      _applyMentionState(
        query: null,
        options: const <MentionTargetRef>[],
        ghost: null,
      );
      return;
    }

    final query = _extractMentionQuery(value);
    if (query == null) {
      _applyMentionState(
        query: null,
        options: const <MentionTargetRef>[],
        ghost: null,
      );
      return;
    }

    final atIndex = value.text.lastIndexOf('@', selection.end - 1);
    if (atIndex == -1) {
      _applyMentionState(
        query: null,
        options: const <MentionTargetRef>[],
        ghost: null,
      );
      return;
    }

    final options = StoryRegistry.instance.searchMentionTargets(
      query,
      limit: 6,
    );
    if (options.isEmpty) {
      _applyMentionState(
        query: query,
        options: const <MentionTargetRef>[],
        ghost: null,
      );
      return;
    }

    final target = _resolveGhostTarget(query, options)!;
    final suffix = _resolveGhostSuffix(query, target.label);
    _applyMentionState(
      query: query,
      options: options,
      ghost: suffix.isEmpty
          ? null
          : ChatMentionGhost(
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
      if (_mentionBoundaryPattern.hasMatch(previous)) {
        return null;
      }
    }

    final query = prefix.substring(atIndex + 1);
    if (query.contains(_mentionStopPattern)) return null;
    return query;
  }

  void _applyMentionState({
    required String? query,
    required List<MentionTargetRef> options,
    required ChatMentionGhost? ghost,
  }) {
    if (_mentionQuery != query ||
        !_sameMentionOptions(_mentionOptions, options)) {
      setState(() {
        _mentionQuery = query;
        _mentionOptions = options;
      });
    } else {
      _mentionQuery = query;
      _mentionOptions = options;
    }

    _isUpdatingGhost = true;
    try {
      widget.controller.updateGhost(ghost);
    } finally {
      _isUpdatingGhost = false;
    }
  }

  bool _sameMentionOptions(
    List<MentionTargetRef> current,
    List<MentionTargetRef> next,
  ) {
    if (identical(current, next)) return true;
    if (current.length != next.length) return false;

    for (var index = 0; index < current.length; index += 1) {
      if (current[index].uri != next[index].uri) {
        return false;
      }
    }

    return true;
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
  }

  void _acceptGhost() {
    widget.controller.acceptGhostSuggestion();
  }

  bool _acceptMentionSuggestion() {
    if (widget.controller.acceptGhostSuggestion()) {
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_mentionQuery != null)
              _ChatMentionSuggestionPanel(
                query: _mentionQuery ?? '',
                options: _mentionOptions,
                onSelected: _insertMention,
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                  decoration: BoxDecoration(
                    color: const Color(0xEDFFFFFF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xBFFFFFFF)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDF6EB8).withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Focus(
                          onKeyEvent: _handleKeyEvent,
                          child: TextField(
                            controller: widget.controller,
                            focusNode: _focusNode,
                            minLines: 1,
                            maxLines: 5,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => widget.onSend(),
                            decoration: const InputDecoration(
                              hintText: 'Digite uma ideia...',
                              hintStyle: TextStyle(color: Color(0xFF8B7A8B)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                            ),
                            style: const TextStyle(
                              color: Color(0xFF3A3140),
                              fontSize: 15,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: widget.onSend,
                          child: Ink(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFE68CC0), Color(0xFFCB6AA9)],
                              ),
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
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
    );
  }
}

class _ChatMentionSuggestionPanel extends StatelessWidget {
  final String query;
  final List<MentionTargetRef> options;
  final ValueChanged<MentionTargetRef> onSelected;

  const _ChatMentionSuggestionPanel({
    required this.query,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bestMatch = options.isEmpty
        ? null
        : _resolveGhostTarget(query, options);
    final ghostSuffix = bestMatch == null
        ? ''
        : _resolveGhostSuffix(query, bestMatch.label);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kNotesPlum.withValues(alpha: 0.11)),
          boxShadow: [
            BoxShadow(
              color: kNotesPlum.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (bestMatch != null && ghostSuffix.isNotEmpty) ...[
              _ChatGhostMentionSuggestion(
                query: query,
                target: bestMatch,
                ghostSuffix: ghostSuffix,
              ),
              const SizedBox(height: 6),
            ],
            if (options.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Text(
                  'Sem resultados',
                  style: TextStyle(color: kNotesMutedText, fontSize: 11),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 176),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return _ChatMentionSuggestionTile(
                      option: option,
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatMentionSuggestionTile extends StatelessWidget {
  final MentionTargetRef option;
  final VoidCallback onTap;

  const _ChatMentionSuggestionTile({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: option.accentColor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Icon(
                _mentionKindIcon(option.kind),
                size: 16,
                color: option.accentColor,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '@${option.label}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: option.accentColor,
                    fontSize: 12.2,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _mentionKindLabel(option.kind),
                style: TextStyle(
                  color: kNotesMutedText.withValues(alpha: 0.82),
                  fontSize: 10.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatGhostMentionSuggestion extends StatelessWidget {
  final String query;
  final MentionTargetRef target;
  final String ghostSuffix;

  const _ChatGhostMentionSuggestion({
    required this.query,
    required this.target,
    required this.ghostSuffix,
  });

  @override
  Widget build(BuildContext context) {
    final accent = target.accentColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 11.3,
            height: 1.1,
            fontWeight: FontWeight.w700,
          ),
          children: [
            TextSpan(
              text: '@',
              style: TextStyle(color: accent.withValues(alpha: 0.92)),
            ),
            TextSpan(
              text: query,
              style: TextStyle(color: accent),
            ),
            TextSpan(
              text: ghostSuffix,
              style: TextStyle(color: accent.withValues(alpha: 0.34)),
            ),
            TextSpan(
              text: '  toque para inserir',
              style: TextStyle(
                color: kNotesMutedText.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _mentionKindIcon(MentionTargetKind kind) {
  return switch (kind) {
    MentionTargetKind.project => Icons.work_outline_rounded,
    MentionTargetKind.character => Icons.person_outline_rounded,
    MentionTargetKind.note => Icons.description_outlined,
    MentionTargetKind.folder => Icons.folder_outlined,
  };
}

String _mentionKindLabel(MentionTargetKind kind) {
  return switch (kind) {
    MentionTargetKind.project => 'Projeto',
    MentionTargetKind.character => 'Personagem',
    MentionTargetKind.note => 'Nota',
    MentionTargetKind.folder => 'Pasta',
  };
}

MentionTargetRef? _resolveGhostTarget(
  String query,
  List<MentionTargetRef> options,
) {
  final normalizedQuery = _normalizeMentionToken(query);
  if (normalizedQuery.isEmpty) return options.isEmpty ? null : options.first;

  for (final option in options) {
    final normalizedLabel = _normalizeMentionToken(option.label);
    if (normalizedLabel.startsWith(normalizedQuery)) {
      return option;
    }
  }

  return options.first;
}

String _resolveGhostSuffix(String query, String label) {
  final normalizedQuery = _normalizeMentionToken(query);
  final normalizedLabel = _normalizeMentionToken(label);
  if (normalizedQuery.isEmpty) return '';
  if (!normalizedLabel.startsWith(normalizedQuery)) return '';

  final typedLength = query.length.clamp(0, label.length);
  return label.substring(typedLength);
}

String _normalizeMentionToken(String value) {
  return value.trim().toLowerCase();
}
