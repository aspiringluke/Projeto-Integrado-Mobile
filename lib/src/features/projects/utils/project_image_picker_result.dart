import 'dart:typed_data';

class ProjectImagePickResult {
  final String name;
  final Uint8List bytes;

  const ProjectImagePickResult({required this.name, required this.bytes});
}
