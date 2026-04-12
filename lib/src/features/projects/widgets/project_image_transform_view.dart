import 'dart:typed_data';

import 'package:flutter/material.dart';

class ProjectImageTransformView extends StatelessWidget {
  final Uint8List imageBytes;
  final double scale;
  final double offsetX;
  final double offsetY;
  final bool clipImage;

  const ProjectImageTransformView({
    super.key,
    required this.imageBytes,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
    this.clipImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final image = Transform.translate(
          offset: Offset(
            offsetX * size.width * 0.35,
            offsetY * size.height * 0.35,
          ),
          child: Transform.scale(
            scale: scale,
            child: SizedBox.expand(
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
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
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: image,
          ),
        );
      },
    );
  }
}
