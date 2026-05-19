import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

import 'db_schema.dart';

const String _databaseName = 'wireframe.db';

Future<CommonDatabase> getConnection() async {
  final docsDir = await getApplicationDocumentsDirectory();
  final databasePath = join(docsDir.path, _databaseName);
  final Database conn = sqlite3.open(databasePath);
  return conn;
}

Future<void> initDatabase() async {
  final docsDir = await getApplicationDocumentsDirectory();
  final databasePath = join(docsDir.path, _databaseName);
  final databaseFile = File(databasePath);
  final alreadyExists = await databaseFile.exists();

  final conn = await getConnection();
  initializeSchema(conn);

  conn.close();

  if (!alreadyExists) {
    debugPrint('Caminho do banco: $databasePath');
  }
}
