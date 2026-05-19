import 'package:flutter/material.dart';

class TagModel {
  final int? id;
  final String label;
  final Color color;
  final int? groupId;

  const TagModel({
    this.id,
    required this.label,
    required this.color,
    this.groupId,
  });

  String get normalizedLabel => normalizeTagLabel(label);

  TagModel copyWith({
    int? id,
    String? label,
    Color? color,
    int? groupId,
  }) {
    return TagModel(
      id: id ?? this.id,
      label: label ?? this.label,
      color: color ?? this.color,
      groupId: groupId ?? this.groupId,
    );
  }
}

String sanitizeTagLabel(String label) {
  return label.trim().replaceAll(RegExp(r'\s+'), ' ');
}

String normalizeTagLabel(String label) {
  return sanitizeTagLabel(label).toLowerCase();
}
