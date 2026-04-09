import 'package:flutter/material.dart';

Rect rectFromContext(BuildContext context) {
  final box = context.findRenderObject() as RenderBox;
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final offset = box.localToGlobal(Offset.zero, ancestor: overlay);
  return offset & box.size;
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
