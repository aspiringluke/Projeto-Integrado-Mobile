import 'package:flutter/material.dart';

class TagModel {
  final String label;
  final Color color;

  const TagModel({required this.label, required this.color});

  String get normalizedLabel => normalizeTagLabel(label);

  TagModel copyWith({String? label, Color? color}) {
    return TagModel(label: label ?? this.label, color: color ?? this.color);
  }
}

String sanitizeTagLabel(String label) {
  return label.trim().replaceAll(RegExp(r'\s+'), ' ');
}

String normalizeTagLabel(String label) {
  return sanitizeTagLabel(label).toLowerCase();
}
