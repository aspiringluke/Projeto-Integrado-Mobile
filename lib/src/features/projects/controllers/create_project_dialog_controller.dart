import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';
import 'package:projeto_integrado_mobile/src/features/tags/controllers/tag_group_controller.dart';

import '../models/project_style_defaults.dart';
import '../models/project_tag_data.dart';

enum CreateProjectDialogColorTarget { cover, accent }

class CreateProjectDialogController extends ChangeNotifier {
  late final TagGroupController _tagGroupController;
  HSLColor _coverColor = HSLColor.fromColor(defaultProjectCoverColor);
  HSLColor _accentColor = HSLColor.fromColor(defaultProjectAccentColor);
  CreateProjectDialogColorTarget _activeColorTarget =
      CreateProjectDialogColorTarget.accent;

  CreateProjectDialogController({required List<ProjectTagData> availableTags}) {
    _tagGroupController = TagGroupController(groups: const <NoteTagGroup>[]);
    _tagGroupController.addListener(_forwardTagChanges);
  }

  @override
  void dispose() {
    _tagGroupController.removeListener(_forwardTagChanges);
    _tagGroupController.dispose();
    super.dispose();
  }

  void _forwardTagChanges() {
    notifyListeners();
  }

  List<NoteTagGroup> get tagGroups => _tagGroupController.groups;

  Color get coverColor => _coverColor.toColor();

  Color get accentColor => _accentColor.toColor();

  HSLColor get activeHslColor =>
      _isCoverTarget(_activeColorTarget) ? _coverColor : _accentColor;

  Color get activeColor =>
      _isCoverTarget(_activeColorTarget) ? coverColor : accentColor;

  CreateProjectDialogColorTarget get activeColorTarget => _activeColorTarget;

  List<ProjectTagData> get tags => _tagGroupController.groups
      .expand(
        (group) => group.tags.map(
          (tag) => ProjectTagData(
            label: tag.label,
            color: group.color,
            groupTitle: group.title,
          ),
        ),
      )
      .toList(growable: false);

  void addGroup({required String title, required Color color}) {
    _tagGroupController.addGroup(title: title, color: color);
  }

  void updateGroup({
    required int groupIndex,
    required String title,
    required Color color,
  }) {
    _tagGroupController.updateGroup(
      groupIndex: groupIndex,
      title: title,
      color: color,
    );
  }

  void removeGroup(int groupIndex) {
    _tagGroupController.removeGroup(groupIndex);
  }

  void addTagToGroup({required int groupIndex, required String tagLabel}) {
    _tagGroupController.addTagToGroup(
      groupIndex: groupIndex,
      tagLabel: tagLabel,
    );
  }

  void removeTagFromGroup({required int groupIndex, required int tagIndex}) {
    _tagGroupController.removeTagFromGroup(
      groupIndex: groupIndex,
      tagIndex: tagIndex,
    );
  }

  void updateTag({
    required int groupIndex,
    required int tagIndex,
    required String label,
  }) {
    _tagGroupController.updateTag(
      groupIndex: groupIndex,
      tagIndex: tagIndex,
      label: label,
    );
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
