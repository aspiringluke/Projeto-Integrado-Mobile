import 'package:flutter/material.dart';

import './buttons/botao_voltar.dart';
import './buttons/botao_config.dart';

class MainHeader extends StatelessWidget {
  const MainHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // eu não faço IDEIA de como fazer um header decente
    // a sizedbox não tem nenhuma configuração de estilo e o card
    // é arredondado por padrão
    return SizedBox(
        height: 200,
        child: Card(
            color: Color.fromARGB(255, 223, 110, 184),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    BotaoVoltar(),
                    Text("WIREFRAME", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w200)),
                    BotaoConfig(),
                ],
            )
        )
    );
  }
}