import 'package:flutter/material.dart';

import './pages/shell_page.dart';
import './widgets/custom_nav_bar.dart';

class Wireframe extends StatelessWidget {
  const Wireframe({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Wireframe",
      initialRoute: "/projects",
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (_) => const ShellPage(initialTab: NavTab.projects),
        "/projects": (_) => const ShellPage(initialTab: NavTab.projects),
        "/ideas": (_) => const ShellPage(initialTab: NavTab.ideas),
      },
    );
  }
}
