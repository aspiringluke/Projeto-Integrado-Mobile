import 'package:flutter/material.dart';

class BotaoConfig extends StatelessWidget {
  const BotaoConfig({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: null,
        child: Text("*",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500
            )
        )
    );
  }
}