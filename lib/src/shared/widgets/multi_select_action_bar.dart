import 'dart:ui';

import 'package:flutter/material.dart';

class MultiSelectAction {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool destructive;

  const MultiSelectAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.destructive = false,
  });
}

class MultiSelectActionBar extends StatelessWidget {
  final String label;
  final Color accentColor;
  final VoidCallback onClear;
  final List<MultiSelectAction> actions;

  const MultiSelectActionBar({
    super.key,
    required this.label,
    required this.onClear,
    required this.actions,
    this.accentColor = const Color(0xFFDF6EB8),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.72),
                accentColor.withValues(alpha: 0.07),
                Colors.white.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.1),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF342F33),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              MultiSelectIconButton(
                icon: Icons.close_rounded,
                tooltip: 'Cancelar seleção',
                onTap: onClear,
                accentColor: accentColor,
              ),
              for (final action in actions) ...[
                const SizedBox(width: 8),
                MultiSelectIconButton(
                  icon: action.icon,
                  tooltip: action.tooltip,
                  onTap: action.onTap,
                  accentColor: accentColor,
                  destructive: action.destructive,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MultiSelectIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color accentColor;
  final bool destructive;

  const MultiSelectIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.accentColor = const Color(0xFFDF6EB8),
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final tint = destructive ? const Color(0xFFE05E8A) : const Color(0xFF544959);

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
              color: Colors.white.withValues(alpha: 0.36),
              border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
              boxShadow: [
                BoxShadow(
                  color: (destructive ? tint : accentColor).withValues(
                    alpha: 0.08,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 18, color: tint),
          ),
        ),
      ),
    );
  }
}

