import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './src/app/database/db.dart';
import './src/app/wireframe.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _runPlatformBootstrap();
  runApp(const Wireframe());
}

Future<void> _runPlatformBootstrap() async {
  if (kIsWeb) {
    await _bootstrapWeb();
    return;
  }

  await _bootstrapNative();
}

Future<void> _bootstrapWeb() async {
  await initDatabase();
}

Future<void> _bootstrapNative() async {
  await initDatabase();
}
