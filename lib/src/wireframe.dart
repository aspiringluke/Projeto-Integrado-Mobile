import 'package:flutter/material.dart';

import './pages/home_page.dart';

class Wireframe extends StatelessWidget {
  const Wireframe({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Wireframe",
        routes: {
            "/": (_) => HomePage()
        },
    );
  }
}