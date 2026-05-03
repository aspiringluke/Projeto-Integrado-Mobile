import 'package:flutter/material.dart';

import '../../../shared/widgets/pin_badge.dart';

class CharacterAvatarTile extends StatelessWidget {
  final Color accent;
  final Color avatarColor;
  final IconData icon;

  const CharacterAvatarTile({
    super.key,
    required this.accent,
    required this.avatarColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 60,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.76),
                      avatarColor.withValues(alpha: 0.94),
                      Colors.white.withValues(alpha: 0.2),
                    ],
                    stops: const [0.0, 0.58, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.24),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.08),
                            ],
                            stops: const [0.0, 0.38, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 58,
                        height: 22,
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.26),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        icon,
                        size: 33,
                        color: const Color(0xFF171419),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterPinBadge extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const CharacterPinBadge({
    super.key,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PinBadge(isActive: isActive, onTap: onTap);
  }
}
