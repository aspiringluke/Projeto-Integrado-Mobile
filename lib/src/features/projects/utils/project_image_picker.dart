import 'project_image_picker_io.dart'
    if (dart.library.html) 'project_image_picker_web.dart' as impl;
import 'project_image_picker_result.dart';

Future<ProjectImagePickResult?> pickProjectImage() => impl.pickProjectImage();
