enum NotesDragType { note, folder }

class NotesDragPayload {
  final NotesDragType type;
  final int id;

  const NotesDragPayload({
    required this.type,
    required this.id,
  });
}
