import 'package:flutter/material.dart';

class BotaoVoltar extends StatelessWidget {
  const BotaoVoltar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 31,
      height: 31,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.42), width: 1),
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: IconButton(
        iconSize: 15,
        padding: EdgeInsets.zero,
        splashRadius: 17,
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Color(0xFFF6EDF3),
          size: 15,
        ),
        onPressed: () {},
      ),
    );
  }
}
