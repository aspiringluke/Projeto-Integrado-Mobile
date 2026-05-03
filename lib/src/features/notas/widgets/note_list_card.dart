import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/widgets/notes_surface_card.dart';

class NoteListCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const NoteListCard({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NotesSurfaceCard(
        height: 68,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF8B7D8B).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.sticky_note_2_outlined,
                color: Color(0xFF5C4F5C),
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF342F33),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: onTap,
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF8D7E88),
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
