import 'package:flutter/material.dart';

class BotaoVoltar extends StatelessWidget {
  const BotaoVoltar({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: null,
        child: Text("<",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight:
                FontWeight.w500
            )
        )
    );
  }
}