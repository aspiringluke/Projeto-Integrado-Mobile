import 'package:flutter/material.dart';

class ProjectTagData {
  final String label;
  final Color color;

  const ProjectTagData({required this.label, required this.color});

  String get normalizedLabel => normalizeProjectTagLabel(label);
}

String normalizeProjectTagLabel(String label) {
  return sanitizeProjectTagLabel(label).toLowerCase();
}

String sanitizeProjectTagLabel(String label) {
  return label.trim().replaceAll(RegExp(r'\s+'), ' ');
}

Color projectTagColorAt(int index) {
  const palette = <Color>[
    Color(0xFFEB76AE),
    Color(0xFF8EAFF1),
    Color(0xFF6FAF8D),
    Color(0xFFE5A55A),
    Color(0xFF9A88E6),
    Color(0xFF6FB8C8),
    Color(0xFFD97E8E),
    Color(0xFF8B93A8),
  ];

  return palette[index % palette.length];
}
