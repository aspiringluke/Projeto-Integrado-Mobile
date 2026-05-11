import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/notas/models/content_stats.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note_metadata.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/folder_color_picker.dart';
import 'package:projeto_integrado_mobile/src/features/notas/widgets/notes_visuals.dart';
import 'package:projeto_integrado_mobile/src/features/shared/story_registry.dart';

part 'notes_dialogs/form_dialogs.dart';
part 'notes_dialogs/confirmation_dialogs.dart';
part 'notes_dialogs/metadata_widgets.dart';
part 'notes_dialogs/folder_metadata_sheet.dart';

enum NotesCreateAction { note, folder }

class FolderFormData {
  final String title;
  final Color color;
  final NoteMetadata metadata;

  FolderFormData({
    required this.title,
    required this.color,
    required this.metadata,
  });
}

class NoteFormData {
  final String title;
  final String description;

  NoteFormData({required this.title, required this.description});
}

Future<NotesCreateAction?> showNotesCreateActionSheet(BuildContext context) {
  return showModalBottomSheet<NotesCreateAction>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.18),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: NotesGlassCard(
          elevated: true,
          radius: 24,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Stack(
            children: [
              Positioned.fill(
                top: 0,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.38),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.72],
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Criar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kNotesText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Escolha o tipo de item para esta camada da história.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kNotesMutedText.withValues(alpha: 0.92),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  NotesActionPill(
                    icon: Icons.note_add_outlined,
                    label: 'Nova nota',
                    onTap: () =>
                        Navigator.of(context).pop(NotesCreateAction.note),
                  ),
                  const SizedBox(height: 10),
                  NotesActionPill(
                    icon: Icons.create_new_folder_outlined,
                    label: 'Nova pasta',
                    onTap: () =>
                        Navigator.of(context).pop(NotesCreateAction.folder),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<FolderFormData?> showFolderFormDialog(
  BuildContext context, {
  String title = 'Nova pasta',
  String submitLabel = 'Criar',
  String? initialTitle,
  Color initialColor = const Color(0xFF8C5B79),
  NoteMetadata initialMetadata = const NoteMetadata(
    tagGroups: <NoteTagGroup>[],
    linkTarget: NoteLinkTarget(),
  ),
}) {
  return showDialog<FolderFormData>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.22),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: _FolderFormDialog(
        title: title,
        submitLabel: submitLabel,
        initialTitle: initialTitle,
        initialColor: initialColor,
        initialMetadata: initialMetadata,
      ),
    ),
  );
}

Future<NoteFormData?> showNoteFormDialog(BuildContext context) {
  return showDialog<NoteFormData>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.22),
    builder: (dialogContext) => const Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: _NoteFormDialog(),
    ),
  );
}

Future<bool> showDeleteFolderConfirmation(
  BuildContext context, {
  required String folderTitle,
  required bool hasChildren,
  int noteCount = 0,
  required ContentStats stats,
  bool preserveFolder = false,
}) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.24),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: _ConfirmDialog(
        title: preserveFolder ? 'Apagar conteúdo da pasta' : 'Excluir pasta',
        message: preserveFolder
            ? (hasChildren
                  ? 'A pasta "$folderTitle" é vinculada a um projeto. Apagar o conteúdo remove tudo que está dentro, incluindo subpastas.'
                  : 'A pasta "$folderTitle" é vinculada a um projeto. Deseja apagar todo o conteúdo dela sem excluir a pasta?')
            : hasChildren
            ? 'A pasta "$folderTitle" possui subpastas e $noteCount nota(s). Excluir também remove tudo que está dentro.'
            : 'A pasta "$folderTitle" possui $noteCount nota(s). Deseja excluir e apagar tudo que está salvo dentro?',
        confirmLabel: preserveFolder ? 'Apagar conteúdo' : 'Excluir',
        confirmColor: const Color(0xFFE05E8A),
        confirmRequiresHold: true,
        body: _DeleteMetricsSummary(stats: stats),
      ),
    ),
  );

  return shouldDelete == true;
}

Future<bool> showDeleteNoteConfirmation(
  BuildContext context, {
  required String noteTitle,
  required ContentStats stats,
}) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.24),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: _ConfirmDialog(
        title: 'Excluir nota',
        message: 'Deseja excluir "$noteTitle"?',
        confirmLabel: 'Excluir',
        confirmColor: const Color(0xFFE05E8A),
        body: _DeleteMetricsSummary(stats: stats),
      ),
    ),
  );

  return shouldDelete == true;
}

Future<bool> showDeleteSelectionConfirmation(
  BuildContext context, {
  required int noteCount,
  required int folderCount,
  required int totalNotesAffected,
  required ContentStats stats,
  List<String> noteTitles = const <String>[],
}) async {
  final message = folderCount > 0
      ? 'Você vai excluir $noteCount nota(s) e $folderCount pasta(s), afetando $totalNotesAffected nota(s) no total. A confirmação abaixo também remove o conteúdo dentro das pastas selecionadas.'
      : _buildDeleteNoteMessage(noteCount, noteTitles);
  final shouldDelete = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.24),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: _ConfirmDialog(
        title: 'Excluir selecionados',
        message: message,
        confirmLabel: 'Excluir',
        confirmColor: const Color(0xFFE05E8A),
        confirmRequiresHold: true,
        body: _DeleteMetricsSummary(stats: stats),
      ),
    ),
  );

  return shouldDelete == true;
}

String _buildDeleteNoteMessage(int noteCount, List<String> noteTitles) {
  final titles = noteTitles
      .map((title) => title.trim())
      .where((title) => title.isNotEmpty)
      .toList(growable: false);

  if (noteCount <= 1) {
    final title = titles.isNotEmpty ? titles.first : 'esta nota';
    return 'Deseja excluir "$title"?';
  }

  if (noteCount == 2 && titles.length >= 2) {
    return 'Deseja excluir "${titles[0]}" e "${titles[1]}"?';
  }

  return 'Deseja excluir $noteCount notas?';
}

Future<int?> showMoveNoteToFolderSheet(
  BuildContext context, {
  required List<Folder> folders,
  int? currentFolderId,
}) {
  return showModalBottomSheet<int?>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.18),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: NotesGlassCard(
          elevated: true,
          radius: 24,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Mover para',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kNotesText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              _MoveTargetTile(
                icon: Icons.home_outlined,
                title: 'Página raiz',
                color: kNotesPlum,
                enabled: currentFolderId != null,
                onTap: currentFolderId == null
                    ? null
                    : () => Navigator.of(context).pop(0),
              ),
              const SizedBox(height: 8),
              ...folders.map(
                (folder) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _MoveTargetTile(
                    icon: Icons.folder_outlined,
                    title: folder.title,
                    color: folder.color,
                    enabled: folder.id != currentFolderId,
                    onTap: folder.id == currentFolderId
                        ? null
                        : () => Navigator.of(context).pop(folder.id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
