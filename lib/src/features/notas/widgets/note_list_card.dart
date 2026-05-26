import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/models/content_stats.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';
import 'package:projeto_integrado_mobile/src/shared/widgets/pin_badge.dart';

import 'notes_card_widgets.dart';
import 'notes_visuals.dart';

enum _NoteDateType { lastModified, lastAccessed, createdAt }

class NoteListCard extends StatefulWidget {
  final String title;
  final String text;
  final Color highlightColor;
  final NoteMetadata metadata;
  final DateTime createdAt;
  final DateTime lastModified;
  final DateTime lastAccessed;
  final VoidCallback? onTap;
  final VoidCallback? onMoveTo;
  final VoidCallback? onDelete;
  final VoidCallback? onTogglePinned;
  final VoidCallback? onToggleSelection;
  final bool selectionMode;
  final bool isSelected;
  final bool isPinned;
  final bool showActions;

  const NoteListCard({
    super.key,
    required this.title,
    required this.text,
    required this.highlightColor,
    required this.metadata,
    required this.createdAt,
    required this.lastModified,
    required this.lastAccessed,
    this.onTap,
    this.onMoveTo,
    this.onDelete,
    this.onTogglePinned,
    this.onToggleSelection,
    this.selectionMode = false,
    this.isSelected = false,
    this.isPinned = false,
    this.showActions = true,
  });

  @override
  State<NoteListCard> createState() => _NoteListCardState();
}

class _NoteListCardState extends State<NoteListCard> {
  _NoteDateType _activeDateType = _NoteDateType.lastModified;
  String? _cachedText;
  ContentStats _cachedContentStats = const ContentStats.zero();
  String _cachedPreview = '';

  void _cycleDateType() {
    setState(() {
      _activeDateType = switch (_activeDateType) {
        _NoteDateType.lastModified => _NoteDateType.lastAccessed,
        _NoteDateType.lastAccessed => _NoteDateType.createdAt,
        _NoteDateType.createdAt => _NoteDateType.lastModified,
      };
    });
  }

  NotesDateEntry get _currentDateEntry {
    return switch (_activeDateType) {
      _NoteDateType.lastModified => NotesDateEntry(
        label: 'Modificação',
        value: widget.lastModified,
      ),
      _NoteDateType.lastAccessed => NotesDateEntry(
        label: 'Acesso',
        value: widget.lastAccessed,
      ),
      _NoteDateType.createdAt => NotesDateEntry(
        label: 'Criação',
        value: widget.createdAt,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    _syncTextCache();
    final contentStats = _cachedContentStats;
    final preview = _cachedPreview;
    final metrics = contentStats.isEmpty
        ? const <Widget>[]
        : _buildMetricChips(contentStats);
    final chips = _buildSummaryChips();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.selectionMode
                  ? widget.onToggleSelection
                  : widget.onTap,
              onLongPress: widget.onToggleSelection,
              borderRadius: BorderRadius.circular(18),
              child: NotesGlassCard(
                accentColor: widget.highlightColor,
                elevated: true,
                radius: 18,
                padding: const EdgeInsets.fromLTRB(13, 15, 13, 11),
                boxShadow: [
                  if (widget.isSelected)
                    BoxShadow(
                      color: widget.highlightColor.withValues(alpha: 0.24),
                      blurRadius: 0,
                      spreadRadius: 1.2,
                      offset: Offset.zero,
                    ),
                  BoxShadow(
                    color: widget.highlightColor.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.3),
                                widget.highlightColor.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.highlightColor.withValues(
                                alpha: 0.55,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.sticky_note_2_outlined,
                            color: widget.highlightColor,
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kNotesText,
                              fontSize: 16.1,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        if (widget.selectionMode)
                          NotesActionIconButton(
                            icon: widget.isSelected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            tooltip: widget.isSelected
                                ? 'Desmarcar'
                                : 'Selecionar',
                            onTap: widget.onToggleSelection,
                          )
                        else if (widget.showActions)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NotesActionIconButton(
                                icon: Icons.drive_file_move_outline,
                                tooltip: 'Mover nota',
                                onTap: widget.onMoveTo,
                              ),
                              const SizedBox(width: 6),
                              NotesActionIconButton(
                                icon: Icons.delete_outline_rounded,
                                tooltip: 'Excluir nota',
                                onTap: widget.onDelete,
                                destructive: true,
                              ),
                            ],
                          )
                        else
                          const Icon(
                            Icons.drag_indicator_rounded,
                            color: kNotesMutedText,
                            size: 20,
                          ),
                      ],
                    ),
                    if (preview.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      _FadingPreviewLine(text: preview),
                    ],
                    if (metrics.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Wrap(spacing: 5, runSpacing: 5, children: metrics),
                    ],
                    const SizedBox(height: 8),
                    NotesDateCycleField(
                      accentColor: widget.highlightColor,
                      dateEntry: _currentDateEntry,
                      onTapClock: _cycleDateType,
                    ),
                    if (chips.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(spacing: 6, runSpacing: 6, children: chips),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (widget.onTogglePinned != null)
            Positioned(
              left: 0,
              top: -4,
              child: PinBadge(
                isActive: widget.isPinned,
                onTap: widget.onTogglePinned,
              ),
            ),
        ],
      ),
    );
  }

  void _syncTextCache() {
    if (_cachedText == widget.text) {
      return;
    }

    _cachedText = widget.text;
    _cachedContentStats = ContentStats.fromText(widget.text);
    _cachedPreview = buildNotePreview(widget.text);
  }

  List<Widget> _buildSummaryChips() {
    final chips = <Widget>[];
    final linkTarget = widget.metadata.linkTarget;

    if (linkTarget.projectTitle != null &&
        linkTarget.projectTitle!.trim().isNotEmpty) {
      chips.add(
        NotesSummaryChip(
          label: linkTarget.projectTitle!.trim(),
          icon: Icons.work_outline_rounded,
          tint: widget.highlightColor,
        ),
      );
    } else {
      chips.add(
        const NotesSummaryChip(
          label: 'Sem vínculo',
          icon: Icons.link_off_rounded,
          tint: kNotesMutedText,
        ),
      );
    }

    if (linkTarget.characterName != null &&
        linkTarget.characterName!.trim().isNotEmpty) {
      chips.add(
        NotesSummaryChip(
          label: linkTarget.characterName!.trim(),
          icon: Icons.person_outline_rounded,
        ),
      );
    }

    for (final group in widget.metadata.tagGroups) {
      for (final tag in group.tags) {
        chips.add(
          NotesSummaryChip(
            label: '${group.title}: ${tag.label}',
            icon: Icons.label_outline_rounded,
            tint: group.color,
          ),
        );
      }
    }

    return chips.take(6).toList(growable: false);
  }

  List<Widget> _buildMetricChips(ContentStats stats) {
    return <Widget>[
      NotesMetricChip(
        icon: Icons.short_text_rounded,
        label: 'Palavras',
        value: stats.words,
        accentColor: widget.highlightColor,
      ),
      NotesMetricChip(
        icon: Icons.onetwothree_rounded,
        label: 'Caracteres',
        value: stats.characters,
        accentColor: widget.highlightColor,
      ),
      NotesMetricChip(
        icon: Icons.alternate_email_rounded,
        label: 'Menções',
        value: stats.mentions,
        accentColor: widget.highlightColor,
      ),
    ];
  }
}

class _FadingPreviewLine extends StatelessWidget {
  final String text;

  const _FadingPreviewLine({required this.text});

  @override
  Widget build(BuildContext context) {
    final previewColor = kNotesMutedText.withValues(alpha: 0.94);

    return SizedBox(
      height: 20,
      child: Row(
        children: [
          Expanded(
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    previewColor,
                    previewColor,
                    previewColor.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.8, 1.0],
                ).createShader(bounds);
              },
              child: Text(
                text,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  color: previewColor,
                  fontSize: 11.2,
                  height: 1.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '...',
            style: TextStyle(
              color: previewColor.withValues(alpha: 0.72),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
