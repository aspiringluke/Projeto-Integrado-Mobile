import 'package:flutter/material.dart';

import 'notes_visuals.dart';

class FolderColorPicker extends StatelessWidget {
  final Color selected;
  final ValueChanged<Color> onSelect;

  const FolderColorPicker({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const List<Color> colors = [
    Color(0xFF8C5B79),
    Color(0xFFDF6EB8),
    Color(0xFF6D7C9B),
    Color(0xFF668F80),
    Color(0xFFA2785C),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors
          .map(
            (color) => AnimatedScale(
              duration: const Duration(milliseconds: 150),
              scale: selected == color ? 1.08 : 1,
              child: GestureDetector(
                onTap: () => onSelect(color),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white.withValues(alpha: 0.34), color],
                    ),
                    border: Border.all(
                      color: selected == color
                          ? kNotesPink
                          : Colors.white.withValues(alpha: 0.92),
                      width: selected == color ? 2.2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(
                          alpha: selected == color ? 0.24 : 0.12,
                        ),
                        blurRadius: selected == color ? 14 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: selected == color
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
