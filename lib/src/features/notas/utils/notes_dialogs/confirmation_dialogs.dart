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
            _HoldInstructionBox(tint: confirmColor),
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

class _DeleteCharacterConfirmationDialog extends StatefulWidget {
  final String characterName;
  final int linkedNoteCount;

  const _DeleteCharacterConfirmationDialog({
    required this.characterName,
    required this.linkedNoteCount,
  });

  @override
  State<_DeleteCharacterConfirmationDialog> createState() =>
      _DeleteCharacterConfirmationDialogState();
}

class _DeleteCharacterConfirmationDialogState
    extends State<_DeleteCharacterConfirmationDialog> {
  CharacterLinkedNotesDeletionAction _linkedNotesAction =
      CharacterLinkedNotesDeletionAction.keepLinkedNotes;

  @override
  Widget build(BuildContext context) {
    final hasLinkedNotes = widget.linkedNoteCount > 0;

    return NotesGlassCard(
      elevated: true,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Excluir personagem',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kNotesText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasLinkedNotes
                ? 'Isso vai excluir "${widget.characterName}". Escolha o que fazer com as notas vinculadas.'
                : 'Isso vai excluir "${widget.characterName}".',
            textAlign: TextAlign.center,
            style: const TextStyle(color: kNotesMutedText, height: 1.35),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _DeleteSummaryChip(
                icon: Icons.link_rounded,
                label: ptBrCount(
                  widget.linkedNoteCount,
                  singular: 'nota vinculada',
                  plural: 'notas vinculadas',
                ),
                tint: const Color(0xFFB05C8D),
              ),
            ],
          ),
          if (hasLinkedNotes) ...[
            const SizedBox(height: 16),
            _DeleteActionTile(
              title: 'Guardar notas',
              subtitle:
                  'Mantém as notas e muda o vínculo para "Anteriormente vinculado à ${widget.characterName.trim()}".',
              icon: Icons.inventory_2_outlined,
              selected:
                  _linkedNotesAction ==
                  CharacterLinkedNotesDeletionAction.keepLinkedNotes,
              onTap: () => setState(
                () => _linkedNotesAction =
                    CharacterLinkedNotesDeletionAction.keepLinkedNotes,
              ),
            ),
            const SizedBox(height: 8),
            _DeleteActionTile(
              title: 'Apagar notas',
              subtitle:
                  'Exclui as notas vinculadas a este personagem junto com ele.',
              icon: Icons.delete_sweep_outlined,
              selected:
                  _linkedNotesAction ==
                  CharacterLinkedNotesDeletionAction.deleteLinkedNotes,
              onTap: () => setState(
                () => _linkedNotesAction =
                    CharacterLinkedNotesDeletionAction.deleteLinkedNotes,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DialogActionButton(
                  label: 'Cancelar',
                  tint: Colors.white,
                  textColor: kNotesPlum,
                  onTap: () => Navigator.of(context).pop(null),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HoldToConfirmButton(
                  label: 'Excluir',
                  tint: const Color(0xFFE05E8A),
                  textColor: Colors.white,
                  onConfirmed: () =>
                      Navigator.of(context).pop(_linkedNotesAction),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _HoldInstructionBox(tint: Color(0xFFE05E8A)),
        ],
      ),
    );
  }
}

class _DeleteCharactersConfirmationDialog extends StatefulWidget {
  final int characterCount;
  final int linkedNoteCount;

  const _DeleteCharactersConfirmationDialog({
    required this.characterCount,
    required this.linkedNoteCount,
  });

  @override
  State<_DeleteCharactersConfirmationDialog> createState() =>
      _DeleteCharactersConfirmationDialogState();
}

class _DeleteCharactersConfirmationDialogState
    extends State<_DeleteCharactersConfirmationDialog> {
  CharacterLinkedNotesDeletionAction _linkedNotesAction =
      CharacterLinkedNotesDeletionAction.keepLinkedNotes;

  @override
  Widget build(BuildContext context) {
    final hasLinkedNotes = widget.linkedNoteCount > 0;

    return NotesGlassCard(
      elevated: true,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Excluir personagens',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kNotesText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasLinkedNotes
                ? 'Isso vai excluir ${widget.characterCount} personagem(ns). Escolha o que fazer com as notas vinculadas.'
                : 'Isso vai excluir ${widget.characterCount} personagem(ns).',
            textAlign: TextAlign.center,
            style: const TextStyle(color: kNotesMutedText, height: 1.35),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _DeleteSummaryChip(
                icon: Icons.person_outline_rounded,
                label: ptBrCount(
                  widget.characterCount,
                  singular: 'personagem',
                  plural: 'personagens',
                ),
                tint: const Color(0xFF7A5B86),
              ),
              _DeleteSummaryChip(
                icon: Icons.link_rounded,
                label: ptBrCount(
                  widget.linkedNoteCount,
                  singular: 'nota vinculada',
                  plural: 'notas vinculadas',
                ),
                tint: const Color(0xFFB05C8D),
              ),
            ],
          ),
          if (hasLinkedNotes) ...[
            const SizedBox(height: 16),
            _DeleteActionTile(
              title: 'Guardar notas',
              subtitle:
                  'Mantém as notas e marca cada uma como anteriormente vinculada ao personagem removido.',
              icon: Icons.inventory_2_outlined,
              selected:
                  _linkedNotesAction ==
                  CharacterLinkedNotesDeletionAction.keepLinkedNotes,
              onTap: () => setState(
                () => _linkedNotesAction =
                    CharacterLinkedNotesDeletionAction.keepLinkedNotes,
              ),
            ),
            const SizedBox(height: 8),
            _DeleteActionTile(
              title: 'Apagar notas',
              subtitle:
                  'Exclui as notas vinculadas aos personagens selecionados.',
              icon: Icons.delete_sweep_outlined,
              selected:
                  _linkedNotesAction ==
                  CharacterLinkedNotesDeletionAction.deleteLinkedNotes,
              onTap: () => setState(
                () => _linkedNotesAction =
                    CharacterLinkedNotesDeletionAction.deleteLinkedNotes,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DialogActionButton(
                  label: 'Cancelar',
                  tint: Colors.white,
                  textColor: kNotesPlum,
                  onTap: () => Navigator.of(context).pop(null),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HoldToConfirmButton(
                  label: 'Excluir',
                  tint: const Color(0xFFE05E8A),
                  textColor: Colors.white,
                  onConfirmed: () =>
                      Navigator.of(context).pop(_linkedNotesAction),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _HoldInstructionBox(tint: Color(0xFFE05E8A)),
        ],
      ),
    );
  }
}

class _DeleteProjectConfirmationDialog extends StatefulWidget {
  final String projectTitle;
  final int characterCount;
  final int linkedNoteCount;
  final int folderNoteCount;
  final bool hasProjectFolder;

  const _DeleteProjectConfirmationDialog({
    required this.projectTitle,
    required this.characterCount,
    required this.linkedNoteCount,
    required this.folderNoteCount,
    required this.hasProjectFolder,
  });

  @override
  State<_DeleteProjectConfirmationDialog> createState() =>
      _DeleteProjectConfirmationDialogState();
}

class _DeleteProjectConfirmationDialogState
    extends State<_DeleteProjectConfirmationDialog> {
  ProjectFolderDeletionAction _folderAction =
      ProjectFolderDeletionAction.keepFolder;

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
          const Text(
            'Excluir projeto',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kNotesText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Isso vai excluir "${widget.projectTitle}" e ${widget.characterCount} personagem(ns).',
            textAlign: TextAlign.center,
            style: const TextStyle(color: kNotesMutedText, height: 1.35),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _DeleteSummaryChip(
                icon: Icons.person_outline_rounded,
                label: ptBrCount(
                  widget.characterCount,
                  singular: 'personagem',
                  plural: 'personagens',
                ),
                tint: const Color(0xFF7A5B86),
              ),
              _DeleteSummaryChip(
                icon: Icons.link_rounded,
                label: ptBrCount(
                  widget.linkedNoteCount,
                  singular: 'nota vinculada',
                  plural: 'notas vinculadas',
                ),
                tint: const Color(0xFFB05C8D),
              ),
              if (widget.hasProjectFolder)
                _DeleteSummaryChip(
                  icon: Icons.folder_outlined,
                  label: ptBrCount(
                    widget.folderNoteCount,
                    singular: 'nota na pasta',
                    plural: 'notas na pasta',
                  ),
                  tint: const Color(0xFFDA6A9E),
                ),
            ],
          ),
          if (widget.hasProjectFolder) ...[
            const SizedBox(height: 16),
            _DeleteActionTile(
              title: 'Manter pasta',
              subtitle:
                  'Remove a proteção da pasta. Ela continua existindo e pode ser apagada depois.',
              icon: Icons.inventory_2_outlined,
              selected: _folderAction == ProjectFolderDeletionAction.keepFolder,
              onTap: () => setState(
                () => _folderAction = ProjectFolderDeletionAction.keepFolder,
              ),
            ),
            const SizedBox(height: 8),
            _DeleteActionTile(
              title: 'Apagar pasta',
              subtitle:
                  'Exclui a pasta do projeto inteira, incluindo notas e subpastas.',
              icon: Icons.folder_delete_outlined,
              selected:
                  _folderAction == ProjectFolderDeletionAction.deleteFolder,
              onTap: () => setState(
                () => _folderAction = ProjectFolderDeletionAction.deleteFolder,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DialogActionButton(
                  label: 'Cancelar',
                  tint: Colors.white,
                  textColor: kNotesPlum,
                  onTap: () => Navigator.of(context).pop(null),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HoldToConfirmButton(
                  label: 'Excluir',
                  tint: const Color(0xFFE05E8A),
                  textColor: Colors.white,
                  onConfirmed: () => Navigator.of(context).pop(_folderAction),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _HoldInstructionBox(tint: Color(0xFFE05E8A)),
        ],
      ),
    );
  }
}

class _DeleteProjectsConfirmationDialog extends StatefulWidget {
  final int projectCount;
  final int characterCount;
  final int linkedNoteCount;
  final int folderNoteCount;
  final int projectFolderCount;

  const _DeleteProjectsConfirmationDialog({
    required this.projectCount,
    required this.characterCount,
    required this.linkedNoteCount,
    required this.folderNoteCount,
    required this.projectFolderCount,
  });

  @override
  State<_DeleteProjectsConfirmationDialog> createState() =>
      _DeleteProjectsConfirmationDialogState();
}

class _DeleteProjectsConfirmationDialogState
    extends State<_DeleteProjectsConfirmationDialog> {
  ProjectFolderDeletionAction _folderAction =
      ProjectFolderDeletionAction.keepFolder;

  @override
  Widget build(BuildContext context) {
    final hasProjectFolders = widget.projectFolderCount > 0;

    return NotesGlassCard(
      elevated: true,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Excluir projetos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kNotesText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Isso vai excluir ${widget.projectCount} projeto(s) e ${widget.characterCount} personagem(ns).',
            textAlign: TextAlign.center,
            style: const TextStyle(color: kNotesMutedText, height: 1.35),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _DeleteSummaryChip(
                icon: Icons.folder_special_outlined,
                label: ptBrCount(
                  widget.projectCount,
                  singular: 'projeto',
                  plural: 'projetos',
                ),
                tint: const Color(0xFF7A5B86),
              ),
              _DeleteSummaryChip(
                icon: Icons.person_outline_rounded,
                label: ptBrCount(
                  widget.characterCount,
                  singular: 'personagem',
                  plural: 'personagens',
                ),
                tint: const Color(0xFF9A5D8E),
              ),
              _DeleteSummaryChip(
                icon: Icons.link_rounded,
                label: ptBrCount(
                  widget.linkedNoteCount,
                  singular: 'nota vinculada',
                  plural: 'notas vinculadas',
                ),
                tint: const Color(0xFFB05C8D),
              ),
              if (hasProjectFolders)
                _DeleteSummaryChip(
                  icon: Icons.folder_outlined,
                  label: ptBrCount(
                    widget.folderNoteCount,
                    singular: 'nota em pasta',
                    plural: 'notas em pastas',
                  ),
                  tint: const Color(0xFFDA6A9E),
                ),
            ],
          ),
          if (hasProjectFolders) ...[
            const SizedBox(height: 16),
            _DeleteActionTile(
              title: 'Manter pastas',
              subtitle:
                  'Remove a proteção das pastas dos projetos. Elas continuam existindo e podem ser apagadas depois.',
              icon: Icons.inventory_2_outlined,
              selected: _folderAction == ProjectFolderDeletionAction.keepFolder,
              onTap: () => setState(
                () => _folderAction = ProjectFolderDeletionAction.keepFolder,
              ),
            ),
            const SizedBox(height: 8),
            _DeleteActionTile(
              title: 'Apagar pastas',
              subtitle:
                  'Exclui as pastas dos projetos, incluindo notas e subpastas.',
              icon: Icons.folder_delete_outlined,
              selected:
                  _folderAction == ProjectFolderDeletionAction.deleteFolder,
              onTap: () => setState(
                () => _folderAction = ProjectFolderDeletionAction.deleteFolder,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DialogActionButton(
                  label: 'Cancelar',
                  tint: Colors.white,
                  textColor: kNotesPlum,
                  onTap: () => Navigator.of(context).pop(null),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HoldToConfirmButton(
                  label: 'Excluir',
                  tint: const Color(0xFFE05E8A),
                  textColor: Colors.white,
                  onConfirmed: () => Navigator.of(context).pop(_folderAction),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _HoldInstructionBox(tint: Color(0xFFE05E8A)),
        ],
      ),
    );
  }
}

class _DeleteActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _DeleteActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: (selected ? kNotesPink : kNotesPlum).withValues(
              alpha: selected ? 0.12 : 0.06,
            ),
            border: Border.all(
              color: selected
                  ? kNotesPink.withValues(alpha: 0.34)
                  : Colors.white.withValues(alpha: 0.8),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? kNotesPink : kNotesPlum, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: kNotesText,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: kNotesMutedText,
                        fontSize: 11.5,
                        height: 1.22,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? kNotesPink : kNotesMutedText,
                size: 19,
              ),
            ],
          ),
        ),
      ),
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

class _HoldInstructionBox extends StatelessWidget {
  final Color tint;

  const _HoldInstructionBox({required this.tint});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.48),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: tint.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app_rounded,
              color: tint.withValues(alpha: 0.72),
              size: 14,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Segure o botão apagar por 2 segundos para confirmar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kNotesMutedText.withValues(alpha: 0.9),
                  fontSize: 11.7,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
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
          final progress = _controller.value.clamp(0.0, 1.0).toDouble();
          final fillTint = Color.alphaBlend(
            const Color(0xFFFFBED3).withValues(alpha: 0.18),
            widget.tint,
          );
          final textBlend = (progress * 2.2).clamp(0.0, 1.0).toDouble();
          final contentColor =
              Color.lerp(widget.tint, widget.textColor, textBlend) ??
              widget.tint;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: null,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: 0.96),
                  border: Border.all(
                    color: widget.tint.withValues(alpha: 0.56),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.tint.withValues(alpha: 0.12),
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
                                  fillTint.withValues(alpha: 0.82),
                                  widget.tint.withValues(alpha: 0.9),
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
