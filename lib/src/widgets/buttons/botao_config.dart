import 'package:flutter/material.dart';

class BotaoConfig extends StatelessWidget {
  const BotaoConfig({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.2),
        color: Colors.white.withOpacity(0.1),
      ),
      child: IconButton(
        icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
        onPressed: () {},
      ),
    );
  }
}
