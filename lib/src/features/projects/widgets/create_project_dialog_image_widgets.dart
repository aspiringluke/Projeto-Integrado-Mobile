import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/create_project_dialog_image_viewport_presets.dart';
import 'project_image_transform_view.dart';

class CreateProjectDialogCoverImagePickerCard extends StatelessWidget {
  final String title;
  final String description;
  final Uint8List? imageBytes;
  final double? imageWidth;
  final double? imageHeight;
  final String? imageName;
  final double scale;
  final double offsetX;
  final double offsetY;
  final Gradient backgroundGradient;
  final CreateProjectDialogImageEditorViewportPreset viewportPreset;
  final String emptyStateText;
  final String? footerNote;
  final ValueChanged<double> onScaleChanged;
  final void Function(double offsetX, double offsetY) onOffsetChanged;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  const CreateProjectDialogCoverImagePickerCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageBytes,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageName,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
    required this.backgroundGradient,
    required this.viewportPreset,
    required this.emptyStateText,
    this.footerNote,
    required this.onScaleChanged,
    required this.onOffsetChanged,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 0),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF3A3339),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          CreateProjectDialogFieldDescription(text: description),
          const SizedBox(height: 8),
          CreateProjectDialogImageEditor(
            imageBytes: imageBytes,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            scale: scale,
            offsetX: offsetX,
            offsetY: offsetY,
            backgroundGradient: backgroundGradient,
            viewportPreset: viewportPreset,
            emptyStateText: emptyStateText,
            onOffsetChanged: onOffsetChanged,
          ),
          if (imageName != null) ...[
            const SizedBox(height: 8),
            Text(
              imageName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF6A6167),
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (imageBytes != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Zoom',
                  style: TextStyle(
                    color: Color(0xFF514752),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 8,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Slider(
                      value: scale,
                      min: 1,
                      max: 3,
                      onChanged: onScaleChanged,
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${scale.toStringAsFixed(1)}x',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF7A7079),
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final pickButton = OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    imageBytes == null ? 'Escolher imagem' : 'Trocar imagem',
                    maxLines: 1,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF514752),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.82)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              );
              final removeButton = onRemove == null
                  ? null
                  : OutlinedButton(
                      onPressed: onRemove,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8B5668),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Remover'),
                      ),
                    );

              if (removeButton != null && constraints.maxWidth < 310) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    pickButton,
                    const SizedBox(height: 8),
                    removeButton,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: pickButton),
                  if (removeButton != null) ...[
                    const SizedBox(width: 8),
                    Flexible(child: removeButton),
                  ],
                ],
              );
            },
          ),
          if (footerNote != null) ...[
            const SizedBox(height: 6),
            Text(
              footerNote!,
              style: const TextStyle(color: Color(0xFF6A6167), fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class CreateProjectDialogImageEditor extends StatelessWidget {
  final Uint8List? imageBytes;
  final double? imageWidth;
  final double? imageHeight;
  final double scale;
  final double offsetX;
  final double offsetY;
  final Gradient backgroundGradient;
  final CreateProjectDialogImageEditorViewportPreset viewportPreset;
  final String emptyStateText;
  final void Function(double offsetX, double offsetY) onOffsetChanged;

  const CreateProjectDialogImageEditor({
    super.key,
    required this.imageBytes,
    required this.imageWidth,
    required this.imageHeight,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
    required this.backgroundGradient,
    required this.viewportPreset,
    required this.emptyStateText,
    required this.onOffsetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cropTop =
            (viewportPreset.canvasHeight - viewportPreset.cropHeight) / 2;
        final cropWidth =
            constraints.maxWidth - (viewportPreset.cropHorizontalInset * 2);
        final metrics =
            imageBytes != null && imageWidth != null && imageHeight != null
            ? computeProjectImageViewportMetrics(
                viewportSize: Size(cropWidth, viewportPreset.cropHeight),
                imageWidth: imageWidth!,
                imageHeight: imageHeight!,
                scale: scale,
              )
            : null;

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: viewportPreset.canvasHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: backgroundGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
            ),
            child: imageBytes == null
                ? Center(
                    child: Text(
                      emptyStateText,
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.55),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : GestureDetector(
                    onPanUpdate: (details) {
                      final resolvedMetrics = metrics;
                      if (resolvedMetrics == null) return;
                      final offset = resolveProjectImageDragOffset(
                        currentOffsetX: offsetX,
                        currentOffsetY: offsetY,
                        dragDelta: details.delta,
                        metrics: resolvedMetrics,
                      );
                      onOffsetChanged(offset.dx, offset.dy);
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ProjectImageTransformView(
                          imageBytes: imageBytes!,
                          imageWidth: imageWidth ?? cropWidth,
                          imageHeight: imageHeight ?? viewportPreset.cropHeight,
                          scale: scale,
                          offsetX: offsetX,
                          offsetY: offsetY,
                          clipImage: false,
                          viewportWidth: cropWidth,
                          viewportHeight: viewportPreset.cropHeight,
                        ),
                        IgnorePointer(
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                right: 0,
                                top: 0,
                                height: cropTop,
                                child: const CreateProjectDialogEditorShade(),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                height: cropTop,
                                child: const CreateProjectDialogEditorShade(),
                              ),
                              Positioned(
                                left: viewportPreset.cropHorizontalInset,
                                right: viewportPreset.cropHorizontalInset,
                                top: cropTop,
                                height: viewportPreset.cropHeight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.92,
                                      ),
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: cropTop,
                                bottom: cropTop,
                                width: viewportPreset.cropHorizontalInset,
                                child: const CreateProjectDialogEditorShade(),
                              ),
                              Positioned(
                                right: 0,
                                top: cropTop,
                                bottom: cropTop,
                                width: viewportPreset.cropHorizontalInset,
                                child: const CreateProjectDialogEditorShade(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class CreateProjectDialogEditorShade extends StatelessWidget {
  const CreateProjectDialogEditorShade({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white.withValues(alpha: 0.34));
  }
}

class CreateProjectDialogFieldDescription extends StatelessWidget {
  final String text;

  const CreateProjectDialogFieldDescription({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 2,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFBFB8BD).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF6A6167),
              fontSize: 11.25,
              height: 1.3,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
