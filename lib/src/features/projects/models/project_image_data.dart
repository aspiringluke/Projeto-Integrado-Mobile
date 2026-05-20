import 'dart:convert';
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

  ProjectImageData copyWith({
    Uint8List? bytes,
    double? width,
    double? height,
    double? scale,
    double? offsetX,
    double? offsetY,
    bool clearBytes = false,
  }) {
    return ProjectImageData(
      bytes: clearBytes ? null : bytes ?? this.bytes,
      width: clearBytes ? null : width ?? this.width,
      height: clearBytes ? null : height ?? this.height,
      scale: scale ?? this.scale,
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'bytes': bytes == null ? null : base64Encode(bytes!),
      'width': width,
      'height': height,
      'scale': scale,
      'offsetX': offsetX,
      'offsetY': offsetY,
    };
  }

  factory ProjectImageData.fromJson(Map<String, Object?> map) {
    final rawBytes = map['bytes'];

    return ProjectImageData(
      bytes: rawBytes is String && rawBytes.isNotEmpty
          ? Uint8List.fromList(base64Decode(rawBytes))
          : null,
      width: _readDouble(map['width']),
      height: _readDouble(map['height']),
      scale: _readDouble(map['scale']) ?? 1,
      offsetX: _readDouble(map['offsetX']) ?? 0,
      offsetY: _readDouble(map['offsetY']) ?? 0,
    );
  }
}

double? _readDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value);
  }

  return null;
}
