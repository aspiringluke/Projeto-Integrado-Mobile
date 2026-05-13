import 'package:flutter/material.dart';

import 'tag_model.dart';

class TagGroupModel {
  final int? id;
  final String title;
  final Color color;
  final List<TagModel> tags;

  const TagGroupModel({
    this.id,
    required this.title,
    required this.color,
    required this.tags,
  });

  TagGroupModel copyWith({
    int? id,
    String? title,
    Color? color,
    List<TagModel>? tags,
  }) {
    return TagGroupModel(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
      tags: tags ?? this.tags,
    );
  }
}
