part of '../notes_dialogs.dart';

class _DialogActionButton extends StatelessWidget {
  final String label;
  final Color tint;
  final Color textColor;
  final VoidCallback onTap;

  const _DialogActionButton({
    required this.label,
    required this.tint,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint.withValues(alpha: 0.98),
                tint.withValues(alpha: 0.84),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: tint.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final bool confirmRequiresHold;
  final Widget? body;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    this.confirmRequiresHold = false,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    return NotesGlassCard(
      elevated: true,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kNotesText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: kNotesMutedText, height: 1.35),
          ),
          if (body != null) ...[const SizedBox(height: 14), body!],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DialogActionButton(
                  label: 'Cancelar',
                  tint: Colors.white,
                  textColor: kNotesPlum,
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: confirmRequiresHold
                    ? _HoldToConfirmButton(
                        label: confirmLabel,
                        tint: confirmColor,
                        textColor: Colors.white,
                        onConfirmed: () => Navigator.of(context).pop(true),
                      )
                    : _DialogActionButton(
                        label: confirmLabel,
                        tint: confirmColor,
                        textColor: Colors.white,
                        onTap: () => Navigator.of(context).pop(true),
                      ),
              ),
            ],
          ),
          if (confirmRequiresHold) ...[
            const SizedBox(height: 10),
            Text(
              'Segure o botão "$confirmLabel" por 2 segundos para confirmar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kNotesMutedText.withValues(alpha: 0.88),
                fontSize: 12,
                height: 1.25,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeleteMetricsSummary extends StatelessWidget {
  final ContentStats stats;

  const _DeleteMetricsSummary({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        _DeleteSummaryChip(
          icon: Icons.short_text_rounded,
          label: ptBrCount(
            stats.words,
            singular: 'palavra',
            plural: 'palavras',
            formatNumber: formatCompactCount,
          ),
          tint: const Color(0xFF7A5B86),
        ),
        _DeleteSummaryChip(
          icon: Icons.onetwothree_rounded,
          label: ptBrCount(
            stats.characters,
            singular: 'caractere',
            plural: 'caracteres',
            formatNumber: formatCompactCount,
          ),
          tint: const Color(0xFFB05C8D),
        ),
        _DeleteSummaryChip(
          icon: Icons.alternate_email_rounded,
          label: ptBrCount(
            stats.mentions,
            singular: 'menção',
            plural: 'menções',
            formatNumber: formatCompactCount,
          ),
          tint: const Color(0xFFDA6A9E),
        ),
      ],
    );
  }
}

class _DeleteSummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color tint;

  const _DeleteSummaryChip({
    required this.icon,
    required this.label,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: tint),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: tint,
              fontSize: 11.1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoldToConfirmButton extends StatefulWidget {
  final String label;
  final Color tint;
  final Color textColor;
  final VoidCallback onConfirmed;

  const _HoldToConfirmButton({
    required this.label,
    required this.tint,
    required this.textColor,
    required this.onConfirmed,
  });

  @override
  State<_HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<_HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  static const Duration _holdDuration = Duration(seconds: 2);
  late final AnimationController _controller;
  bool _isHolding = false;
  bool _hasConfirmed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _holdDuration)
      ..addStatusListener(_handleStatusChanged);
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed || _hasConfirmed) {
      return;
    }

    _hasConfirmed = true;
    widget.onConfirmed();
  }

  void _startHold() {
    if (_controller.isAnimating || _hasConfirmed) return;

    setState(() {
      _isHolding = true;
    });

    _controller.forward(from: 0);
  }

  void _cancelHold() {
    if (_hasConfirmed) return;

    if (_controller.isAnimating || _controller.value > 0) {
      _controller.stop();
      _controller.value = 0;
    }

    if (!mounted || !_isHolding) return;

    setState(() {
      _isHolding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _startHold(),
      onPointerUp: (_) => _cancelHold(),
      onPointerCancel: (_) => _cancelHold(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = _controller.value.clamp(0.0, 1.0);
          final fillTint = _isHolding ? const Color(0xFFF16A9A) : widget.tint;
          final fillGlow = Color.alphaBlend(
            const Color(0xFFFFC3D7).withValues(alpha: 0.42),
            fillTint,
          );
          final contentColor = _isHolding
              ? Colors.white.withValues(alpha: 0.98)
              : widget.textColor;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: null,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.tint.withValues(alpha: 0.98),
                      widget.tint.withValues(alpha: 0.84),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: fillGlow.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  fillGlow.withValues(alpha: 0.98),
                                  fillTint.withValues(alpha: 0.88),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 17,
                            color: contentColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.label,
                            style: TextStyle(
                              color: contentColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MoveTargetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final bool enabled;
  final VoidCallback? onTap;

  const _MoveTargetTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.44,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: color.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.16),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: kNotesText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: kNotesMutedText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _folderMetadataSummary(NoteMetadata metadata) {
  if (metadata.tagGroups.isNotEmpty) {
    return ptBrCount(
      metadata.tagGroups.length,
      singular: 'grupo',
      plural: 'grupos',
    );
  }

  return 'Sem tags';
}

String _folderTagsSummary(NoteMetadata metadata) {
  if (metadata.tagGroups.isEmpty) {
    return 'Nenhuma classificação criada';
  }

  final tagCount = metadata.tagGroups.fold<int>(
    0,
    (count, group) => count + group.tags.length,
  );

  return ptBrCountSummary([
    ptBrCount(metadata.tagGroups.length, singular: 'grupo', plural: 'grupos'),
    if (tagCount > 0) ptBrCount(tagCount, singular: 'tag', plural: 'tags'),
  ]);
}
