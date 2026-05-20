part of '../notes_sub_page.dart';

class _NotesBreadcrumb extends StatelessWidget {
  final List<Folder> segments;
  final VoidCallback onHomeTap;
  final ValueChanged<Folder> onFolderTap;

  const _NotesBreadcrumb({
    required this.segments,
    required this.onHomeTap,
    required this.onFolderTap,
  });

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      'Notas',
      ...segments
          .map((folder) => folder.title.trim())
          .where((title) => title.isNotEmpty),
    ];
    final currentIndex = labels.length - 1;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var index = 0; index < labels.length; index += 1) ...[
          if (index > 0)
            const Text(
              '/',
              style: TextStyle(
                color: kNotesMutedText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          _BreadcrumbLabel(
            label: labels[index],
            isCurrent: index == currentIndex,
            onTap: index == 0
                ? onHomeTap
                : () => onFolderTap(segments[index - 1]),
          ),
        ],
      ],
    );
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

    return Material(
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
    );
  }
}
