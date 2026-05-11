import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/models/content_stats.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/notes_drag_payload.dart';
import 'package:projeto_integrado_mobile/src/shared/widgets/buttons/glass_circle_button.dart';
import 'package:projeto_integrado_mobile/src/shared/widgets/pin_badge.dart';

import 'notes_visuals.dart';

enum _FolderDateType { lastModified, lastAccessed, createdAt }

class _FolderDateEntry {
  final String label;
  final DateTime value;

  const _FolderDateEntry({required this.label, required this.value});
}

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
  final List<String> summaryTags;
  final int noteCount;
  final Future<int> Function(int folderId)? noteCountLoader;
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
    this.summaryTags = const <String>[],
    this.noteCount = 0,
    this.noteCountLoader,
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

  _FolderDateEntry get _currentDateEntry {
    return switch (_activeDateType) {
      _FolderDateType.lastModified => _FolderDateEntry(
        label: 'Modificação',
        value: widget.folder.lastModified,
      ),
      _FolderDateType.lastAccessed => _FolderDateEntry(
        label: 'Acesso',
        value: widget.folder.lastAccessed,
      ),
      _FolderDateType.createdAt => _FolderDateEntry(
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
                              _FolderActionButton(
                                icon: widget.isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                tooltip: widget.isSelected
                                    ? 'Desmarcar'
                                    : 'Selecionar',
                                onTap: widget.onToggleSelection,
                              )
                            else
                              _FolderActionButton(
                                icon: Icons.drive_file_rename_outline_rounded,
                                tooltip: 'Renomear pasta',
                                onTap: widget.onRename,
                              ),
                            const SizedBox(width: 6),
                            if (!widget.selectionMode)
                              _FolderActionButton(
                                icon: Icons.delete_outline_rounded,
                                tooltip: 'Excluir pasta',
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
                              child: _DateCycleField(
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

          if (widget.noteCountLoader == null || widget.folder.id == null) {
            return buildCard(widget.noteCount);
          }

          return FutureBuilder<int>(
            future: widget.noteCountLoader!(widget.folder.id!),
            builder: (context, snapshot) {
              final resolvedCount = snapshot.data ?? widget.noteCount;
              return buildCard(resolvedCount);
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildTagChips(NoteMetadata metadata) {
    final chips = <Widget>[];

    for (final group in metadata.tagGroups) {
      for (final tag in group.tags) {
        chips.add(
          _SummaryChip(
            label: '${group.title}: ${tag.label}',
            icon: Icons.label_outline_rounded,
            tint: group.color,
          ),
        );
      }
    }

    return chips;
  }

  List<Widget> _buildMetricChips(ContentStats stats) {
    return <Widget>[
      _MetricChip(
        icon: Icons.short_text_rounded,
        label: 'Palavras',
        value: stats.words,
        accentColor: widget.folder.color,
      ),
      _MetricChip(
        icon: Icons.onetwothree_rounded,
        label: 'Caracteres',
        value: stats.characters,
        accentColor: widget.folder.color,
      ),
      _MetricChip(
        icon: Icons.alternate_email_rounded,
        label: 'Menções',
        value: stats.mentions,
        accentColor: widget.folder.color,
      ),
    ];
  }
}

class _DateCycleField extends StatelessWidget {
  final Color accentColor;
  final _FolderDateEntry dateEntry;
  final VoidCallback onTapClock;

  const _DateCycleField({
    required this.accentColor,
    required this.dateEntry,
    required this.onTapClock,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            left: 8,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 40, right: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.66),
                    accentColor.withValues(alpha: 0.12),
                    const Color(0xFFF7F2F5).withValues(alpha: 0.88),
                  ],
                ),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.86),
                  width: 0.8,
                ),
              ),
              child: Text(
                '${dateEntry.label}: ${formatCompactDateTime(dateEntry.value)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF2C262C),
                  fontSize: 10.7,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: GlassCircleButton(
              diameter: 34,
              onTap: onTapClock,
              blurSigma: 8,
              fillColor: accentColor.withValues(alpha: 0.42),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.7),
                  accentColor.withValues(alpha: 0.36),
                  _lighten(accentColor, 0.18).withValues(alpha: 0.26),
                ],
              ),
              borderColor: Colors.white.withValues(alpha: 0.84),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.12),
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                ),
              ],
              child: const Icon(
                Icons.history_rounded,
                size: 19,
                color: Color(0xFF171419),
              ),
            ),
          ),
        ],
      ),
    );
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

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color accentColor;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$label: ${formatCompactCount(value)}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.54),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: accentColor.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(icon, size: 8.5, color: accentColor),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: kNotesMutedText,
                fontSize: 10.2,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              formatCompactCount(value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: kNotesText,
                fontSize: 11.6,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ],
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

class _FolderActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool destructive;

  const _FolderActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final tint = destructive ? const Color(0xFFE05E8A) : kNotesPlum;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tint.withValues(alpha: 0.1),
              border: Border.all(color: Colors.white.withValues(alpha: 0.84)),
            ),
            child: Icon(icon, size: 18, color: tint),
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color tint;

  const _SummaryChip({
    required this.label,
    required this.icon,
    this.tint = kNotesPlum,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: tint),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: tint,
              fontWeight: FontWeight.w600,
              fontSize: 11.2,
            ),
          ),
        ],
      ),
    );
  }
}

Color _lighten(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
}
