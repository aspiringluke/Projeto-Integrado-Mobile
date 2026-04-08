import 'package:flutter/material.dart';

class OutlinedTagPill extends StatelessWidget {
  final String label;
  final Color color;

  const OutlinedTagPill({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4.5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.92),
          width: 1.1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withValues(alpha: 0.96),
          fontSize: 11,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
      ),
    );
  }
}
