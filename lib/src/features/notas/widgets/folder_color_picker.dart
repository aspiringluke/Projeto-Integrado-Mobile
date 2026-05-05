import 'package:flutter/material.dart';

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
      spacing: 8,
      children: colors
          .map(
            (color) => GestureDetector(
              onTap: () => onSelect(color),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected == color ? Colors.black : Colors.white,
                    width: selected == color ? 2 : 1,
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
