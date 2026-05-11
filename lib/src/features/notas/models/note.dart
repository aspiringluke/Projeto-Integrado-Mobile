import 'dart:ui';

import 'note_metadata.dart';

class Note {
  final int? id;
  final String title;
  final String text;
  final Color color;
  final int? idPasta;
  final NoteMetadata metadata;
  final DateTime createdAt;
  final DateTime lastModified;
  final DateTime lastAccessed;

  Note({
    this.id,
    required this.title,
    required this.text,
    required this.color,
    this.idPasta,
    this.metadata = const NoteMetadata(
      tagGroups: <NoteTagGroup>[],
      linkTarget: NoteLinkTarget(),
    ),
    required this.createdAt,
    required this.lastModified,
    required this.lastAccessed,
  });
}
