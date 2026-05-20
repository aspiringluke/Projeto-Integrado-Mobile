import 'package:projeto_integrado_mobile/src/features/projects/models/project_record.dart';

abstract interface class IProjectService {
  Future<(bool, ProjectRecord?, String?)> createProject(ProjectRecord project);
  Future<(bool, String)> updateProject(ProjectRecord project);
  Future<(bool, String)> updateProjectOrdering(List<ProjectRecord> projects);
  Future<(bool, ProjectRecord?, String?)> getProject(int id);
  Future<(bool, List<ProjectRecord>?, String?)> listProjects();
  Future<(bool, String)> touchProject(int id);
}
