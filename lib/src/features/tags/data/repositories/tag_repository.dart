import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/tags/data/services/i_tag_service.dart';
import 'package:projeto_integrado_mobile/src/features/tags/data/services/tag_service.dart';
import 'package:projeto_integrado_mobile/src/features/tags/models/tag_model.dart';

class TagRepository {
  final ITagService service;

  TagRepository({ITagService? service}) : service = service ?? TagService();

  Future<(bool, TagModel?, String?)> upsertTag({
    required String label,
    required Color color,
    int? groupId,
  }) {
    return service.upsertTag(label: label, color: color, groupId: groupId);
  }

  Future<(bool, List<TagModel>?, String?)> listTags({int? groupId}) {
    return service.listTags(groupId: groupId);
  }
}
