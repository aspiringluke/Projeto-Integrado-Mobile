import 'package:flutter/material.dart';

import 'notes_visuals.dart';

class NoteListCard extends StatelessWidget {
  final String title;
  final Color highlightColor;
  final VoidCallback? onTap;
  final VoidCallback? onMoveTo;
  final VoidCallback? onDelete;
  final bool showActions;

  const NoteListCard({
    super.key,
    required this.title,
    required this.highlightColor,
    this.onTap,
    this.onMoveTo,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: NotesGlassCard(
            height: 70,
            accentColor: highlightColor,
            elevated: true,
            radius: 18,
            boxShadow: [
              BoxShadow(
                color: highlightColor.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        highlightColor.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: highlightColor.withValues(alpha: 0.55),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: highlightColor.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.sticky_note_2_outlined,
                    color: highlightColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kNotesText,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (showActions)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionButton(
                        icon: Icons.drive_file_move_outline,
                        tooltip: 'Mover nota',
                        onTap: onMoveTo,
                      ),
                      const SizedBox(width: 6),
                      _ActionButton(
                        icon: Icons.delete_outline_rounded,
                        tooltip: 'Excluir nota',
                        onTap: onDelete,
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
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool destructive;

  const _ActionButton({
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
