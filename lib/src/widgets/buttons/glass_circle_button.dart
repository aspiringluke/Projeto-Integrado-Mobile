import 'dart:ui';

import 'package:flutter/material.dart';

class GlassCircleButton extends StatelessWidget {
  final double diameter;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double blurSigma;
  final Color fillColor;
  final Gradient? gradient;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry padding;
  final String? tooltip;

  const GlassCircleButton({
    super.key,
    required this.diameter,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.blurSigma = 8,
    this.fillColor = const Color(0x6BFFFFFF),
    this.gradient,
    this.borderColor = const Color(0xAAFFFFFF),
    this.borderWidth = 0.85,
    this.boxShadow,
    this.padding = EdgeInsets.zero,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient =
        gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(Colors.white.withValues(alpha: 0.16), fillColor),
            fillColor,
            Color.alphaBlend(Colors.black.withValues(alpha: 0.04), fillColor),
          ],
          stops: const [0.0, 0.55, 1.0],
        );

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        customBorder: const CircleBorder(),
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow:
                boxShadow ??
                [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(
                width: diameter,
                height: diameter,
                padding: padding,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fillColor,
                  gradient: effectiveGradient,
                  border: Border.all(
                    color: borderColor,
                    width: borderWidth,
                  ),
                ),
                foregroundDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.17),
                      Colors.white.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.24, 0.56],
                  ),
                ),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip == null || tooltip!.isEmpty) {
      return button;
    }

    return Tooltip(
      message: tooltip!,
      child: button,
    );
  }
}
