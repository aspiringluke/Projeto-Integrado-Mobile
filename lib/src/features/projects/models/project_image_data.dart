import 'dart:typed_data';

class ProjectImageData {
  final Uint8List? bytes;
  final double? width;
  final double? height;
  final double scale;
  final double offsetX;
  final double offsetY;

  const ProjectImageData({
    this.bytes,
    this.width,
    this.height,
    this.scale = 1,
    this.offsetX = 0,
    this.offsetY = 0,
  });
}
