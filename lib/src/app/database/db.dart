import 'package:sqlite3/common.dart';

import 'db_native.dart' if (dart.library.js_interop) 'db_web.dart' as impl;

Future<CommonDatabase> getConnection() => impl.getConnection();

Future<void> initDatabase() => impl.initDatabase();
