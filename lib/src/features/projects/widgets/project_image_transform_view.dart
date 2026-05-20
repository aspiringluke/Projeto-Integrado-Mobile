import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ProjectImageViewportMetrics {
  final double renderedWidth;
  final double renderedHeight;
  final double maxTranslationX;
  final double maxTranslationY;

  const ProjectImageViewportMetrics({
    required this.renderedWidth,
    required this.renderedHeight,
    required this.maxTranslationX,
    required this.maxTranslationY,
  });
}

ProjectImageViewportMetrics computeProjectImageViewportMetrics({
  required Size viewportSize,
  required double imageWidth,
  required double imageHeight,
  required double scale,
}) {
  if (viewportSize.width <= 0 ||
      viewportSize.height <= 0 ||
      imageWidth <= 0 ||
      imageHeight <= 0) {
    return const ProjectImageViewportMetrics(
      renderedWidth: 0,
      renderedHeight: 0,
      maxTranslationX: 0,
      maxTranslationY: 0,
    );
  }

  final coverScale = math.max(
    viewportSize.width / imageWidth,
    viewportSize.height / imageHeight,
  );
  final resolvedScale = math.max(scale, 1);
  final renderedWidth = imageWidth * coverScale * resolvedScale;
  final renderedHeight = imageHeight * coverScale * resolvedScale;

  return ProjectImageViewportMetrics(
    renderedWidth: renderedWidth,
    renderedHeight: renderedHeight,
    maxTranslationX: math.max(0, (renderedWidth - viewportSize.width) / 2),
    maxTranslationY: math.max(0, (renderedHeight - viewportSize.height) / 2),
  );
}

double clampProjectImageOffset(
  double offset, {
  required double maxTranslation,
}) {
  if (maxTranslation <= 0) {
    return 0;
  }

  return offset.clamp(-1.0, 1.0).toDouble();
}

Offset resolveProjectImageDragOffset({
  required double currentOffsetX,
  required double currentOffsetY,
  required Offset dragDelta,
  required ProjectImageViewportMetrics metrics,
}) {
  final nextOffsetX = metrics.maxTranslationX <= 0
      ? 0.0
      : currentOffsetX + (dragDelta.dx / metrics.maxTranslationX);
  final nextOffsetY = metrics.maxTranslationY <= 0
      ? 0.0
      : currentOffsetY + (dragDelta.dy / metrics.maxTranslationY);

  return Offset(
    clampProjectImageOffset(
      nextOffsetX,
      maxTranslation: metrics.maxTranslationX,
    ),
    clampProjectImageOffset(
      nextOffsetY,
      maxTranslation: metrics.maxTranslationY,
    ),
  );
}

class ProjectImageTransformView extends StatelessWidget {
  final Uint8List imageBytes;
  final double imageWidth;
  final double imageHeight;
  final double scale;
  final double offsetX;
  final double offsetY;
  final bool clipImage;
  final double? viewportWidth;
  final double? viewportHeight;

  const ProjectImageTransformView({
    super.key,
    required this.imageBytes,
    required this.imageWidth,
    required this.imageHeight,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
    this.clipImage = true,
    this.viewportWidth,
    this.viewportHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final resolvedViewport = Size(
          viewportWidth ?? size.width,
          viewportHeight ?? size.height,
        );
        if (imageWidth <= 0 || imageHeight <= 0) {
          final fallbackImage = Transform.translate(
            offset: Offset(
              offsetX * resolvedViewport.width * 0.35,
              offsetY * resolvedViewport.height * 0.35,
            ),
            child: Transform.scale(
              scale: math.max(scale, 1),
              child: SizedBox(
                width: resolvedViewport.width,
                height: resolvedViewport.height,
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          );

          if (clipImage) {
            return ClipRect(child: fallbackImage);
          }

          return OverflowBox(
            minWidth: 0,
            minHeight: 0,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            alignment: Alignment.center,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: fallbackImage,
            ),
          );
        }

        final metrics = computeProjectImageViewportMetrics(
          viewportSize: resolvedViewport,
          imageWidth: imageWidth,
          imageHeight: imageHeight,
          scale: scale,
        );

        final image = Transform.translate(
          offset: Offset(
            clampProjectImageOffset(
                  offsetX,
                  maxTranslation: metrics.maxTranslationX,
                ) *
                metrics.maxTranslationX,
            clampProjectImageOffset(
                  offsetY,
                  maxTranslation: metrics.maxTranslationY,
                ) *
                metrics.maxTranslationY,
          ),
          child: SizedBox(
            width: resolvedViewport.width,
            height: resolvedViewport.height,
            child: OverflowBox(
              minWidth: 0,
              minHeight: 0,
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              alignment: Alignment.center,
              child: SizedBox(
                width: metrics.renderedWidth,
                height: metrics.renderedHeight,
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        );

        if (clipImage) {
          return ClipRect(child: image);
        }

        return OverflowBox(
          minWidth: 0,
          minHeight: 0,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          alignment: Alignment.center,
          child: SizedBox(width: size.width, height: size.height, child: image),
        );
      },
    );
  }
}
