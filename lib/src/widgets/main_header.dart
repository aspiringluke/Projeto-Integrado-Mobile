import 'package:flutter/material.dart';
import './buttons/botao_voltar.dart';
import './buttons/botao_config.dart';

// TODO: Subsituir os métodos deprecated (o VSCode mostra quais são)

class MainHeader extends StatelessWidget {
  const MainHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF8B7D8B), 
                Color(0xFFDF6EB8), 
              ],
            ),
          ),
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BotaoVoltar(),
                  Text(
                    "WIREFRAME",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 8.0,
                    ),
                  ),
                  BotaoConfig(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
}
}