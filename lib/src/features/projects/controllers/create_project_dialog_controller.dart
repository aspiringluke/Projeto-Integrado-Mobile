import 'package:flutter/material.dart';

import '../models/project_style_defaults.dart';
import '../models/project_tag_data.dart';

enum CreateProjectDialogColorTarget { cover, accent }

class CreateProjectDialogController extends ChangeNotifier {
  List<ProjectTagData> _knownTags;
  final Set<String> _selectedTagLabels = <String>{};
  late Color _newTagColor;
  HSLColor _coverColor = HSLColor.fromColor(defaultProjectCoverColor);
  HSLColor _accentColor = HSLColor.fromColor(defaultProjectAccentColor);
  CreateProjectDialogColorTarget _activeColorTarget =
      CreateProjectDialogColorTarget.accent;

  CreateProjectDialogController({required List<ProjectTagData> availableTags})
    : _knownTags = List<ProjectTagData>.from(availableTags) {
    _newTagColor = projectTagColorAt(_knownTags.length);
  }

  List<ProjectTagData> get knownTags => _knownTags;

  Set<String> get selectedTagLabels => _selectedTagLabels;

  Color get newTagColor => _newTagColor;

  Color get coverColor => _coverColor.toColor();

  Color get accentColor => _accentColor.toColor();

  HSLColor get activeHslColor =>
      _isCoverTarget(_activeColorTarget) ? _coverColor : _accentColor;

  Color get activeColor =>
      _isCoverTarget(_activeColorTarget) ? coverColor : accentColor;

  CreateProjectDialogColorTarget get activeColorTarget => _activeColorTarget;

  List<ProjectTagData> get selectedTags => _knownTags
      .where((tag) => _selectedTagLabels.contains(tag.normalizedLabel))
      .toList(growable: false);

  bool isSelectedTag(ProjectTagData tag) =>
      _selectedTagLabels.contains(tag.normalizedLabel);

  void toggleTag(ProjectTagData tag) {
    final normalizedLabel = tag.normalizedLabel;
    if (_selectedTagLabels.contains(normalizedLabel)) {
      _selectedTagLabels.remove(normalizedLabel);
    } else {
      _selectedTagLabels.add(normalizedLabel);
    }
    notifyListeners();
  }

  bool addTagFromInput(String input) {
    final sanitizedLabel = sanitizeProjectTagLabel(input);
    final normalizedLabel = normalizeProjectTagLabel(input);
    if (normalizedLabel.isEmpty) return false;

    final existingIndex = _knownTags.indexWhere(
      (tag) => tag.normalizedLabel == normalizedLabel,
    );

    if (existingIndex != -1) {
      _selectedTagLabels.add(normalizedLabel);
    } else {
      final newTag = ProjectTagData(label: sanitizedLabel, color: _newTagColor);
      _knownTags = <ProjectTagData>[..._knownTags, newTag];
      _selectedTagLabels.add(newTag.normalizedLabel);
    }

    _newTagColor = projectTagColorAt(_knownTags.length);
    notifyListeners();
    return true;
  }

  void setNewTagColor(Color color) {
    if (_newTagColor == color) return;
    _newTagColor = color;
    notifyListeners();
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
