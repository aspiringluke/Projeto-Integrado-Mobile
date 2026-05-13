import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/projects/models/project_tag_data.dart';
import 'package:projeto_integrado_mobile/src/features/tags/models/tag_model.dart';

class TagPoolResolution {
  final List<ProjectTagData> resolvedKnownTags;
  final List<ProjectTagData> resolvedIncomingTags;

  const TagPoolResolution({
    required this.resolvedKnownTags,
    required this.resolvedIncomingTags,
  });
}

class TagController extends ChangeNotifier {
  List<ProjectTagData> _knownTags;
  final Set<String> _selectedTagLabels;
  Color _draftTagColor;

  TagController({
    List<ProjectTagData> knownTags = const <ProjectTagData>[],
    Iterable<String> selectedTagLabels = const <String>[],
    Color? draftTagColor,
  }) : _knownTags = List<ProjectTagData>.from(knownTags),
       _selectedTagLabels = <String>{...selectedTagLabels},
       _draftTagColor = draftTagColor ?? projectTagColorAt(knownTags.length);

  List<ProjectTagData> get knownTags =>
      List<ProjectTagData>.unmodifiable(_knownTags);
  Set<String> get selectedTagLabels => Set<String>.unmodifiable(_selectedTagLabels);
  Color get draftTagColor => _draftTagColor;

  List<ProjectTagData> get selectedTags => _knownTags
      .where((tag) => _selectedTagLabels.contains(tag.normalizedLabel))
      .toList(growable: false);

  bool isSelected(ProjectTagData tag) {
    return _selectedTagLabels.contains(tag.normalizedLabel);
  }

  void toggle(ProjectTagData tag) {
    final normalizedLabel = tag.normalizedLabel;
    if (_selectedTagLabels.contains(normalizedLabel)) {
      _selectedTagLabels.remove(normalizedLabel);
    } else {
      _selectedTagLabels.add(normalizedLabel);
    }
    notifyListeners();
  }

  void setDraftTagColor(Color color) {
    if (_draftTagColor == color) return;
    _draftTagColor = color;
    notifyListeners();
  }

  bool addTagFromInput(String input) {
    final sanitizedLabel = sanitizeTagLabel(input);
    final normalizedLabel = normalizeTagLabel(input);
    if (normalizedLabel.isEmpty) return false;

    final existingTag = _findByNormalizedLabel(normalizedLabel);
    if (existingTag != null) {
      _selectedTagLabels.add(existingTag.normalizedLabel);
      notifyListeners();
      return true;
    }

    final newTag = ProjectTagData(label: sanitizedLabel, color: _draftTagColor);
    _knownTags = <ProjectTagData>[..._knownTags, newTag];
    _selectedTagLabels.add(newTag.normalizedLabel);
    _draftTagColor = projectTagColorAt(_knownTags.length);
    notifyListeners();
    return true;
  }

  String? upsertTagLabel(
    String input, {
    Color? newTagColor,
    bool select = false,
  }) {
    final sanitizedLabel = sanitizeTagLabel(input);
    final normalizedLabel = normalizeTagLabel(input);
    if (normalizedLabel.isEmpty) return null;

    final existingTag = _findByNormalizedLabel(normalizedLabel);
    if (existingTag != null) {
      if (select) {
        _selectedTagLabels.add(existingTag.normalizedLabel);
        notifyListeners();
      }
      return existingTag.label;
    }

    final tag = ProjectTagData(
      label: sanitizedLabel,
      color: newTagColor ?? _draftTagColor,
    );
    _knownTags = <ProjectTagData>[..._knownTags, tag];
    if (select) {
      _selectedTagLabels.add(tag.normalizedLabel);
    }
    _draftTagColor = projectTagColorAt(_knownTags.length);
    notifyListeners();
    return tag.label;
  }

  Color? colorForLabel(String label) {
    final normalizedLabel = normalizeTagLabel(label);
    if (normalizedLabel.isEmpty) return null;
    final tag = _findByNormalizedLabel(normalizedLabel);
    return tag?.color;
  }

  ProjectTagData? _findByNormalizedLabel(String normalizedLabel) {
    for (final tag in _knownTags) {
      if (tag.normalizedLabel == normalizedLabel) {
        return tag;
      }
    }
    return null;
  }

  static TagPoolResolution resolveProjectTagPool({
    required List<ProjectTagData> existingTags,
    required Iterable<ProjectTagData> incomingTags,
  }) {
    final nextKnownTags = List<ProjectTagData>.from(existingTags);
    final seenIncoming = <String>{};
    final resolvedIncoming = <ProjectTagData>[];

    for (final tag in incomingTags) {
      final normalizedLabel = normalizeTagLabel(tag.label);
      if (normalizedLabel.isEmpty || !seenIncoming.add(normalizedLabel)) {
        continue;
      }

      final knownIndex = nextKnownTags.indexWhere(
        (knownTag) => knownTag.normalizedLabel == normalizedLabel,
      );
      if (knownIndex != -1) {
        resolvedIncoming.add(nextKnownTags[knownIndex]);
        continue;
      }

      final sanitizedLabel = sanitizeTagLabel(tag.label);
      final addedTag = ProjectTagData(label: sanitizedLabel, color: tag.color);
      nextKnownTags.add(addedTag);
      resolvedIncoming.add(addedTag);
    }

    return TagPoolResolution(
      resolvedKnownTags: List<ProjectTagData>.unmodifiable(nextKnownTags),
      resolvedIncomingTags: List<ProjectTagData>.unmodifiable(resolvedIncoming),
    );
  }
}
