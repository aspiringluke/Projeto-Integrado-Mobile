import 'package:flutter/material.dart';

class NotesSubPage extends StatelessWidget {
  const NotesSubPage({super.key});

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
