import 'package:flutter/material.dart';

import './glass_circle_button.dart';

class BotaoConfig extends StatelessWidget {
  final VoidCallback? onPressed;

  const BotaoConfig({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCircleButton(
      diameter: 34,
      onTap: onPressed ?? () {},
      blurSigma: 7,
      fillColor: Colors.white.withValues(alpha: 0.12),
      borderColor: Colors.white.withValues(alpha: 0.44),
      borderWidth: 0.95,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 9,
          offset: const Offset(0, 2),
        ),
      ],
      child: const Icon(
        Icons.settings_outlined,
        color: Color(0xFFF6EDF3),
        size: 17,
      ),
    );
  }
}
