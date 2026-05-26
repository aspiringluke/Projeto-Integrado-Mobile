import 'dart:ui';

import 'note_metadata.dart';

enum FolderPreviewItemKind { note, folder }

class FolderPreviewItem {
  final FolderPreviewItemKind kind;
  final String title;

  const FolderPreviewItem({required this.kind, required this.title});
}

class FolderPreviewData {
  final List<FolderPreviewItem> items;

  const FolderPreviewData({required this.items});

  bool get isEmpty => items.isEmpty;
}

class Folder {
  final String title;
  final int? id;
  final Color color;
  final int? parentFolderId;
  final NoteMetadata metadata;
  final DateTime createdAt;
  final DateTime lastModified;
  final DateTime lastAccessed;

  Folder({
    required this.title,
    required this.color,
    this.id,
    this.parentFolderId,
    this.metadata = const NoteMetadata(
      tagGroups: <NoteTagGroup>[],
      linkTarget: NoteLinkTarget(),
    ),
    required this.createdAt,
    required this.lastModified,
    required this.lastAccessed,
  });

  Folder copyWith({
    String? title,
    int? id,
    Color? color,
    int? parentFolderId,
    NoteMetadata? metadata,
    DateTime? createdAt,
    DateTime? lastModified,
    DateTime? lastAccessed,
  }) {
    return Folder(
      title: title ?? this.title,
      id: id ?? this.id,
      color: color ?? this.color,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }

  bool get isProjectRoot => metadata.isProjectRoot;
  bool get isCharacterRoot => metadata.isCharacterRoot;
  bool get isProtectedRoot => metadata.isProtectedRoot;
}
