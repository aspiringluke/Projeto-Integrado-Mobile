import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'project_image_transform_view.dart';

class ProjectCoverFill extends StatelessWidget {
  final Color color;
  final Uint8List? imageBytes;
  final double? imageWidth;
  final double? imageHeight;
  final double imageScale;
  final double imageOffsetX;
  final double imageOffsetY;
  final BorderRadius borderRadius;

  const ProjectCoverFill({
    super.key,
    required this.color,
    this.imageBytes,
    this.imageWidth,
    this.imageHeight,
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
                  imageWidth: imageWidth ?? 0,
                  imageHeight: imageHeight ?? 0,
                  scale: imageScale,
                  offsetX: imageOffsetX,
                  offsetY: imageOffsetY,
                ),
              ),
            ),
    );
  }
}

class ProjectAccentFill extends StatelessWidget {
  final Color accentColor;
  final Uint8List? imageBytes;
  final double? imageWidth;
  final double? imageHeight;
  final double imageScale;
  final double imageOffsetX;
  final double imageOffsetY;

  const ProjectAccentFill({
    super.key,
    required this.accentColor,
    this.imageBytes,
    this.imageWidth,
    this.imageHeight,
    this.imageScale = 1,
    this.imageOffsetX = 0,
    this.imageOffsetY = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(
                  accentColor.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.52),
                ),
                Colors.white.withValues(alpha: 0.34),
                Color.alphaBlend(
                  accentColor.withValues(alpha: 0.16),
                  const Color(0xFFFFF8FC).withValues(alpha: 0.42),
                ),
              ],
            ),
          ),
        ),
        if (imageBytes != null)
          Positioned.fill(
            child: Opacity(
              opacity: 0.44,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 1.6, sigmaY: 1.6),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Color.alphaBlend(
                      accentColor.withValues(alpha: 0.24),
                      Colors.white.withValues(alpha: 0.08),
                    ),
                    BlendMode.modulate,
                  ),
                  child: _ProjectCoverImageViewport(
                    imageBytes: imageBytes!,
                    imageWidth: imageWidth ?? 0,
                    imageHeight: imageHeight ?? 0,
                    scale: imageScale,
                    offsetX: imageOffsetX,
                    offsetY: imageOffsetY,
                  ),
                ),
              ),
            ),
          ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(
                    accentColor.withValues(alpha: 0.18),
                    Colors.white.withValues(alpha: 0.56),
                  ),
                  Colors.white.withValues(alpha: 0.16),
                  Color.alphaBlend(
                    accentColor.withValues(alpha: 0.24),
                    const Color(0xFFFFF7FB).withValues(alpha: 0.34),
                  ),
                ],
                stops: const [0.0, 0.52, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectCoverImageViewport extends StatelessWidget {
  final Uint8List imageBytes;
  final double imageWidth;
  final double imageHeight;
  final double scale;
  final double offsetX;
  final double offsetY;

  const _ProjectCoverImageViewport({
    required this.imageBytes,
    required this.imageWidth,
    required this.imageHeight,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  Widget build(BuildContext context) {
    return ProjectImageTransformView(
      imageBytes: imageBytes,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      scale: scale,
      offsetX: offsetX,
      offsetY: offsetY,
    );
  }
}
