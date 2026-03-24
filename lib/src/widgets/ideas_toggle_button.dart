import 'package:flutter/material.dart';

class IdeasToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const IdeasToggleButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 48,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFD9A9C5), Color(0xFFEFC3DB)],
                  )
                : null,
            color: isActive ? null : Colors.white.withValues(alpha: 0.55),
            borderRadius: borderRadius,
            border: Border.all(
              color: isActive
                  ? const Color(0xFFD37AB2).withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isActive ? 0.12 : 0.05),
                blurRadius: isActive ? 12 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF4A4348),
                fontSize: 20,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
