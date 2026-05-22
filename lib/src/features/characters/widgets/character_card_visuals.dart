import 'package:flutter/material.dart';

import '../../projects/models/project_image_data.dart';
import '../../projects/widgets/project_image_transform_view.dart';
import '../../../shared/widgets/pin_badge.dart';

const double characterProfileTileWidth = 108;
const double characterProfileTileHeight = 76;

class CharacterAvatarTile extends StatelessWidget {
  final Color accent;
  final Color avatarColor;
  final ProjectImageData profileImage;
  final bool isExpanded;
  final VoidCallback? onTap;
  final bool showExpandHint;

  const CharacterAvatarTile({
    super.key,
    required this.accent,
    required this.avatarColor,
    required this.profileImage,
    required this.isExpanded,
    this.onTap,
    this.showExpandHint = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          bottomLeft: isExpanded ? Radius.zero : const Radius.circular(16),
          topRight: const Radius.circular(18),
          bottomRight: const Radius.circular(18),
        ),
        child: SizedBox(
          width: characterProfileTileWidth,
          height: characterProfileTileHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    bottomLeft: isExpanded
                        ? Radius.zero
                        : const Radius.circular(16),
                    topRight: const Radius.circular(18),
                    bottomRight: const Radius.circular(18),
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
                        if (profileImage.bytes != null)
                          Positioned.fill(
                            child: ProjectImageTransformView(
                              imageBytes: profileImage.bytes!,
                              imageWidth:
                                  profileImage.width ??
                                  characterProfileTileWidth,
                              imageHeight:
                                  profileImage.height ??
                                  characterProfileTileHeight,
                              scale: profileImage.scale,
                              offsetX: profileImage.offsetX,
                              offsetY: profileImage.offsetY,
                            ),
                          ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.24),
                                  Colors.transparent,
                                  Colors.black.withValues(
                                    alpha: profileImage.bytes != null
                                        ? 0.16
                                        : 0.08,
                                  ),
                                ],
                                stops: const [0.0, 0.38, 1.0],
                              ),
                            ),
                          ),
                        ),
                        if (profileImage.bytes == null) ...[
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 72,
                              height: 26,
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.26),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 38,
                              color: const Color(0xFF171419),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (profileImage.bytes != null && showExpandHint)
                Positioned(
                  right: 8,
                  top: 8,
                  child: IgnorePointer(
                    child: _CharacterAvatarExpandHint(accent: accent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterAvatarExpandHint extends StatelessWidget {
  final Color accent;

  const _CharacterAvatarExpandHint({required this.accent});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.72),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: 18,
        height: 18,
        child: Center(
          child: Icon(
            Icons.open_in_full_rounded,
            size: 10,
            color: Colors.white.withValues(alpha: 0.96),
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
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
