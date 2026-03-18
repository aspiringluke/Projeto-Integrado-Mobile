import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
        destinations: [
            NavigationDestination(
                selectedIcon: Icon(Icons.library_books),
                icon: Icon(Icons.library_books_outlined),
                label: 'Projetos',
            ),
              NavigationDestination(
                selectedIcon: Icon(Icons.lightbulb),
                icon: Badge(label: Text('2'), child: Icon(Icons.lightbulb_outline)),
                label: 'Ideias',
            ),
        ],
    );
  }
}