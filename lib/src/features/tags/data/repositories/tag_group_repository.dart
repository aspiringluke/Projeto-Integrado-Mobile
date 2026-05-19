import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/tags/data/services/i_tag_group_service.dart';
import 'package:projeto_integrado_mobile/src/features/tags/data/services/tag_group_service.dart';
import 'package:projeto_integrado_mobile/src/features/tags/models/tag_group_model.dart';

class TagGroupRepository {
  final ITagGroupService service;

  TagGroupRepository({ITagGroupService? service})
    : service = service ?? TagGroupService();

  Future<(bool, TagGroupModel?, String?)> ensureGroup({
    required String title,
    required Color color,
  }) {
    return service.ensureGroup(title: title, color: color);
  }

  Future<(bool, List<TagGroupModel>?, String?)> listGroups() {
    return service.listGroups();
  }
}
