part of 'project_card.dart';

Future<void> _showAnchoredInfoBubble({
  required BuildContext context,
  required Rect anchorRect,
  required Widget child,
  double width = 180,
}) {
  return showAnchoredInfoBubbleDialog(
    context: context,
    anchorRect: anchorRect,
    child: child,
    width: width,
    estimatedHeight: 130,
    bubbleBuilder:
        (
          context, {
          required showAbove,
          required pointerLeft,
          required arrowSize,
          required child,
        }) {
          return AnchoredInfoBubbleFrame(
            showAbove: showAbove,
            pointerLeft: pointerLeft,
            arrowSize: arrowSize,
            borderRadius: BorderRadius.circular(20),
            blurSigma: 12,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8FC).withValues(alpha: 0.78),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  const Color(0xFFFFF6FB).withValues(alpha: 0.84),
                  const Color(0xFFF2DCE8).withValues(alpha: 0.72),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.92),
                width: 0.9,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB96B92).withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.14),
                  Colors.white.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.24, 0.62],
              ),
            ),
            arrowColor: const Color(0xFFFFF7FB).withValues(alpha: 0.88),
            child: child,
          );
        },
  );
}

class _ProjectInfoButton extends StatelessWidget {
  const _ProjectInfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 38,
      height: 38,
      child: Center(child: _DottedCircle()),
    );
  }
}

class _DottedCircle extends StatelessWidget {
  const _DottedCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(
        painter: _DottedCirclePainter(
          color: const Color(0xFFB0B0B0),
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _DottedCirclePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final dashLength = 5.0;
    final gapLength = 4.0;
    final circumference = 2 * 3.1415926535897932 * radius;
    final dashAngle = dashLength / radius;
    final gapAngle = gapLength / radius;

    for (
      var startAngle = 0.0;
      startAngle < 2 * 3.1415926535897932;
      startAngle += dashAngle + gapAngle
    ) {
      canvas.drawArc(rect, startAngle, dashAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
