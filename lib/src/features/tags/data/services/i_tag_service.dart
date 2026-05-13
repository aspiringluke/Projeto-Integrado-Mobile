import 'package:flutter/material.dart';

import 'package:projeto_integrado_mobile/src/features/tags/models/tag_model.dart';

abstract interface class ITagService {
  Future<(bool, TagModel?, String?)> upsertTag({
    required String label,
    required Color color,
    int? groupId,
  });

  Future<(bool, List<TagModel>?, String?)> listTags({int? groupId});
}
