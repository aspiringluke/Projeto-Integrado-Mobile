import 'package:flutter/material.dart';

import './src/app/database/db.dart';
import './src/app/wireframe.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();
  runApp(const Wireframe());
}
