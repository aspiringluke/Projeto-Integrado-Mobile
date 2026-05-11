part of '../note_editor_page.dart';

class _MentionSuggestionPanel extends StatelessWidget {
  final String query;
  final List<MentionTargetRef> options;
  final ValueChanged<MentionTargetRef> onSelected;

  const _MentionSuggestionPanel({
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
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kNotesPlum.withValues(alpha: 0.11)),
          boxShadow: [
            BoxShadow(
              color: kNotesPlum.withValues(alpha: 0.05),
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
              _GhostMentionSuggestion(
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
                    return _MentionSuggestionTile(
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

class _MentionSuggestionTile extends StatelessWidget {
  final MentionTargetRef option;
  final VoidCallback onTap;

  const _MentionSuggestionTile({required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = _mentionKindIcon(option.kind);
    final kindLabel = _mentionKindLabel(option.kind);

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
              Icon(icon, size: 16, color: option.accentColor),
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
                kindLabel,
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

IconData _mentionInlineIcon(MentionTargetKind kind) {
  return switch (kind) {
    MentionTargetKind.project => Icons.work_outline_rounded,
    MentionTargetKind.character => Icons.person_outline_rounded,
    MentionTargetKind.note => Icons.description_outlined,
    MentionTargetKind.folder => Icons.folder_outlined,
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

class _GhostMentionSuggestion extends StatelessWidget {
  final String query;
  final MentionTargetRef target;
  final String ghostSuffix;

  const _GhostMentionSuggestion({
    required this.query,
    required this.target,
    required this.ghostSuffix,
  });

  @override
  Widget build(BuildContext context) {
    final accent = target.accentColor;
    final fadedAccent = accent.withValues(alpha: 0.34);

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
              style: TextStyle(color: fadedAccent),
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

class _MentionPreviewBuilder extends MarkdownElementBuilder {
  final ValueChanged<String?> onTapMention;

  _MentionPreviewBuilder({required this.onTapMention});

  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final href = element.attributes['href'];
    final target = href == null
        ? null
        : StoryRegistry.instance.findMentionTargetByUri(href);
    final accent = target?.accentColor ?? kNotesPink;
    final label = element.textContent.trim().replaceFirst(RegExp(r'^@'), '');

    return _MentionInlineLink(
      label: '@$label',
      kind: target?.kind ?? MentionTargetKind.note,
      accentColor: accent,
      onTap: () => onTapMention(href),
    );
  }
}

class _MentionInlineLink extends StatelessWidget {
  final String label;
  final MentionTargetKind kind;
  final Color accentColor;
  final VoidCallback onTap;

  const _MentionInlineLink({
    required this.label,
    required this.kind,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: accentColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
                height: 1.0,
              ),
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    _mentionInlineIcon(kind),
                    size: 13,
                    color: accentColor,
                  ),
                ),
                const WidgetSpan(child: SizedBox(width: 4)),
                TextSpan(text: label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MentionInlineSyntax extends md.InlineSyntax {
  final Map<String, MentionTargetRef> _targetsByToken;

  _MentionInlineSyntax._(this._targetsByToken, String pattern)
    : super(pattern, startCharacter: 0x40, caseSensitive: false);

  factory _MentionInlineSyntax.fromRegistry(StoryRegistry registry) {
    final targetsByToken = <String, MentionTargetRef>{};

    void registerToken(String token, MentionTargetRef target) {
      final normalized = _normalizeMentionToken(token);
      if (normalized.isEmpty) return;
      targetsByToken.putIfAbsent(normalized, () => target);
    }

    for (final target in registry.mentionTargets) {
      registerToken(target.label, target);
      for (final term in target.searchTerms) {
        registerToken(term, target);
      }
    }

    final pattern =
        r'@[^\s\r\n`<>\[\]\(\){}@,.;:!?]+(?:\s+[^\s\r\n`<>\[\]\(\){}@,.;:!?]+)*';

    return _MentionInlineSyntax._(targetsByToken, pattern);
  }

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final raw = match[0]!;
    final token = raw.substring(1).trim();
    final target = _targetsByToken[_normalizeMentionToken(token)];
    if (target == null) {
      parser.addNode(md.Text(raw));
      return true;
    }

    final element = md.Element.text('mention', raw);
    element.attributes['href'] = target.uri;
    parser.addNode(element);
    return true;
  }
}

String _normalizeMentionToken(String value) {
  return value.trim().toLowerCase();
}
