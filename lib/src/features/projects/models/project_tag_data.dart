import 'package:flutter/material.dart';

import '../../../shared/utils/text_normalization.dart';

class ProjectTagData {
  final int? groupId;
  final String? groupTitle;
  final String label;
  final Color color;

  const ProjectTagData({
    this.groupId,
    this.groupTitle,
    required this.label,
    required this.color,
  });

  String get normalizedLabel => normalizeProjectTagLabel(label);

  ProjectTagData copyWith({
    int? groupId,
    String? groupTitle,
    String? label,
    Color? color,
  }) {
    return ProjectTagData(
      groupId: groupId ?? this.groupId,
      groupTitle: groupTitle ?? this.groupTitle,
      label: label ?? this.label,
      color: color ?? this.color,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      if (groupId != null) 'groupId': groupId,
      if (groupTitle != null && groupTitle!.trim().isNotEmpty)
        'groupTitle': groupTitle,
      'label': label,
      'color': color.toARGB32(),
    };
  }

  factory ProjectTagData.fromJson(Map<String, Object?> map) {
    return ProjectTagData(
      groupId: _readIntValue(map['groupId']),
      groupTitle: map['groupTitle'] as String?,
      label: map['label'] as String? ?? '',
      color: Color(_readColorValue(map['color']) ?? 0xFFDF6EB8),
    );
  }
}

const List<Color> projectTagPalette = <Color>[
  Color(0xFFEB76AE),
  Color(0xFF8EAFF1),
  Color(0xFF6FAF8D),
  Color(0xFFE5A55A),
  Color(0xFF9A88E6),
  Color(0xFF6FB8C8),
  Color(0xFFD97E8E),
  Color(0xFF8B93A8),
];

String normalizeProjectTagLabel(String label) {
  return normalizeSearchText(sanitizeProjectTagLabel(label));
}

String sanitizeProjectTagLabel(String label) {
  return label.trim().replaceAll(RegExp(r'\s+'), ' ');
}

Color projectTagColorAt(int index) {
  return projectTagPalette[index % projectTagPalette.length];
}

int? _readColorValue(Object? value) {
  if (value is int) {
    return value;
  }

  if (value is String) {
    return int.tryParse(value);
  }

  return null;
}

int? _readIntValue(Object? value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value);
  }

  return null;
}
