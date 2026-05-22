import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../features/characters/controllers/characters_pin_controller.dart';
import '../../../features/characters/data/repositories/character_repository.dart';
import '../../../features/characters/models/characters_models.dart';
import '../../../features/characters/pages/characters_section.dart';
import '../../../features/characters/widgets/create_character_dialog.dart';
import '../../../features/notas/data/repositories/note_repository.dart';
import '../../../features/notas/models/note.dart';
import '../../../features/notas/models/note_metadata.dart';
import '../../../features/notas/utils/notes_dialogs.dart';
import '../../../features/shared/story_registry.dart';
import '../../../shared/widgets/funcoes_busca.dart';
import '../../../shared/widgets/buttons/glass_circle_button.dart';
import '../../../shared/widgets/main_header.dart';
import '../data/repositories/project_repository.dart';
import '../models/project_image_data.dart';
import '../models/project_record.dart';
import '../models/project_tag_data.dart';
import '../widgets/project_general_section.dart';
import '../widgets/project_image_transform_view.dart';
import '../widgets/project_image_viewer_dialog.dart';

part 'project_page_shell.dart';
part 'project_page_parts/project_page_action_widgets.dart';
