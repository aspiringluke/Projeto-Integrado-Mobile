import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

typedef SynopsisViewerBuilder =
    Widget Function(BuildContext context, String text, TextStyle style);

const String synopsisPlaceholderText =
    'Este é o campo de síntese. Uma boa síntese reúne o máximo de informações pertinentes no menor número possível de palavras, criando uma imagem mental precisa do assunto. Explicite o que for essencial e deixe o que for implícito surgir nas entrelinhas, pela escolha cuidadosa das palavras.';

class SynopsisScrollBox extends StatefulWidget {
  final ScrollController controller;
  final Widget child;
  final bool childIsScrollable;
  final double height;
  final EdgeInsetsGeometry contentPadding;

  const SynopsisScrollBox({
    super.key,
    required this.controller,
    required this.child,
    this.childIsScrollable = false,
    this.height = 92,
    this.contentPadding = const EdgeInsets.only(right: 10),
  });

  @override
  State<SynopsisScrollBox> createState() => _SynopsisScrollBoxState();
}

class _SynopsisScrollBoxState extends State<SynopsisScrollBox> {
  bool _refreshScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refreshScrollbar);
    _scheduleMetricsRefresh();
  }

  @override
  void didUpdateWidget(covariant SynopsisScrollBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refreshScrollbar);
      widget.controller.addListener(_refreshScrollbar);
      _scheduleMetricsRefresh();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refreshScrollbar);
    super.dispose();
  }

  void _refreshScrollbar() {
    if (!mounted) {
      return;
    }

    final schedulerPhase = SchedulerBinding.instance.schedulerPhase;
    final canRefreshImmediately =
        schedulerPhase == SchedulerPhase.idle ||
        schedulerPhase == SchedulerPhase.postFrameCallbacks;

    if (canRefreshImmediately) {
      setState(() {});
      return;
    }

    if (_refreshScheduled) {
      return;
    }

    _refreshScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _scheduleMetricsRefresh() {
    _refreshScrollbar();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveHeight = _resolveHeight(constraints);
        final scrollMetrics = _resolveMetrics(effectiveHeight);
        final scrollBehavior = const _SynopsisNoScrollbarBehavior().copyWith(
          scrollbars: false,
          overscroll: false,
        );
        final scrollableChild = NotificationListener<ScrollMetricsNotification>(
          onNotification: (_) {
            _refreshScrollbar();
            return false;
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (_) {
              _refreshScrollbar();
              return false;
            },
            child: ScrollConfiguration(
              behavior: scrollBehavior,
              child: widget.childIsScrollable
                  ? widget.child
                  : SingleChildScrollView(
                      controller: widget.controller,
                      physics: const BouncingScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: widget.child,
                      ),
                    ),
            ),
          ),
        );

        final content = Stack(
          children: [
            Padding(padding: widget.contentPadding, child: scrollableChild),
            if (scrollMetrics.isVisible)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: _SynopsisScrollIndicator(
                    height: effectiveHeight,
                    metrics: scrollMetrics,
                  ),
                ),
              ),
          ],
        );

        if (widget.height.isFinite) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: effectiveHeight),
            child: content,
          );
        }

        return SizedBox(height: effectiveHeight, child: content);
      },
    );
  }

  double _resolveHeight(BoxConstraints constraints) {
    if (widget.height.isFinite) {
      return math.max(0, widget.height);
    }

    if (constraints.maxHeight.isFinite) {
      return math.max(0, constraints.maxHeight);
    }

    return 0;
  }

  _SynopsisScrollMetrics _resolveMetrics(double effectiveHeight) {
    if (effectiveHeight <= 0) {
      return const _SynopsisScrollMetrics(
        isVisible: false,
        thumbExtent: 0,
        thumbOffset: 0,
      );
    }

    if (!widget.controller.hasClients) {
      return const _SynopsisScrollMetrics(
        isVisible: false,
        thumbExtent: 0,
        thumbOffset: 0,
      );
    }

    final position = widget.controller.position;
    final viewportExtent = position.viewportDimension <= 0
        ? effectiveHeight
        : position.viewportDimension;
    final maxScrollExtent = position.maxScrollExtent;

    if (maxScrollExtent <= 0) {
      return const _SynopsisScrollMetrics(
        isVisible: false,
        thumbExtent: 0,
        thumbOffset: 0,
      );
    }

    final totalContentExtent = viewportExtent + maxScrollExtent;
    final thumbExtent = math
        .max(24.0, effectiveHeight * (viewportExtent / totalContentExtent))
        .clamp(0.0, effectiveHeight)
        .toDouble();
    final availableOffset = math.max(0.0, effectiveHeight - thumbExtent);
    final scrollFraction = (position.pixels / maxScrollExtent).clamp(0.0, 1.0);

    return _SynopsisScrollMetrics(
      isVisible: true,
      thumbExtent: thumbExtent,
      thumbOffset: math.max(0.0, availableOffset * scrollFraction),
    );
  }
}

class _SynopsisNoScrollbarBehavior extends MaterialScrollBehavior {
  const _SynopsisNoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class _SynopsisScrollIndicator extends StatelessWidget {
  final double height;
  final _SynopsisScrollMetrics metrics;

  const _SynopsisScrollIndicator({required this.height, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final resolvedHeight = math.max(0.0, height);
    final thumbHeight = metrics.thumbExtent
        .clamp(math.min(16.0, resolvedHeight), resolvedHeight)
        .toDouble();
    final thumbOffset = metrics.thumbOffset
        .clamp(0.0, math.max(0.0, resolvedHeight - thumbHeight))
        .toDouble();

    return SizedBox(
      width: 3,
      height: resolvedHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFD8D3D8),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.only(top: thumbOffset),
            width: 3,
            height: thumbHeight,
            decoration: BoxDecoration(
              color: const Color(0xFFDF6EB8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}

class _SynopsisScrollMetrics {
  final bool isVisible;
  final double thumbExtent;
  final double thumbOffset;

  const _SynopsisScrollMetrics({
    required this.isVisible,
    required this.thumbExtent,
    required this.thumbOffset,
  });
}

class EditableSynopsisPanel extends StatefulWidget {
  final TextEditingController controller;
  final ScrollController scrollController;
  final bool isEditing;
  final String placeholderText;
  final ValueChanged<String>? onChanged;
  final TextStyle textStyle;
  final SynopsisViewerBuilder viewerBuilder;
  final double height;
  final EdgeInsetsGeometry panelPadding;
  final EdgeInsetsGeometry scrollPadding;
  final Color fillColor;
  final BorderRadiusGeometry borderRadius;
  final BoxBorder? border;
  final TextStyle? placeholderStyle;
  final double blurSigma;
  final Gradient? backgroundGradient;
  final Color? focusedBorderColor;
  final int minLines;
  final int? maxLines;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;

  const EditableSynopsisPanel({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.isEditing,
    required this.placeholderText,
    this.onChanged,
    required this.textStyle,
    required this.viewerBuilder,
    this.height = 92,
    this.panelPadding = const EdgeInsets.all(12),
    this.scrollPadding = const EdgeInsets.only(right: 10),
    this.fillColor = const Color(0xD1FFFFFF),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.border,
    this.placeholderStyle,
    this.blurSigma = 0,
    this.backgroundGradient,
    this.focusedBorderColor,
    this.minLines = 1,
    this.maxLines,
    this.keyboardType = TextInputType.multiline,
    this.textInputAction,
  });

  @override
  State<EditableSynopsisPanel> createState() => _EditableSynopsisPanelState();
}

class _EditableSynopsisPanelState extends State<EditableSynopsisPanel> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant EditableSynopsisPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isEditing && widget.isEditing) {
      _focusNode.requestFocus();
    } else if (oldWidget.isEditing && !widget.isEditing) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final effectivePlaceholderStyle =
        widget.placeholderStyle ??
        widget.textStyle.copyWith(
          color: const Color(0xFF8A828C),
          fontStyle: FontStyle.italic,
        );
    final isEmpty = widget.controller.text.trim().isEmpty;
    final isFocused = _focusNode.hasFocus;
    final focusedBorderColor =
        widget.focusedBorderColor ?? const Color(0xFFDF6EB8);

    final content = Container(
      padding: widget.panelPadding,
      decoration: BoxDecoration(
        color: widget.fillColor,
        gradient: widget.backgroundGradient,
        borderRadius: widget.borderRadius,
        border: isFocused
            ? Border.all(color: focusedBorderColor, width: 1.1)
            : widget.border ??
                  Border.all(
                    color: Colors.white.withValues(alpha: 0.74),
                    width: 1.0,
                  ),
      ),
      child: SynopsisScrollBox(
        controller: widget.scrollController,
        childIsScrollable: widget.isEditing,
        height: widget.height,
        contentPadding: widget.scrollPadding,
        child: widget.isEditing
            ? TextField(
                focusNode: _focusNode,
                controller: widget.controller,
                onChanged: widget.onChanged,
                scrollController: widget.scrollController,
                scrollPhysics: const ClampingScrollPhysics(),
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                textAlignVertical: TextAlignVertical.top,
                scrollPadding: EdgeInsets.zero,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: widget.placeholderText,
                  hintMaxLines: null,
                  hintStyle: effectivePlaceholderStyle,
                ),
                style: widget.textStyle,
              )
            : isEmpty
            ? Text(widget.placeholderText, style: effectivePlaceholderStyle)
            : widget.viewerBuilder(
                context,
                widget.controller.text,
                widget.textStyle,
              ),
      ),
    );

    final animatedContent = AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: const Cubic(0.22, 1, 0.36, 1),
      alignment: Alignment.topCenter,
      child: widget.blurSigma <= 0
          ? content
          : ClipRRect(
              borderRadius: widget.borderRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blurSigma,
                  sigmaY: widget.blurSigma,
                ),
                child: content,
              ),
            ),
    );

    return animatedContent;
  }
}
