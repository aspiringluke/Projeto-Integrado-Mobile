import 'package:projeto_integrado_mobile/src/features/characters/data/repositories/character_repository.dart';
import 'package:projeto_integrado_mobile/src/features/characters/models/characters_models.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/folder_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/data/repositories/note_repository.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/folder.dart';
import 'package:projeto_integrado_mobile/src/features/notas/models/note.dart';
import 'package:projeto_integrado_mobile/src/features/projects/data/repositories/project_repository.dart';
import 'package:projeto_integrado_mobile/src/features/projects/models/project_record.dart';
import 'package:projeto_integrado_mobile/src/features/shared/story_registry.dart';
import 'package:projeto_integrado_mobile/src/shared/utils/text_normalization.dart';

class AiMentionContextBuilder {
  AiMentionContextBuilder({
    NoteRepository? noteRepository,
    FolderRepository? folderRepository,
    ProjectRepository? projectRepository,
    CharacterRepository? characterRepository,
    StoryRegistry? registry,
  }) : _noteRepository = noteRepository ?? NoteRepository(),
       _folderRepository = folderRepository ?? FolderRepository(),
       _projectRepository = projectRepository ?? ProjectRepository(),
       _characterRepository = characterRepository ?? CharacterRepository(),
       _registry = registry ?? StoryRegistry.instance;

  final NoteRepository _noteRepository;
  final FolderRepository _folderRepository;
  final ProjectRepository _projectRepository;
  final CharacterRepository _characterRepository;
  final StoryRegistry _registry;

  Future<String> buildPromptWithMentionContext(String message) async {
    final mentions = _resolveMentionTargets(message);
    if (mentions.isEmpty) {
      return message;
    }

    final entries = <String>[];
    for (final target in mentions) {
      final entry = await _buildEntry(target);
      if (entry != null && entry.trim().isNotEmpty) {
        entries.add(entry.trim());
      }
    }

    if (entries.isEmpty) {
      return message;
    }

    return '''
Contexto das mencoes citadas pelo usuario:
${entries.join('\n\n')}

Use esse contexto como referencia factual para responder. Se uma informacao nao estiver no contexto, diga que nao foi encontrada no material mencionado.

Mensagem do usuario:
$message''';
  }

  List<MentionTargetRef> _resolveMentionTargets(String message) {
    final normalizedMessage = normalizeSearchText(message);
    if (normalizedMessage.isEmpty || !normalizedMessage.contains('@')) {
      return const <MentionTargetRef>[];
    }

    final matched = <String, MentionTargetRef>{};
    final targets = [..._registry.mentionTargets]
      ..sort((left, right) => right.label.length.compareTo(left.label.length));
    final mentionChunks = RegExp(
      r'@([^@\r\n,.!?;:]+)',
    ).allMatches(normalizedMessage).map((match) => match.group(1)!.trim());

    for (final chunk in mentionChunks) {
      for (final target in targets) {
        if (_chunkMatchesTarget(chunk, target)) {
          matched[target.uri] = target;
          break;
        }
      }
    }

    return matched.values.toList(growable: false);
  }

  bool _chunkMatchesTarget(String chunk, MentionTargetRef target) {
    final terms = <String>{
      target.label,
      ...target.searchTerms,
    }.where((term) => term.trim().isNotEmpty);

    for (final term in terms) {
      final normalizedTerm = normalizeSearchText(term);
      if (normalizedTerm.isEmpty) {
        continue;
      }

      if (chunk == normalizedTerm || chunk.startsWith('$normalizedTerm ')) {
        return true;
      }
    }

    return false;
  }

  Future<String?> _buildEntry(MentionTargetRef target) {
    return switch (target.kind) {
      MentionTargetKind.note => _buildNoteEntry(target),
      MentionTargetKind.folder => _buildFolderEntry(target),
      MentionTargetKind.project => _buildProjectEntry(target),
      MentionTargetKind.character => _buildCharacterEntry(target),
    };
  }

  Future<String?> _buildNoteEntry(MentionTargetRef target) async {
    final noteId = target.noteId ?? _idFromUri(target.uri);
    if (noteId == null || noteId <= 0) {
      return null;
    }

    final result = await _noteRepository.getNote(noteId);
    final note = result.$2;
    if (!result.$1 || note == null) {
      return null;
    }

    return '''
[Nota] ${note.title}
Descricao:
${_clip(note.text)}''';
  }

  Future<String?> _buildFolderEntry(MentionTargetRef target) async {
    final folderId = _idFromUri(target.uri);
    if (folderId == null || folderId <= 0) {
      return null;
    }

    final folderResult = await _folderRepository.getFolder(folderId);
    final folder = folderResult.$2;
    if (!folderResult.$1 || folder == null) {
      return null;
    }

    final notesResult = await _noteRepository.listNotes(folderId);
    final notes = notesResult.$2 ?? const <Note>[];
    final previewResult = await _folderRepository.getFolderTreePreview(
      folderId,
    );
    final preview = previewResult.$2;

    return '''
[Pasta] ${folder.title}
Vinculos: ${_describeFolderLinks(folder)}
Notas diretas:
${notes.take(6).map((note) => '- ${note.title}: ${_clip(note.text, maxLength: 420)}').join('\n')}
Itens recentes:
${_describeFolderPreview(preview)}''';
  }

  Future<String?> _buildProjectEntry(MentionTargetRef target) async {
    final project = await _findProject(target.label);
    if (project == null) {
      return null;
    }

    final characters = project.id == null
        ? const <CharacterListItem>[]
        : (await _characterRepository.listCharactersForProject(
                project.id!,
              )).$2 ??
              const <CharacterListItem>[];

    final tags = project.tags.map((tag) => tag.label).join(', ');
    final characterNames = characters
        .take(12)
        .map((character) => character.data.name)
        .where((name) => name.trim().isNotEmpty)
        .join(', ');

    return '''
[Projeto] ${project.title}
Sintese:
${_clip(project.synopsis)}
Tags: ${tags.isEmpty ? 'nenhuma' : tags}
Personagens: ${characterNames.isEmpty ? 'nenhum listado' : characterNames}''';
  }

  Future<String?> _buildCharacterEntry(MentionTargetRef target) async {
    final character = await _findCharacter(target);
    if (character == null) {
      return null;
    }

    final data = character.data;
    final notebook = data.notebookComplexityValues.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .take(12)
        .map((entry) => '- ${entry.key}: ${_clip(entry.value, maxLength: 360)}')
        .join('\n');

    return '''
[Personagem] ${data.name}
Projeto: ${character.projectTitle ?? 'sem projeto vinculado'}
Apelido: ${data.alias.isEmpty ? 'nao informado' : data.alias}
Funcao: ${data.functionTag.isEmpty ? 'nao informada' : data.functionTag}
Relevancia: ${data.relevanceTag.isEmpty ? 'nao informada' : data.relevanceTag}
Lema: ${data.motto.isEmpty ? 'nao informado' : data.motto}
Citacao: ${data.quote.isEmpty ? 'nao informada' : data.quote}
Sinopse:
${_clip(data.synopsis)}
Notas do caderno:
${notebook.isEmpty ? 'nenhuma' : notebook}''';
  }

  Future<ProjectRecord?> _findProject(String label) async {
    final result = await _projectRepository.listProjects();
    if (!result.$1) {
      return null;
    }

    final normalizedLabel = normalizeSearchText(label);
    for (final project in result.$2 ?? const <ProjectRecord>[]) {
      if (normalizeSearchText(project.title) == normalizedLabel) {
        return project;
      }
    }

    return null;
  }

  Future<CharacterListItem?> _findCharacter(MentionTargetRef target) async {
    final result = await _characterRepository.listAllCharacters();
    if (!result.$1) {
      return null;
    }

    final normalizedName = normalizeSearchText(
      target.characterName ?? target.label,
    );
    final normalizedProject = normalizeSearchText(target.projectTitle ?? '');
    for (final character in result.$2 ?? const <CharacterListItem>[]) {
      final nameMatches =
          normalizeSearchText(character.data.name) == normalizedName;
      final projectMatches =
          normalizedProject.isEmpty ||
          normalizeSearchText(character.projectTitle ?? '') ==
              normalizedProject;
      if (nameMatches && projectMatches) {
        return character;
      }
    }

    return null;
  }

  int? _idFromUri(String uri) {
    final parsed = Uri.tryParse(uri);
    if (parsed == null || parsed.pathSegments.isEmpty) {
      return null;
    }

    return int.tryParse(parsed.pathSegments.first);
  }

  String _describeFolderLinks(Folder folder) {
    final links = <String>[
      if (folder.metadata.linkTarget.projectTitle?.trim().isNotEmpty == true)
        'projeto=${folder.metadata.linkTarget.projectTitle}',
      if (folder.metadata.linkTarget.characterName?.trim().isNotEmpty == true)
        'personagem=${folder.metadata.linkTarget.characterName}',
      if (folder.metadata.projectRootTitle?.trim().isNotEmpty == true)
        'raizProjeto=${folder.metadata.projectRootTitle}',
      if (folder.metadata.characterRootName?.trim().isNotEmpty == true)
        'raizPersonagem=${folder.metadata.characterRootName}',
    ];

    return links.isEmpty ? 'nenhum' : links.join(', ');
  }

  String _describeFolderPreview(FolderPreviewData? preview) {
    if (preview == null || preview.items.isEmpty) {
      return 'nenhum';
    }

    return preview.items
        .map((item) {
          final kind = item.kind == FolderPreviewItemKind.folder
              ? 'pasta'
              : 'nota';
          return '- $kind: ${item.title}';
        })
        .join('\n');
  }

  String _clip(String value, {int maxLength = 1800}) {
    final normalized = value.trim();
    if (normalized.length <= maxLength) {
      return normalized.isEmpty ? 'vazio' : normalized;
    }

    return '${normalized.substring(0, maxLength).trimRight()}...';
  }
}
