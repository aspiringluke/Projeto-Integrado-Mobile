import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/tags/models/tag_group_model.dart';

abstract interface class ITagGroupService {
  Future<(bool, TagGroupModel?, String?)> ensureGroup({
    required String title,
    required Color color,
  });

  Future<(bool, List<TagGroupModel>?, String?)> listGroups();
}
