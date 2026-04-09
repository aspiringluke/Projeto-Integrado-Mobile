import 'package:flutter/material.dart';

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFF4EEF3).withValues(alpha: isActive ? 0.9 : 0.78),
            gradient: isActive
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFF6D3E5).withValues(alpha: 0.96),
                      const Color(0xFFF0BEDB).withValues(alpha: 0.9),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.72),
                      const Color(0xFFF0E7EE).withValues(alpha: 0.82),
                    ],
                  ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: isActive ? 0.84 : 0.7),
              width: 0.65,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? const Color(0xFFDF6EB8).withValues(alpha: 0.26)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: isActive ? 10 : 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: AnimatedScale(
              scale: isActive ? 1.06 : 1,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              child: Transform.rotate(
                angle: -0.32,
                child: Icon(
                  isActive ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  size: isActive ? 16 : 15,
                  color: Color(0xFF8A828C).withValues(alpha: isActive ? 0.98 : 0.56),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
