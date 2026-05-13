import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/tags/controllers/tag_controller.dart';

import '../models/project_style_defaults.dart';
import '../models/project_tag_data.dart';

enum CreateProjectDialogColorTarget { cover, accent }

class CreateProjectDialogController extends ChangeNotifier {
  late final TagController _tagController;
  HSLColor _coverColor = HSLColor.fromColor(defaultProjectCoverColor);
  HSLColor _accentColor = HSLColor.fromColor(defaultProjectAccentColor);
  CreateProjectDialogColorTarget _activeColorTarget =
      CreateProjectDialogColorTarget.accent;

  CreateProjectDialogController({required List<ProjectTagData> availableTags})
    {
    _tagController = TagController(
      knownTags: availableTags,
      groupTitle: 'Projetos',
    );
    _tagController.addListener(_forwardTagChanges);
  }

  @override
  void dispose() {
    _tagController.removeListener(_forwardTagChanges);
    _tagController.dispose();
    super.dispose();
  }

  void _forwardTagChanges() {
    notifyListeners();
  }

  List<ProjectTagData> get knownTags => _tagController.knownTags;

  Set<String> get selectedTagLabels => _tagController.selectedTagLabels;

  Color get newTagColor => _tagController.draftTagColor;

  Color get coverColor => _coverColor.toColor();

  Color get accentColor => _accentColor.toColor();

  HSLColor get activeHslColor =>
      _isCoverTarget(_activeColorTarget) ? _coverColor : _accentColor;

  Color get activeColor =>
      _isCoverTarget(_activeColorTarget) ? coverColor : accentColor;

  CreateProjectDialogColorTarget get activeColorTarget => _activeColorTarget;

  List<ProjectTagData> get selectedTags => _tagController.selectedTags;

  bool isSelectedTag(ProjectTagData tag) => _tagController.isSelected(tag);

  void toggleTag(ProjectTagData tag) {
    _tagController.toggle(tag);
  }

  bool addTagFromInput(String input) {
    return _tagController.addTagFromInput(input);
  }

  void setNewTagColor(Color color) {
    _tagController.setDraftTagColor(color);
  }

  void setActiveColorTarget(CreateProjectDialogColorTarget target) {
    if (_activeColorTarget == target) return;
    _activeColorTarget = target;
    notifyListeners();
  }

  void setActiveHue(double value) {
    if (_isCoverTarget(_activeColorTarget)) {
      _coverColor = _coverColor.withHue(value);
    } else {
      _accentColor = _accentColor.withHue(value);
    }
    notifyListeners();
  }

  void setActiveSaturation(double value) {
    if (_isCoverTarget(_activeColorTarget)) {
      _coverColor = _coverColor.withSaturation(value);
    } else {
      _accentColor = _accentColor.withSaturation(value);
    }
    notifyListeners();
  }

  void setActiveLightness(double value) {
    if (_isCoverTarget(_activeColorTarget)) {
      _coverColor = _coverColor.withLightness(value);
    } else {
      _accentColor = _accentColor.withLightness(value);
    }
    notifyListeners();
  }

  bool isCoverTarget(CreateProjectDialogColorTarget target) =>
      _isCoverTarget(target);

  bool _isCoverTarget(CreateProjectDialogColorTarget target) =>
      target == CreateProjectDialogColorTarget.cover;
}
