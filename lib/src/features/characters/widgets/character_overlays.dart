import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../shared/widgets/buttons/botao_voltar.dart';

Rect rectFromContext(BuildContext context) {
  final box = context.findRenderObject() as RenderBox;
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final offset = box.localToGlobal(Offset.zero, ancestor: overlay);
  return offset & box.size;
}

Future<void> showAnchoredInfoBubble({
  required BuildContext context,
  required Rect anchorRect,
  required Widget child,
  double width = 180,
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
      const estimatedHeight = 110.0;
      final left = (anchorRect.center.dx - (width / 2))
          .clamp(
            horizontalPadding,
            screenSize.width - width - horizontalPadding,
          )
          .toDouble();
      final showAbove = anchorRect.bottom + estimatedHeight > screenSize.height - 24;
      final top = (showAbove
              ? anchorRect.top - estimatedHeight - arrowSize - verticalGap
              : anchorRect.bottom + verticalGap)
          .clamp(12.0, screenSize.height - estimatedHeight - 12.0)
          .toDouble();
      final pointerLeft = (anchorRect.center.dx - left - (arrowSize / 2))
          .clamp(
            18.0,
            width - 18.0,
          )
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
                    alignment: showAbove ? Alignment.bottomCenter : Alignment.topCenter,
                    child: dialogChild,
                  );
                },
                child: _AnchoredInfoBubble(
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

class _AnchoredInfoBubble extends StatelessWidget {
  final bool showAbove;
  final double pointerLeft;
  final double arrowSize;
  final Widget child;

  const _AnchoredInfoBubble({
    required this.showAbove,
    required this.pointerLeft,
    required this.arrowSize,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.86),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
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
        painter: _BubbleArrowPainter(
          color: Colors.white.withValues(alpha: 0.9),
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

class _BubbleArrowPainter extends CustomPainter {
  final Color color;
  final bool pointUp;

  const _BubbleArrowPainter({
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
  bool shouldRepaint(covariant _BubbleArrowPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.pointUp != pointUp;
  }
}

class DashedUnderlinePainter extends CustomPainter {
  final Color color;

  const DashedUnderlinePainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 4.0;
    const dashGap = 2.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var startX = 0.0;
    final y = size.height / 2;

    while (startX < size.width) {
      final endX = (startX + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      startX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant DashedUnderlinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class CharacterPlaceholderPage extends StatelessWidget {
  final String title;

  const CharacterPlaceholderPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/FUNDO.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BotaoVoltar(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF2C262C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pagina interna do personagem em construcao.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black.withValues(alpha: 0.58),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
