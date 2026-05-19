import 'package:sqlite3/wasm.dart';

import 'db_schema.dart';

const String _databaseName = '/wireframe.db';
const String _sqliteWasmPath = 'sqlite3.wasm';

Future<WasmSqlite3>? _sqliteFuture;

Future<WasmSqlite3> _loadSqlite() {
  return _sqliteFuture ??= _initializeSqlite();
}

Future<WasmSqlite3> _initializeSqlite() async {
  final sqlite = await WasmSqlite3.loadFromUrl(Uri.parse(_sqliteWasmPath));
  final fileSystem = await IndexedDbFileSystem.open(dbName: 'wireframe_db');
  sqlite.registerVirtualFileSystem(fileSystem, makeDefault: true);
  return sqlite;
}

Future<CommonDatabase> getConnection() async {
  final sqlite = await _loadSqlite();
  return sqlite.open(_databaseName);
}

Future<void> initDatabase() async {
  final conn = await getConnection();
  initializeSchema(conn);

  conn.close();
}
