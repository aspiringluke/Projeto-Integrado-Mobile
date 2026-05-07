import 'package:flutter/material.dart';

import 'notes_visuals.dart';

class NotesSurfaceCard extends StatelessWidget {
  final double height;
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;

  const NotesSurfaceCard({
    super.key,
    required this.height,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final accent = borderColor ?? backgroundColor ?? kNotesPink;

    return SizedBox(
      height: height,
      child: NotesGlassCard(
        accentColor: accent,
        elevated: true,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        radius: 16,
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: accent.withValues(alpha: 0.16),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
        child: child,
      ),
    );
  }
}
