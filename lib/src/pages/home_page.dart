import 'package:flutter/material.dart';
import 'package:projeto_integrado_mobile/src/widgets/funcoes_busca.dart';
import 'package:projeto_integrado_mobile/src/widgets/main_header.dart';
import 'package:projeto_integrado_mobile/src/widgets/nav_bar.dart';
import 'package:projeto_integrado_mobile/src/widgets/project_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: NavBar(),
        body: Container(
            alignment: Alignment.center,
            color: Colors.white,
            child: Column(children: [
                MainHeader(),
                FuncoesBusca(),
                Column(
                    children: [ProjectCard()],
                )
            ],)
        )
    );
  }
}