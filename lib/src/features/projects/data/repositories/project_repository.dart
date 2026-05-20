import 'dart:ui';

import 'package:projeto_integrado_mobile/src/features/projects/data/services/i_project_service.dart';
import 'package:projeto_integrado_mobile/src/features/projects/data/services/sqlite_project_service.dart';
import 'package:projeto_integrado_mobile/src/features/projects/models/project_image_data.dart';
import 'package:projeto_integrado_mobile/src/features/projects/models/project_record.dart';
import 'package:projeto_integrado_mobile/src/features/projects/models/project_tag_data.dart';

class ProjectRepository {
  final IProjectService service;

  ProjectRepository({IProjectService? service})
    : service = service ?? SqliteProjectService();

  Future<(bool, ProjectRecord?, String?)> createProject({
    required String title,
    String synopsis = '',
    List<ProjectTagData> tags = const <ProjectTagData>[],
    required Color coverColor,
    required Color accentColor,
    ProjectImageData coverImage = const ProjectImageData(),
    ProjectImageData accentImage = const ProjectImageData(),
    bool isPinned = false,
    int unpinnedIndex = 0,
    String characterDisplayMode = 'list',
    int characterGridColumns = 3,
    List<int> featuredCharacterIds = const <int>[],
  }) {
    final now = DateTime.now();

    return service.createProject(
      ProjectRecord(
        title: title,
        synopsis: synopsis,
        tags: tags,
        coverColor: coverColor,
        accentColor: accentColor,
        coverImage: coverImage,
        accentImage: accentImage,
        isPinned: isPinned,
        unpinnedIndex: unpinnedIndex,
        characterDisplayMode: characterDisplayMode,
        characterGridColumns: characterGridColumns,
        featuredCharacterIds: featuredCharacterIds,
        createdAt: now,
        lastModified: now,
        lastAccessed: now,
      ),
    );
  }

  Future<(bool, ProjectRecord?, String?)> getProject(int id) {
    return service.getProject(id);
  }

  Future<(bool, List<ProjectRecord>?, String?)> listProjects() {
    return service.listProjects();
  }

  Future<(bool, String)> touchProject(int id) {
    return service.touchProject(id);
  }

  Future<(bool, String)> saveProject(ProjectRecord project) {
    return service.updateProject(project);
  }

  Future<(bool, String)> saveProjectOrdering(List<ProjectRecord> projects) {
    return service.updateProjectOrdering(projects);
  }

  Future<(bool, String)> updateProject(
    int id, {
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
    DateTime? lastAccessed,
  }) async {
    final current = await getProject(id);
    if (!current.$1) {
      return (false, current.$3 ?? 'Erro ao buscar projeto');
    }

    final project = current.$2;
    if (project == null) {
      return (false, 'Projeto não encontrado');
    }

    return service.updateProject(
      project.copyWith(
        title: title ?? project.title,
        synopsis: synopsis ?? project.synopsis,
        tags: tags ?? project.tags,
        coverColor: coverColor ?? project.coverColor,
        accentColor: accentColor ?? project.accentColor,
        coverImage: coverImage ?? project.coverImage,
        accentImage: accentImage ?? project.accentImage,
        isPinned: isPinned ?? project.isPinned,
        unpinnedIndex: unpinnedIndex ?? project.unpinnedIndex,
        characterDisplayMode:
            characterDisplayMode ?? project.characterDisplayMode,
        characterGridColumns:
            characterGridColumns ?? project.characterGridColumns,
        featuredCharacterIds:
            featuredCharacterIds ?? project.featuredCharacterIds,
        lastAccessed: lastAccessed ?? project.lastAccessed,
      ),
    );
  }
}
