import 'package:flutter/material.dart';

class BotaoConfig extends StatelessWidget {
  const BotaoConfig({super.key});

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
        iconSize: 16,
        padding: EdgeInsets.zero,
        splashRadius: 17,
        icon: const Icon(
          Icons.settings_outlined,
          color: Color(0xFFF6EDF3),
          size: 16,
        ),
        onPressed: () {},
      ),
    );
  }
}
