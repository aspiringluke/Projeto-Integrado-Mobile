import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/notes_surface_card.dart';

class FolderListCard extends StatelessWidget {
  final Folder folder;
  final VoidCallback? onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  final ValueChanged<int>? onAcceptNote;

  const FolderListCard({
    super.key,
    required this.folder,
    this.onTap,
    this.onRename,
    this.onDelete,
    this.onAcceptNote,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DragTarget<int>(
        onWillAcceptWithDetails: (_) => onAcceptNote != null,
        onAcceptWithDetails: (details) => onAcceptNote?.call(details.data),
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
                        color: folder.color.withValues(alpha: 0.35),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: NotesSurfaceCard(
              height: 68,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: folder.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
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
                        style: const TextStyle(
                          color: Color(0xFF342F33),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'rename') onRename?.call();
                      if (value == 'delete') onDelete?.call();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'rename',
                        child: Text('Renomear'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Excluir'),
                      ),
                    ],
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Color(0xFF8D7E88),
                    ),
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
