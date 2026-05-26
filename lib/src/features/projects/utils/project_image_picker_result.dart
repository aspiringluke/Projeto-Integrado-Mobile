import 'dart:typed_data';

class ProjectImagePickResult {
  final String name;
  final Uint8List bytes;
  final double width;
  final double height;

  const ProjectImagePickResult({
    required this.name,
    required this.bytes,
    required this.width,
    required this.height,
  });
}
