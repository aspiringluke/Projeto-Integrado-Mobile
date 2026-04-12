import 'package:flutter/material.dart';

class ProjectCoverFill extends StatelessWidget {
  final Color color;
  final BorderRadius borderRadius;

  const ProjectCoverFill({
    super.key,
    required this.color,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            color,
            Color.alphaBlend(
              color.withValues(alpha: 0.32),
              const Color(0xFFF5EDF2),
            ),
            Colors.white.withValues(alpha: 0.98),
          ],
          stops: const [0.0, 0.62, 1.0],
        ),
      ),
    );
  }
}
