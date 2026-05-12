import 'dart:ui';

import 'package:flutter/material.dart';

typedef AnchoredInfoBubbleBuilder =
    Widget Function(
      BuildContext context, {
      required bool showAbove,
      required double pointerLeft,
      required double arrowSize,
      required Widget child,
    });

Future<void> showAnchoredInfoBubbleDialog({
  required BuildContext context,
  required Rect anchorRect,
  required Widget child,
  required AnchoredInfoBubbleBuilder bubbleBuilder,
  double width = 180,
  double estimatedHeight = 110,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Info',
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 140),
    pageBuilder: (context, animation, secondaryAnimation) {
      final screenSize = MediaQuery.of(context).size;
      const horizontalPadding = 12.0;
      const arrowSize = 12.0;
      const verticalGap = 8.0;

      final left = (anchorRect.center.dx - (width / 2))
          .clamp(
            horizontalPadding,
            screenSize.width - width - horizontalPadding,
          )
          .toDouble();

      final showAbove =
          anchorRect.bottom + estimatedHeight > screenSize.height - 24;
      final top =
          (showAbove
                  ? anchorRect.top - estimatedHeight - arrowSize - verticalGap
                  : anchorRect.bottom + verticalGap)
              .clamp(12.0, screenSize.height - estimatedHeight - 12.0)
              .toDouble();

      final pointerLeft = (anchorRect.center.dx - left - (arrowSize / 2))
          .clamp(18.0, width - 18.0)
          .toDouble();

      return Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: width,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 140),
                tween: Tween<double>(begin: 0.96, end: 1),
                builder: (context, scale, dialogChild) {
                  return Transform.scale(
                    scale: scale,
                    alignment: showAbove
                        ? Alignment.bottomCenter
                        : Alignment.topCenter,
                    child: dialogChild,
                  );
                },
                child: bubbleBuilder(
                  context,
                  showAbove: showAbove,
                  pointerLeft: pointerLeft,
                  arrowSize: arrowSize,
                  child: child,
                ),
              ),
            ),
          ],
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class AnchoredInfoBubbleFrame extends StatelessWidget {
  final bool showAbove;
  final double pointerLeft;
  final double arrowSize;
  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;
  final EdgeInsetsGeometry padding;
  final BoxDecoration decoration;
  final BoxDecoration? foregroundDecoration;
  final Color arrowColor;

  const AnchoredInfoBubbleFrame({
    super.key,
    required this.showAbove,
    required this.pointerLeft,
    required this.arrowSize,
    required this.child,
    required this.borderRadius,
    required this.blurSigma,
    required this.padding,
    required this.decoration,
    required this.arrowColor,
    this.foregroundDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: decoration,
          foregroundDecoration: foregroundDecoration,
          child: child,
        ),
      ),
    );

    final arrow = Positioned(
      left: pointerLeft,
      top: showAbove ? null : 0,
      bottom: showAbove ? 0 : null,
      child: CustomPaint(
        size: Size(arrowSize, arrowSize),
        painter: AnchoredInfoBubbleArrowPainter(
          color: arrowColor,
          pointUp: !showAbove,
        ),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: showAbove
              ? EdgeInsets.only(bottom: arrowSize - 1)
              : EdgeInsets.only(top: arrowSize - 1),
          child: bubble,
        ),
        arrow,
      ],
    );
  }
}

class AnchoredInfoBubbleArrowPainter extends CustomPainter {
  final Color color;
  final bool pointUp;

  const AnchoredInfoBubbleArrowPainter({
    required this.color,
    required this.pointUp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    if (pointUp) {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close();
    }

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant AnchoredInfoBubbleArrowPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.pointUp != pointUp;
  }
}
