import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/notes_drag_payload.dart';
import 'notes_visuals.dart';

class FolderListCard extends StatelessWidget {
  final Folder folder;
  final VoidCallback? onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  final ValueChanged<int>? onAcceptNote;
  final ValueChanged<int>? onAcceptFolder;

  const FolderListCard({
    super.key,
    required this.folder,
    this.onTap,
    this.onRename,
    this.onDelete,
    this.onAcceptNote,
    this.onAcceptFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DragTarget<NotesDragPayload>(
        onWillAcceptWithDetails: (details) {
          final data = details.data;
          if (data.type == NotesDragType.note) return onAcceptNote != null;
          if (data.type == NotesDragType.folder) {
            return onAcceptFolder != null && data.id != folder.id;
          }
          return false;
        },
        onAcceptWithDetails: (details) {
          final data = details.data;
          if (data.type == NotesDragType.note) {
            onAcceptNote?.call(data.id);
            return;
          }
          if (data.type == NotesDragType.folder) {
            onAcceptFolder?.call(data.id);
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: isHovering
                  ? [
                      BoxShadow(
                        color: folder.color.withValues(alpha: 0.24),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: NotesGlassCard(
              height: 72,
              accentColor: folder.color,
              elevated: true,
              radius: 18,
              boxShadow: [
                BoxShadow(
                  color: folder.color.withValues(alpha: 0.2),
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.22),
                          folder.color.withValues(alpha: 0.24),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: folder.color.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Icon(
                      Icons.folder_outlined,
                      color: folder.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: onTap,
                      child: Text(
                        folder.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _FolderActionButton(
                    icon: Icons.drive_file_rename_outline_rounded,
                    tooltip: 'Renomear pasta',
                    onTap: onRename,
                  ),
                  const SizedBox(width: 6),
                  _FolderActionButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Excluir pasta',
                    onTap: onDelete,
                    destructive: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
