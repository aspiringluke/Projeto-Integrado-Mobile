import 'package:flutter/material.dart';

import '../widgets/ideas_toggle_button.dart';

enum IdeasView { notes, diagrams }

class IdeasContent extends StatefulWidget {
  const IdeasContent({super.key});

  @override
  State<IdeasContent> createState() => _IdeasContentState();
}

class _IdeasContentState extends State<IdeasContent> {
  IdeasView _activeView = IdeasView.notes;

  @override
  Widget build(BuildContext context) {
    final isNotes = _activeView == IdeasView.notes;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: IdeasToggleButton(
                label: "Notas",
                isActive: isNotes,
                onTap: () => setState(() => _activeView = IdeasView.notes),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: IdeasToggleButton(
                label: "Diagramas",
                isActive: !isNotes,
                onTap: () => setState(() => _activeView = IdeasView.diagrams),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            isNotes ? "Notas recentes" : "Grupos de diagramas",
            key: ValueKey(_activeView),
            style: const TextStyle(
              color: Color(0xFF5D535A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _activeView == IdeasView.notes
              ? const _NotesSubPage(key: ValueKey(IdeasView.notes))
              : const _DiagramsSubPage(key: ValueKey(IdeasView.diagrams)),
        ),
      ],
    );
  }
}

class _NotesSubPage extends StatelessWidget {
  const _NotesSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _FolderCard(title: "Universo e ambientação"),
        _FolderCard(title: "Personagens e arcos"),
        _IdeaCard(title: "Conflito central da trama"),
        _IdeaCard(title: "Virada do ato 1"),
        _IdeaCard(title: "Motivação da protagonista"),
        _IdeaCard(title: "Cenário da cena de abertura"),
        _IdeaCard(title: "Diálogos-chave do capítulo 3"),
        _IdeaCard(title: "Final alternativo"),
      ],
    );
  }
}

class _DiagramsSubPage extends StatelessWidget {
  const _DiagramsSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _DiagramGroupCard(title: "Mapa da história", subtitle: "Linha do tempo dos eventos"),
        _DiagramGroupCard(title: "Relações de personagens", subtitle: "Conflitos, alianças e segredos"),
        _DiagramGroupCard(title: "Estrutura por atos", subtitle: "Setup, confronto e resolução"),
        _DiagramGroupCard(title: "Fluxo de capítulos", subtitle: "Objetivo, obstáculo e gancho"),
      ],
    );
  }
}

class _FolderCard extends StatelessWidget {
  final String title;

  const _FolderCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _IdeasSurfaceCard(
        height: 68,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFDF6EB8).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.folder_outlined,
                color: Color(0xFF8C5B79),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF342F33),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF8D7E88)),
          ],
        ),
      ),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  final String title;

  const _IdeaCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _IdeasSurfaceCard(
        height: 68,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF8B7D8B).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.sticky_note_2_outlined,
                color: Color(0xFF5C4F5C),
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF342F33),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF8D7E88),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagramGroupCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _DiagramGroupCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.75),
              const Color(0xFFF3DFEB).withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF3B3238),
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF6A6167),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                _DiagramChip(
                  label: "Nós",
                  color: const Color(0xFFDF6EB8).withValues(alpha: 0.15),
                ),
                const SizedBox(width: 8),
                _DiagramChip(
                  label: "Fluxos",
                  color: const Color(0xFF8B7D8B).withValues(alpha: 0.16),
                ),
                const Spacer(),
                const Icon(Icons.open_in_full_rounded, color: Color(0xFF7B6E77)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IdeasSurfaceCard extends StatelessWidget {
  final double height;
  final Widget child;

  const _IdeasSurfaceCard({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DiagramChip extends StatelessWidget {
  final String label;
  final Color color;

  const _DiagramChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4A3F47),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
