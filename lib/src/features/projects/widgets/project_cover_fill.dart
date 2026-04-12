import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'project_image_transform_view.dart';

class ProjectCoverFill extends StatelessWidget {
  final Color color;
  final Uint8List? imageBytes;
  final double imageScale;
  final double imageOffsetX;
  final double imageOffsetY;
  final BorderRadius borderRadius;

  const ProjectCoverFill({
    super.key,
    required this.color,
    this.imageBytes,
    this.imageScale = 1,
    this.imageOffsetX = 0,
    this.imageOffsetY = 0,
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
      child: imageBytes == null
          ? null
          : ClipRRect(
              borderRadius: borderRadius,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Color(0x66FFFFFF),
                      Colors.white,
                    ],
                    stops: [0.0, 0.48, 1.0],
                  ).createShader(bounds);
                },
                child: _ProjectCoverImageViewport(
                  imageBytes: imageBytes!,
                  scale: imageScale,
                  offsetX: imageOffsetX,
                  offsetY: imageOffsetY,
                ),
              ),
            ),
    );
  }
}

class _ProjectCoverImageViewport extends StatelessWidget {
  final Uint8List imageBytes;
  final double scale;
  final double offsetX;
  final double offsetY;

  const _ProjectCoverImageViewport({
    required this.imageBytes,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectImageTransformView(
      imageBytes: imageBytes,
      scale: scale,
      offsetX: offsetX,
      offsetY: offsetY,
    );
  }
}
