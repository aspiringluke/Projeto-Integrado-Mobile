import 'dart:ui';

import 'project_image_data.dart';
import 'project_tag_data.dart';

class ProjectRecord {
  final int? id;
  final String title;
  final String synopsis;
  final List<ProjectTagData> tags;
  final Color coverColor;
  final Color accentColor;
  final ProjectImageData coverImage;
  final ProjectImageData accentImage;
  final bool isPinned;
  final int unpinnedIndex;
  final String characterDisplayMode;
  final int characterGridColumns;
  final List<int> featuredCharacterIds;
  final DateTime createdAt;
  final DateTime lastModified;
  final DateTime lastAccessed;

  const ProjectRecord({
    this.id,
    required this.title,
    required this.synopsis,
    this.tags = const <ProjectTagData>[],
    required this.coverColor,
    required this.accentColor,
    this.coverImage = const ProjectImageData(),
    this.accentImage = const ProjectImageData(),
    this.isPinned = false,
    this.unpinnedIndex = 0,
    this.characterDisplayMode = 'list',
    this.characterGridColumns = 3,
    this.featuredCharacterIds = const <int>[],
    required this.createdAt,
    required this.lastModified,
    required this.lastAccessed,
  });

  ProjectRecord copyWith({
    int? id,
    String? title,
    String? synopsis,
    List<ProjectTagData>? tags,
    Color? coverColor,
    Color? accentColor,
    ProjectImageData? coverImage,
    ProjectImageData? accentImage,
    bool? isPinned,
    int? unpinnedIndex,
    String? characterDisplayMode,
    int? characterGridColumns,
    List<int>? featuredCharacterIds,
    DateTime? createdAt,
    DateTime? lastModified,
    DateTime? lastAccessed,
  }) {
    return ProjectRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      synopsis: synopsis ?? this.synopsis,
      tags: tags ?? this.tags,
      coverColor: coverColor ?? this.coverColor,
      accentColor: accentColor ?? this.accentColor,
      coverImage: coverImage ?? this.coverImage,
      accentImage: accentImage ?? this.accentImage,
      isPinned: isPinned ?? this.isPinned,
      unpinnedIndex: unpinnedIndex ?? this.unpinnedIndex,
      characterDisplayMode: characterDisplayMode ?? this.characterDisplayMode,
      characterGridColumns: characterGridColumns ?? this.characterGridColumns,
      featuredCharacterIds: featuredCharacterIds ?? this.featuredCharacterIds,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }
}
