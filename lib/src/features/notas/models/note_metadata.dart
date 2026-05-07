import 'dart:convert';
import 'dart:ui';

class NoteTagItem {
  final String label;

  const NoteTagItem({required this.label});

  Map<String, dynamic> toJson() => <String, dynamic>{'label': label};

  factory NoteTagItem.fromJson(Map<String, dynamic> json) {
    return NoteTagItem(label: (json['label'] as String? ?? '').trim());
  }
}

class NoteTagGroup {
  final String title;
  final Color color;
  final List<NoteTagItem> tags;

  const NoteTagGroup({
    required this.title,
    required this.color,
    required this.tags,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'color': color.toARGB32(),
    'tags': tags.map((tag) => tag.toJson()).toList(growable: false),
  };

  factory NoteTagGroup.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    return NoteTagGroup(
      title: (json['title'] as String? ?? '').trim(),
      color: Color((json['color'] as num?)?.toInt() ?? 0xFFDF6EB8),
      tags: rawTags is List
          ? rawTags
                .whereType<Map>()
                .map(
                  (entry) =>
                      NoteTagItem.fromJson(Map<String, dynamic>.from(entry)),
                )
                .where((tag) => tag.label.isNotEmpty)
                .toList(growable: false)
          : const <NoteTagItem>[],
    );
  }
}

class NoteLinkTarget {
  final String? projectTitle;
  final String? characterName;

  const NoteLinkTarget({this.projectTitle, this.characterName});

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (projectTitle != null && projectTitle!.trim().isNotEmpty)
      'projectTitle': projectTitle,
    if (characterName != null && characterName!.trim().isNotEmpty)
      'characterName': characterName,
  };

  factory NoteLinkTarget.fromJson(Map<String, dynamic> json) {
    return NoteLinkTarget(
      projectTitle: json['projectTitle'] as String?,
      characterName: json['characterName'] as String?,
    );
  }
}

class NoteMetadata {
  final List<NoteTagGroup> tagGroups;
  final NoteLinkTarget linkTarget;

  const NoteMetadata({required this.tagGroups, required this.linkTarget});

  factory NoteMetadata.empty() {
    return const NoteMetadata(
      tagGroups: <NoteTagGroup>[],
      linkTarget: NoteLinkTarget(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'tagGroups': tagGroups
        .map((group) => group.toJson())
        .toList(growable: false),
    'linkTarget': linkTarget.toJson(),
  };

  String toJsonString() => jsonEncode(toJson());

  factory NoteMetadata.fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.trim().isEmpty) {
      return NoteMetadata.empty();
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) {
        return NoteMetadata.empty();
      }

      final map = Map<String, dynamic>.from(decoded);
      final rawGroups = map['tagGroups'];
      final tagGroups = rawGroups is List
          ? rawGroups
                .whereType<Map>()
                .map(
                  (entry) =>
                      NoteTagGroup.fromJson(Map<String, dynamic>.from(entry)),
                )
                .where((group) => group.title.isNotEmpty)
                .toList(growable: false)
          : const <NoteTagGroup>[];

      final rawTarget = map['linkTarget'];
      final linkTarget = rawTarget is Map
          ? NoteLinkTarget.fromJson(Map<String, dynamic>.from(rawTarget))
          : const NoteLinkTarget();

      return NoteMetadata(tagGroups: tagGroups, linkTarget: linkTarget);
    } catch (_) {
      return NoteMetadata.empty();
    }
  }

  NoteMetadata copyWith({
    List<NoteTagGroup>? tagGroups,
    NoteLinkTarget? linkTarget,
  }) {
    return NoteMetadata(
      tagGroups: tagGroups ?? this.tagGroups,
      linkTarget: linkTarget ?? this.linkTarget,
    );
  }
}
