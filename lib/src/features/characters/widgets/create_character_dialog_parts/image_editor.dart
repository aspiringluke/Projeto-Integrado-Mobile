part of '../create_character_dialog.dart';

class _CharacterProfilePhotoSection extends StatelessWidget {
  final CreateProjectDialogImageController imageController;
  final Color coverColor;
  final Color accentColor;

  const _CharacterProfilePhotoSection({
    required this.imageController,
    required this.coverColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final profileImage = imageController.coverImage;

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
          const Text(
            'Foto de perfil',
            style: TextStyle(
              color: Color(0xFF3A3339),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          CreateProjectDialogFieldDescription(
            text:
                'Escolha a imagem principal do personagem. GIF também é suportado. O enquadramento abaixo replica a mesma moldura usada no cartão.',
          ),
          const SizedBox(height: 8),
          _CharacterProfileImageEditor(
            image: profileImage,
            imageName: imageController.coverImageName,
            coverColor: coverColor,
            accentColor: accentColor,
            onScaleChanged: (value) => imageController.setImageScale(
              CreateProjectDialogColorTarget.cover,
              value,
            ),
            onOffsetChanged: (offsetX, offsetY) =>
                imageController.setImageOffset(
                  CreateProjectDialogColorTarget.cover,
                  offsetX,
                  offsetY,
                ),
            onPick: () =>
                imageController.pickImage(CreateProjectDialogColorTarget.cover),
            onRemove: profileImage.bytes == null
                ? null
                : () => imageController.removeImage(
                    CreateProjectDialogColorTarget.cover,
                  ),
          ),
        ],
      ),
    );
  }
}

class _CharacterProfileImageEditor extends StatelessWidget {
  final ProjectImageData image;
  final String? imageName;
  final Color coverColor;
  final Color accentColor;
  final ValueChanged<double> onScaleChanged;
  final void Function(double offsetX, double offsetY) onOffsetChanged;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  const _CharacterProfileImageEditor({
    required this.image,
    required this.imageName,
    required this.coverColor,
    required this.accentColor,
    required this.onScaleChanged,
    required this.onOffsetChanged,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = 22.0;
        final frameWidth = (constraints.maxWidth - (horizontalPadding * 2))
            .clamp(160.0, 230.0)
            .toDouble();
        final frameHeight =
            frameWidth *
            (characterProfileTileHeight / characterProfileTileWidth);
        final canvasHeight = frameHeight + 44;
        final frameTop = (canvasHeight - frameHeight) / 2;
        final frameLeft = (constraints.maxWidth - frameWidth) / 2;
        final metrics =
            image.bytes != null && image.width != null && image.height != null
            ? computeProjectImageViewportMetrics(
                viewportSize: Size(frameWidth, frameHeight),
                imageWidth: image.width!,
                imageHeight: image.height!,
                scale: image.scale,
              )
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: canvasHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.alphaBlend(
                        accentColor.withValues(alpha: 0.14),
                        Colors.white.withValues(alpha: 0.84),
                      ),
                      Color.alphaBlend(
                        coverColor.withValues(alpha: 0.36),
                        const Color(0xFFF8F1F5),
                      ),
                      Color.alphaBlend(
                        accentColor.withValues(alpha: 0.12),
                        const Color(0xFFF0E2EA),
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
                child: image.bytes == null
                    ? Center(
                        child: Text(
                          'Nenhuma foto selecionada',
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
                            currentOffsetX: image.offsetX,
                            currentOffsetY: image.offsetY,
                            dragDelta: details.delta,
                            metrics: resolvedMetrics,
                          );
                          onOffsetChanged(offset.dx, offset.dy);
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Center(
                              child: SizedBox(
                                width: frameWidth,
                                height: frameHeight,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                    topRight: Radius.circular(18),
                                    bottomRight: Radius.circular(18),
                                  ),
                                  child: ProjectImageTransformView(
                                    imageBytes: image.bytes!,
                                    imageWidth: image.width ?? frameWidth,
                                    imageHeight: image.height ?? frameHeight,
                                    scale: image.scale,
                                    offsetX: image.offsetX,
                                    offsetY: image.offsetY,
                                    viewportWidth: frameWidth,
                                    viewportHeight: frameHeight,
                                  ),
                                ),
                              ),
                            ),
                            IgnorePointer(
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    height: frameTop,
                                    child: Container(
                                      color: Colors.white.withValues(
                                        alpha: 0.34,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    height: frameTop,
                                    child: Container(
                                      color: Colors.white.withValues(
                                        alpha: 0.34,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: frameLeft,
                                    top: frameTop,
                                    width: frameWidth,
                                    height: frameHeight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                          topRight: Radius.circular(18),
                                          bottomRight: Radius.circular(18),
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.94,
                                          ),
                                          width: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: frameTop,
                                    bottom: frameTop,
                                    width: frameLeft,
                                    child: Container(
                                      color: Colors.white.withValues(
                                        alpha: 0.34,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: frameTop,
                                    bottom: frameTop,
                                    width: frameLeft,
                                    child: Container(
                                      color: Colors.white.withValues(
                                        alpha: 0.34,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
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
            if (image.bytes != null) ...[
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
                        value: image.scale,
                        min: 1,
                        max: 3,
                        onChanged: onScaleChanged,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${image.scale.toStringAsFixed(1)}x',
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
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPick,
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: Text(
                      image.bytes == null ? 'Escolher foto' : 'Trocar foto',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF514752),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                if (onRemove != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
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
                    child: const Text('Remover'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Formatos suportados: JPEG, PNG, GIF e WEBP.',
              style: TextStyle(color: Color(0xFF6A6167), fontSize: 11),
            ),
          ],
        );
      },
    );
  }
}
