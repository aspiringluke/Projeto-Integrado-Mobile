import 'dart:async';

import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';
import 'package:projeto_integrado_mobile/src/features/tags/data/repositories/tag_group_repository.dart';
import 'package:projeto_integrado_mobile/src/features/tags/data/repositories/tag_repository.dart';
import 'package:projeto_integrado_mobile/src/features/tags/models/tag_group_model.dart';
import 'package:projeto_integrado_mobile/src/features/tags/models/tag_model.dart';

class TagGroupController extends ChangeNotifier {
  final TagGroupRepository _groupRepository;
  final TagRepository _tagRepository;
  List<NoteTagGroup> _groups;

  TagGroupController({
    List<NoteTagGroup> groups = const <NoteTagGroup>[],
    TagGroupRepository? groupRepository,
    TagRepository? tagRepository,
  }) : _groups = List<NoteTagGroup>.from(groups),
       _groupRepository = groupRepository ?? TagGroupRepository(),
       _tagRepository = tagRepository ?? TagRepository();

  List<NoteTagGroup> get groups => List<NoteTagGroup>.unmodifiable(_groups);

  List<TagGroupModel> get groupsAsModels => _groups
      .map(
        (group) => TagGroupModel(
          title: group.title,
          color: group.color,
          tags: group.tags
              .map((tag) => TagModel(label: tag.label, color: group.color))
              .toList(growable: false),
        ),
      )
      .toList(growable: false);

  void setGroups(List<NoteTagGroup> groups) {
    _groups = List<NoteTagGroup>.from(groups);
    notifyListeners();
  }

  void addGroup({required String title, required Color color}) {
    final sanitizedTitle = title.trim();
    if (sanitizedTitle.isEmpty) return;

    _groups = <NoteTagGroup>[
      ..._groups,
      NoteTagGroup(
        title: sanitizedTitle,
        color: color,
        tags: const <NoteTagItem>[],
      ),
    ];
    unawaited(_persistGroup(title: sanitizedTitle, color: color));
    notifyListeners();
  }

  void updateGroup({
    required int groupIndex,
    required String title,
    required Color color,
  }) {
    if (groupIndex < 0 || groupIndex >= _groups.length) return;
    final sanitizedTitle = title.trim();
    if (sanitizedTitle.isEmpty) return;

    final groups = _groups.toList(growable: true);
    final group = groups[groupIndex];
    groups[groupIndex] = NoteTagGroup(
      title: sanitizedTitle,
      color: color,
      tags: group.tags,
    );
    _groups = groups;
    unawaited(
      _persistGroupWithTags(
        title: sanitizedTitle,
        color: color,
        tags: group.tags,
      ),
    );
    notifyListeners();
  }

  void removeGroup(int groupIndex) {
    if (groupIndex < 0 || groupIndex >= _groups.length) return;
    final groups = _groups.toList(growable: true)..removeAt(groupIndex);
    _groups = groups;
    notifyListeners();
  }

  void addTagToGroup({required int groupIndex, required String tagLabel}) {
    if (groupIndex < 0 || groupIndex >= _groups.length) return;
    final sanitizedLabel = tagLabel.trim();
    if (sanitizedLabel.isEmpty) return;

    final groups = _groups.toList(growable: true);
    final group = groups[groupIndex];
    final hasTag = group.tags.any(
      (tag) => tag.label.toLowerCase() == sanitizedLabel.toLowerCase(),
    );
    if (hasTag) return;

    groups[groupIndex] = NoteTagGroup(
      title: group.title,
      color: group.color,
      tags: <NoteTagItem>[
        ...group.tags,
        NoteTagItem(label: sanitizedLabel),
      ],
    );
    _groups = groups;
    unawaited(
      _persistTag(
        groupTitle: group.title,
        groupColor: group.color,
        tagLabel: sanitizedLabel,
      ),
    );
    notifyListeners();
  }

  void removeTagFromGroup({required int groupIndex, required int tagIndex}) {
    if (groupIndex < 0 || groupIndex >= _groups.length) return;
    final group = _groups[groupIndex];
    if (tagIndex < 0 || tagIndex >= group.tags.length) return;

    final groups = _groups.toList(growable: true);
    final tags = group.tags.toList(growable: true)..removeAt(tagIndex);
    groups[groupIndex] = NoteTagGroup(
      title: group.title,
      color: group.color,
      tags: tags,
    );
    _groups = groups;
    notifyListeners();
  }

  void updateTag({
    required int groupIndex,
    required int tagIndex,
    required String label,
  }) {
    if (groupIndex < 0 || groupIndex >= _groups.length) return;
    final group = _groups[groupIndex];
    if (tagIndex < 0 || tagIndex >= group.tags.length) return;

    final sanitizedLabel = label.trim();
    if (sanitizedLabel.isEmpty) return;

    final groups = _groups.toList(growable: true);
    final tags = group.tags.toList(growable: true);
    tags[tagIndex] = NoteTagItem(label: sanitizedLabel);
    groups[groupIndex] = NoteTagGroup(
      title: group.title,
      color: group.color,
      tags: tags,
    );
    _groups = groups;
    unawaited(
      _persistTag(
        groupTitle: group.title,
        groupColor: group.color,
        tagLabel: sanitizedLabel,
      ),
    );
    notifyListeners();
  }

  Future<void> _persistGroup({
    required String title,
    required Color color,
  }) async {
    await _groupRepository.ensureGroup(title: title, color: color);
  }

  Future<void> _persistGroupWithTags({
    required String title,
    required Color color,
    required List<NoteTagItem> tags,
  }) async {
    final groupResult = await _groupRepository.ensureGroup(
      title: title,
      color: color,
    );
    if (!groupResult.$1 || groupResult.$2?.id == null) return;

    final groupId = groupResult.$2!.id;
    for (final tag in tags) {
      final sanitizedLabel = tag.label.trim();
      if (sanitizedLabel.isEmpty) continue;
      await _tagRepository.upsertTag(
        label: sanitizedLabel,
        color: color,
        groupId: groupId,
      );
    }
  }

  Future<void> _persistTag({
    required String groupTitle,
    required Color groupColor,
    required String tagLabel,
  }) async {
    final groupResult = await _groupRepository.ensureGroup(
      title: groupTitle,
      color: groupColor,
    );
    if (!groupResult.$1 || groupResult.$2?.id == null) return;

    await _tagRepository.upsertTag(
      label: tagLabel,
      color: groupColor,
      groupId: groupResult.$2!.id,
    );
  }
}
