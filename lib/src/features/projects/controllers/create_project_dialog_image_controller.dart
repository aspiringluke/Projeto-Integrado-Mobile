import 'package:flutter/material.dart';

import '../models/create_project_dialog_image_viewport_presets.dart';
import '../models/project_image_data.dart';
import '../utils/project_image_picker.dart';
import '../utils/project_image_picker_result.dart';
import '../widgets/project_image_transform_view.dart';
import 'create_project_dialog_controller.dart';

class CreateProjectDialogImageController extends ChangeNotifier {
  ProjectImageData _coverImage = const ProjectImageData();
  String? _coverImageName;
  ProjectImageData _accentImage = const ProjectImageData();
  String? _accentImageName;
  String? _imageErrorMessage;
  bool _isDisposed = false;

  ProjectImageData get coverImage => _coverImage;
  String? get coverImageName => _coverImageName;
  ProjectImageData get accentImage => _accentImage;
  String? get accentImageName => _accentImageName;
  String? get imageErrorMessage => _imageErrorMessage;

  ProjectImageData imageForTarget(CreateProjectDialogColorTarget target) {
    return _isCoverTarget(target) ? _coverImage : _accentImage;
  }

  String? imageNameForTarget(CreateProjectDialogColorTarget target) {
    return _isCoverTarget(target) ? _coverImageName : _accentImageName;
  }

  Future<void> pickImage(CreateProjectDialogColorTarget target) async {
    ProjectImagePickResult? result;
    try {
      result = await pickProjectImage();
    } on ProjectImagePickException catch (error) {
      _imageErrorMessage = error.message;
      _notifySafely();
      return;
    }

    if (result == null) {
      return;
    }

    if (_isDisposed) {
      return;
    }

    _imageErrorMessage = null;
    _setImageStateForTarget(
      target,
      image: ProjectImageData(
        bytes: result.bytes,
        width: result.width,
        height: result.height,
      ),
      imageName: result.name,
    );
    _notifySafely();
  }

  void removeImage(CreateProjectDialogColorTarget target) {
    _setImageStateForTarget(
      target,
      image: const ProjectImageData(),
      imageName: null,
    );
    _notifySafely();
  }

  void setImageScale(CreateProjectDialogColorTarget target, double value) {
    final metrics = _imageMetricsForTarget(target, value);
    final image = imageForTarget(target);

    _setImageStateForTarget(
      target,
      image: ProjectImageData(
        bytes: image.bytes,
        width: image.width,
        height: image.height,
        scale: value,
        offsetX: clampProjectImageOffset(
          image.offsetX,
          maxTranslation: metrics.maxTranslationX,
        ),
        offsetY: clampProjectImageOffset(
          image.offsetY,
          maxTranslation: metrics.maxTranslationY,
        ),
      ),
      imageName: imageNameForTarget(target),
    );
    _notifySafely();
  }

  void setImageOffset(
    CreateProjectDialogColorTarget target,
    double dx,
    double dy,
  ) {
    final image = imageForTarget(target);
    final metrics = _imageMetricsForTarget(target, image.scale);

    _setImageStateForTarget(
      target,
      image: ProjectImageData(
        bytes: image.bytes,
        width: image.width,
        height: image.height,
        scale: image.scale,
        offsetX: clampProjectImageOffset(
          dx,
          maxTranslation: metrics.maxTranslationX,
        ),
        offsetY: clampProjectImageOffset(
          dy,
          maxTranslation: metrics.maxTranslationY,
        ),
      ),
      imageName: imageNameForTarget(target),
    );
    _notifySafely();
  }

  CreateProjectDialogImageEditorViewportPreset _viewportPresetForTarget(
    CreateProjectDialogColorTarget target,
  ) {
    return _isCoverTarget(target)
        ? createProjectDialogCoverViewportPreset
        : createProjectDialogAccentViewportPreset;
  }

  ProjectImageViewportMetrics _imageMetricsForTarget(
    CreateProjectDialogColorTarget target,
    double scale,
  ) {
    final image = imageForTarget(target);
    final viewportPreset = _viewportPresetForTarget(target);

    return computeProjectImageViewportMetrics(
      viewportSize: Size(
        viewportPreset.cropReferenceWidth,
        viewportPreset.cropHeight,
      ),
      imageWidth: image.width ?? 0,
      imageHeight: image.height ?? 0,
      scale: scale,
    );
  }

  void _setImageStateForTarget(
    CreateProjectDialogColorTarget target, {
    required ProjectImageData image,
    required String? imageName,
  }) {
    if (_isCoverTarget(target)) {
      _coverImage = image;
      _coverImageName = imageName;
      return;
    }

    _accentImage = image;
    _accentImageName = imageName;
  }

  bool _isCoverTarget(CreateProjectDialogColorTarget target) =>
      target == CreateProjectDialogColorTarget.cover;

  void _notifySafely() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
