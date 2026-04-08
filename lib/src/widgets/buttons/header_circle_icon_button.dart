import 'package:flutter/material.dart';

class HeaderCircleIconButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback onPressed;

  const HeaderCircleIconButton({
    super.key,
    required this.icon,
    required this.iconSize,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 31,
      height: 31,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.42), width: 1),
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: IconButton(
        iconSize: iconSize,
        padding: EdgeInsets.zero,
        splashRadius: 17,
        icon: Icon(
          icon,
          color: const Color(0xFFF6EDF3),
          size: iconSize,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
