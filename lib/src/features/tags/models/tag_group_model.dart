import 'package:flutter/material.dart';

import 'tag_model.dart';

class TagGroupModel {
  final String title;
  final Color color;
  final List<TagModel> tags;

  const TagGroupModel({
    required this.title,
    required this.color,
    required this.tags,
  });

  TagGroupModel copyWith({
    String? title,
    Color? color,
    List<TagModel>? tags,
  }) {
    return TagGroupModel(
      title: title ?? this.title,
      color: color ?? this.color,
      tags: tags ?? this.tags,
    );
  }
}
