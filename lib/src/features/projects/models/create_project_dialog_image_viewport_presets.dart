class CreateProjectDialogImageEditorViewportPreset {
  final double canvasHeight;
  final double cropHeight;
  final double cropHorizontalInset;
  final double cropReferenceWidth;

  const CreateProjectDialogImageEditorViewportPreset({
    required this.canvasHeight,
    required this.cropHeight,
    required this.cropHorizontalInset,
    required this.cropReferenceWidth,
  });
}

const createProjectDialogCoverViewportPreset =
    CreateProjectDialogImageEditorViewportPreset(
      canvasHeight: 144,
      cropHeight: 74,
      cropHorizontalInset: 12,
      cropReferenceWidth: 240,
    );

const createProjectDialogAccentViewportPreset =
    CreateProjectDialogImageEditorViewportPreset(
      canvasHeight: 156,
      cropHeight: 112,
      cropHorizontalInset: 10,
      cropReferenceWidth: 240,
    );
