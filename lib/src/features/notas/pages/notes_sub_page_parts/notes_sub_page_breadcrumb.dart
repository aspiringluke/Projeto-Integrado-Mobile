part of '../notes_sub_page.dart';

class _NotesBreadcrumb extends StatefulWidget {
  final List<Folder> segments;
  final VoidCallback onHomeTap;
  final ValueChanged<Folder> onFolderTap;

  const _NotesBreadcrumb({
    required this.segments,
    required this.onHomeTap,
    required this.onFolderTap,
  });

  @override
  State<_NotesBreadcrumb> createState() => _NotesBreadcrumbState();
}

class _NotesBreadcrumbState extends State<_NotesBreadcrumb> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToCurrentSegment();
  }

  @override
  void didUpdateWidget(covariant _NotesBreadcrumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segments.length != widget.segments.length ||
        oldWidget.segments.lastOrNull?.id != widget.segments.lastOrNull?.id) {
      _scrollToCurrentSegment();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentSegment() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      'Notas',
      ...widget.segments
          .map((folder) => folder.title.trim())
          .where((title) => title.isNotEmpty),
    ];
    final currentIndex = labels.length - 1;

    return SizedBox(
      height: 30,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < labels.length; index += 1) ...[
                if (index > 0) ...[
                  const SizedBox(width: 4),
                  const Text(
                    '/',
                    style: TextStyle(
                      color: kNotesMutedText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                _BreadcrumbLabel(
                  label: labels[index],
                  isCurrent: index == currentIndex,
                  onTap: index == 0
                      ? widget.onHomeTap
                      : () => widget.onFolderTap(widget.segments[index - 1]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

extension<T> on List<T> {
  T? get lastOrNull {
    if (isEmpty) {
      return null;
    }

    return last;
  }
}

class _BreadcrumbLabel extends StatelessWidget {
  final String label;
  final bool isCurrent;
  final VoidCallback onTap;

  const _BreadcrumbLabel({
    required this.label,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isCurrent ? kNotesText : kNotesMutedText;
    final barWidth = isCurrent ? (label.length * 3.4).clamp(12.0, 26.0) : 0.0;
    final maxLabelWidth = MediaQuery.sizeOf(context).width * 0.52;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxLabelWidth.clamp(96.0, 220.0)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: baseColor,
                    fontSize: isCurrent ? 16 : 14.2,
                    height: 1.05,
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: 2,
                  width: barWidth,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? kNotesPink.withValues(alpha: 0.72)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
