import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/models/content_stats.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/notes_drag_payload.dart';
import 'package:projeto_integrado_mobile/src/shared/widgets/pin_badge.dart';

import 'notes_card_widgets.dart';
import 'notes_visuals.dart';

enum _FolderDateType { lastModified, lastAccessed, createdAt }

class FolderListCard extends StatefulWidget {
  final Folder folder;
  final ContentStats folderStats;
  final VoidCallback? onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  final VoidCallback? onTogglePinned;
  final VoidCallback? onToggleSelection;
  final bool selectionMode;
  final bool isSelected;
  final bool isPinned;
  final bool showActions;
  final List<String> summaryTags;
  final int noteCount;
  final ValueChanged<int>? onAcceptNote;
  final ValueChanged<int>? onAcceptFolder;
  final FolderPreviewData? preview;

  const FolderListCard({
    super.key,
    required this.folder,
    required this.folderStats,
    this.onTap,
    this.onRename,
    this.onDelete,
    this.onTogglePinned,
    this.onToggleSelection,
    this.selectionMode = false,
    this.isSelected = false,
    this.isPinned = false,
    this.showActions = true,
    this.summaryTags = const <String>[],
    this.noteCount = 0,
    this.onAcceptNote,
    this.onAcceptFolder,
    this.preview,
  });

  @override
  State<FolderListCard> createState() => _FolderListCardState();
}

class _FolderListCardState extends State<FolderListCard> {
  _FolderDateType _activeDateType = _FolderDateType.lastModified;

  void _cycleDateType() {
    setState(() {
      _activeDateType = switch (_activeDateType) {
        _FolderDateType.lastModified => _FolderDateType.lastAccessed,
        _FolderDateType.lastAccessed => _FolderDateType.createdAt,
        _FolderDateType.createdAt => _FolderDateType.lastModified,
      };
    });
  }

  NotesDateEntry get _currentDateEntry {
    return switch (_activeDateType) {
      _FolderDateType.lastModified => NotesDateEntry(
        label: 'Modificação',
        value: widget.folder.lastModified,
      ),
      _FolderDateType.lastAccessed => NotesDateEntry(
        label: 'Acesso',
        value: widget.folder.lastAccessed,
      ),
      _FolderDateType.createdAt => NotesDateEntry(
        label: 'Criação',
        value: widget.folder.createdAt,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DragTarget<NotesDragPayload>(
        onWillAcceptWithDetails: (details) {
          final data = details.data;
          if (data.type == NotesDragType.note) {
            return widget.onAcceptNote != null;
          }
          if (data.type == NotesDragType.folder) {
            return widget.onAcceptFolder != null && data.id != widget.folder.id;
          }
          return false;
        },
        onAcceptWithDetails: (details) {
          final data = details.data;
          if (data.type == NotesDragType.note) {
            widget.onAcceptNote?.call(data.id);
            return;
          }
          if (data.type == NotesDragType.folder) {
            widget.onAcceptFolder?.call(data.id);
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          final chips = _buildTagChips(
            widget.folder.metadata,
          ).take(6).toList(growable: false);
          final metrics = widget.folderStats.isEmpty
              ? const <Widget>[]
              : _buildMetricChips(widget.folderStats);

          Widget buildCard(int resolvedCount) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isHovering
                        ? [
                            BoxShadow(
                              color: widget.folder.color.withValues(
                                alpha: 0.24,
                              ),
                              blurRadius: 16,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: NotesGlassCard(
                    accentColor: widget.folder.color,
                    elevated: true,
                    radius: 18,
                    padding: const EdgeInsets.fromLTRB(13, 15, 13, 11),
                    boxShadow: [
                      if (widget.isSelected)
                        BoxShadow(
                          color: widget.folder.color.withValues(alpha: 0.24),
                          blurRadius: 0,
                          spreadRadius: 1.2,
                          offset: Offset.zero,
                        ),
                      BoxShadow(
                        color: widget.folder.color.withValues(alpha: 0.2),
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
                                    Colors.white.withValues(alpha: 0.22),
                                    widget.folder.color.withValues(alpha: 0.24),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: widget.folder.color.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                              child: Icon(
                                Icons.folder_outlined,
                                color: widget.folder.color,
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: GestureDetector(
                                onTap: widget.selectionMode
                                    ? widget.onToggleSelection
                                    : widget.onTap,
                                onLongPress: widget.onToggleSelection,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.folder.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16.1,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (widget.preview != null &&
                                        !widget.preview!.isEmpty) ...[
                                      const SizedBox(height: 5),
                                      _FolderPreviewLine(
                                        preview: widget.preview!,
                                      ),
                                    ],
                                  ],
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
                              NotesActionIconButton(
                                icon: Icons.drive_file_rename_outline_rounded,
                                tooltip: 'Renomear pasta',
                                onTap: widget.onRename,
                              )
                            else
                              const Icon(
                                Icons.drag_indicator_rounded,
                                color: kNotesMutedText,
                                size: 20,
                              ),
                            if (!widget.selectionMode && widget.showActions)
                              const SizedBox(width: 6),
                            if (!widget.selectionMode && widget.showActions)
                              NotesActionIconButton(
                                icon: Icons.delete_outline_rounded,
                                tooltip: widget.folder.isProjectRoot
                                    ? 'Apagar conteúdo da pasta'
                                    : 'Excluir pasta',
                                onTap: widget.onDelete,
                                destructive: true,
                              ),
                          ],
                        ),
                        if (metrics.isNotEmpty) ...[
                          const SizedBox(height: 7),
                          Wrap(spacing: 5, runSpacing: 5, children: metrics),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _CountChip(count: resolvedCount),
                            const SizedBox(width: 8),
                            Expanded(
                              child: NotesDateCycleField(
                                accentColor: widget.folder.color,
                                dateEntry: _currentDateEntry,
                                onTapClock: _cycleDateType,
                              ),
                            ),
                          ],
                        ),
                        if (chips.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(spacing: 6, runSpacing: 6, children: chips),
                        ],
                      ],
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
            );
          }

          return buildCard(widget.noteCount);
        },
      ),
    );
  }

  List<Widget> _buildTagChips(NoteMetadata metadata) {
    final chips = <Widget>[];

    for (final group in metadata.tagGroups) {
      for (final tag in group.tags) {
        chips.add(
          NotesSummaryChip(
            label: '${group.title}: ${tag.label}',
            icon: Icons.label_outline_rounded,
            tint: group.color,
          ),
        );
        if (chips.length >= 6) {
          return chips;
        }
      }
    }

    return chips;
  }

  List<Widget> _buildMetricChips(ContentStats stats) {
    return <Widget>[
      NotesMetricChip(
        icon: Icons.short_text_rounded,
        label: 'Palavras',
        value: stats.words,
        accentColor: widget.folder.color,
      ),
      NotesMetricChip(
        icon: Icons.onetwothree_rounded,
        label: 'Caracteres',
        value: stats.characters,
        accentColor: widget.folder.color,
      ),
      NotesMetricChip(
        icon: Icons.alternate_email_rounded,
        label: 'Menções',
        value: stats.mentions,
        accentColor: widget.folder.color,
      ),
    ];
  }
}

class _CountChip extends StatelessWidget {
  final int count;

  const _CountChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Text(
        '$count nota(s)',
        style: const TextStyle(
          color: kNotesMutedText,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
    );
  }
}

class _FolderPreviewLine extends StatelessWidget {
  final FolderPreviewData preview;

  const _FolderPreviewLine({required this.preview});

  @override
  Widget build(BuildContext context) {
    final previewColor = kNotesMutedText.withValues(alpha: 0.9);
    final items = preview.items
        .where((item) => item.title.trim().isNotEmpty)
        .take(3)
        .toList(growable: false);
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    const titleStyle = TextStyle(
      fontSize: 11.1,
      height: 1.0,
      fontWeight: FontWeight.w500,
    );
    const gapWidth = 4.0;
    const separatorWidth = 10.0;
    const iconWidth = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        var estimatedWidth = 0.0;
        for (var index = 0; index < items.length; index += 1) {
          final item = items[index];
          final painter = TextPainter(
            text: TextSpan(text: item.title.trim(), style: titleStyle),
            maxLines: 1,
            textDirection: Directionality.of(context),
          )..layout();
          estimatedWidth += painter.width + iconWidth + gapWidth;
          if (index < items.length - 1) {
            estimatedWidth += separatorWidth;
          }
        }

        final shouldShowEllipsis = estimatedWidth > constraints.maxWidth;
        final textStyle = titleStyle.copyWith(color: previewColor);

        Widget buildItem(FolderPreviewItem item) {
          final title = item.title.trim();
          final icon = item.kind == FolderPreviewItemKind.folder
              ? Icons.folder_outlined
              : Icons.description_outlined;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: previewColor),
              const SizedBox(width: gapWidth),
              Text(
                title,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                style: textStyle,
              ),
            ],
          );
        }

        Widget buildSeparator() {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '·',
              style: TextStyle(
                color: previewColor.withValues(alpha: 0.64),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          );
        }

        return SizedBox(
          height: 18,
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
                      stops: const [0.0, 0.84, 1.0],
                    ).createShader(bounds);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var index = 0; index < items.length; index += 1) ...[
                        if (index > 0) buildSeparator(),
                        Flexible(child: buildItem(items[index])),
                      ],
                    ],
                  ),
                ),
              ),
              if (shouldShowEllipsis) ...[
                const SizedBox(width: 4),
                Text(
                  '...',
                  style: TextStyle(
                    color: previewColor.withValues(alpha: 0.72),
                    fontSize: 11.1,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
