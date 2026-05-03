import 'package:file_picker/file_picker.dart';

import 'project_image_picker_result.dart';

Future<ProjectImagePickResult?> pickProjectImage() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
    withData: true,
  );

  if (result == null || result.files.isEmpty) {
    return null;
  }

  final file = result.files.first;
  final bytes = file.bytes;
  if (bytes == null) {
    return null;
  }

  return ProjectImagePickResult(
    name: file.name,
    bytes: bytes,
  );
}
