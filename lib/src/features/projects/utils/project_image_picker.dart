import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';

import 'project_image_picker_result.dart';

const int maxProjectImageBytes = 20 * 1024 * 1024;
const int maxProjectImageDimension = 1600;

class ProjectImagePickException implements Exception {
  final String message;

  const ProjectImagePickException(this.message);

  @override
  String toString() => message;
}

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

  return _normalizePickedImage(file.name, bytes);
}

Future<ProjectImagePickResult> _normalizePickedImage(
  String fileName,
  Uint8List bytes,
) async {
  final isGif = fileName.toLowerCase().endsWith('.gif');
  final decoded = await _decodeImage(bytes);
  final image = decoded.frame.image;
  final width = image.width.toDouble();
  final height = image.height.toDouble();
  image.dispose();
  decoded.codec.dispose();

  if (isGif) {
    if (bytes.lengthInBytes > maxProjectImageBytes) {
      throw const ProjectImagePickException(
        'A imagem precisa ter no máximo 20 MB.',
      );
    }

    return ProjectImagePickResult(
      name: fileName,
      bytes: bytes,
      width: width,
      height: height,
    );
  }

  final longestSide = math.max(width, height);
  final shouldDownscale = longestSide > maxProjectImageDimension;
  if (!shouldDownscale && bytes.lengthInBytes <= maxProjectImageBytes) {
    return ProjectImagePickResult(
      name: fileName,
      bytes: bytes,
      width: width,
      height: height,
    );
  }

  if (shouldDownscale) {
    final scale = maxProjectImageDimension / longestSide;
    final targetWidth = math.max(1, (width * scale).round());
    final targetHeight = math.max(1, (height * scale).round());
    final resized = await _resizeImageAsPng(
      bytes,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );

    if (resized.bytes.lengthInBytes <= maxProjectImageBytes) {
      return ProjectImagePickResult(
        name: fileName,
        bytes: resized.bytes,
        width: resized.width,
        height: resized.height,
      );
    }
  }

  if (bytes.lengthInBytes > maxProjectImageBytes) {
    throw const ProjectImagePickException(
      'A imagem precisa ter no máximo 20 MB.',
    );
  }

  return ProjectImagePickResult(
    name: fileName,
    bytes: bytes,
    width: width,
    height: height,
  );
}

Future<({ui.Codec codec, ui.FrameInfo frame})> _decodeImage(
  Uint8List bytes,
) async {
  try {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return (codec: codec, frame: frame);
  } catch (_) {
    throw const ProjectImagePickException(
      'Não foi possível carregar essa imagem.',
    );
  }
}

Future<ProjectImagePickResult> _resizeImageAsPng(
  Uint8List bytes, {
  required int targetWidth,
  required int targetHeight,
}) async {
  final codec = await ui.instantiateImageCodec(
    bytes,
    targetWidth: targetWidth,
    targetHeight: targetHeight,
  );
  final frame = await codec.getNextFrame();
  final image = frame.image;
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final resizedBytes = data?.buffer.asUint8List();
  final result = ProjectImagePickResult(
    name: '',
    bytes: resizedBytes ?? bytes,
    width: image.width.toDouble(),
    height: image.height.toDouble(),
  );
  image.dispose();
  codec.dispose();
  return result;
}
