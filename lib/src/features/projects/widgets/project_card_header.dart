part of 'project_card.dart';

class _ProjectHeader extends StatelessWidget {
  final Color coverColor;
  final ProjectImageData coverImage;
  final bool isExpanded;
  final bool isEditing;
  final TextEditingController titleController;
  final FocusNode titleFocusNode;
  final Radius bottomRadius;
  final VoidCallback onOpenProject;
  final VoidCallback onToggleExpand;

  const _ProjectHeader({
    required this.coverColor,
    required this.coverImage,
    required this.isExpanded,
    required this.isEditing,
    required this.titleController,
    required this.titleFocusNode,
    required this.bottomRadius,
    required this.onOpenProject,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(16),
          bottom: bottomRadius,
        ),
        border: Border(
          bottom: BorderSide(
            color: isExpanded
                ? Colors.white.withValues(alpha: 0.22)
                : Colors.transparent,
            width: 0.7,
          ),
        ),
      ),
      child: SizedBox(
        height: 60,
        child: Stack(
          children: [
            Positioned.fill(
              child: ProjectCoverFill(
                color: coverColor,
                imageBytes: coverImage.bytes,
                imageWidth: coverImage.width,
                imageHeight: coverImage.height,
                imageScale: coverImage.scale,
                imageOffsetX: coverImage.offsetX,
                imageOffsetY: coverImage.offsetY,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(16),
                  bottom: bottomRadius,
                ),
              ),
            ),
            Positioned.fill(
              right: 52,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEditing ? null : onOpenProject,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50, right: 18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: titleController,
                        focusNode: titleFocusNode,
                        enabled: isEditing,
                        maxLines: 1,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          color: isExpanded
                              ? const Color(0xFFF9F6FA)
                              : const Color(0xFFF7F4F8),
                          fontSize: 17.5,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.58),
                              blurRadius: 14,
                              offset: const Offset(0, 3),
                            ),
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.32),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        cursorColor: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 26,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(16),
                      bottom: Radius.circular(bottomRadius.x),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onToggleExpand,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: const _ExclusionIcon(
                        icon: Icons.keyboard_arrow_down_rounded,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExclusionIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const _ExclusionIcon({required this.icon, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ExclusionIconPainter(icon: icon, size: size),
      ),
    );
  }
}

class _ExclusionIconPainter extends CustomPainter {
  final IconData icon;
  final double size;

  const _ExclusionIconPainter({required this.icon, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    TextPainter buildPainter(Color color) {
      return TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            inherit: false,
            color: color,
            fontSize: size,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
          ),
        ),
      )..layout();
    }

    final outlinePainter = buildPainter(Colors.black.withValues(alpha: 0.22));
    final painter = buildPainter(Colors.white);
    final offset = Offset(
      (canvasSize.width - painter.width) / 2,
      (canvasSize.height - painter.height) / 2,
    );

    for (final delta in const <Offset>[
      Offset(-0.6, 0),
      Offset(0.6, 0),
      Offset(0, -0.6),
      Offset(0, 0.6),
    ]) {
      outlinePainter.paint(canvas, offset + delta);
    }

    canvas.saveLayer(
      Offset.zero & canvasSize,
      Paint()..blendMode = BlendMode.exclusion,
    );
    painter.paint(canvas, offset);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ExclusionIconPainter oldDelegate) {
    return oldDelegate.icon != icon || oldDelegate.size != size;
  }
}
