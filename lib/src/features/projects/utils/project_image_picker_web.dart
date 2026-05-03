import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'project_image_picker_result.dart';

Future<ProjectImagePickResult?> pickProjectImage() {
  final completer = Completer<ProjectImagePickResult?>();
  final input = html.FileUploadInputElement()..accept = 'image/*';

  input.onChange.first.then((_) {
    final file = input.files?.first;
    if (file == null) {
      completer.complete(null);
      return;
    }

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.first.then((_) {
      final result = reader.result;
      if (result is! List<int>) {
        completer.complete(null);
        return;
      }

      completer.complete(
        ProjectImagePickResult(
          name: file.name,
          bytes: Uint8List.fromList(result),
        ),
      );
    });
  });

  input.click();
  return completer.future;
}
