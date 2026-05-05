import 'package:flutter/material.dart';

class DiagramsSubPage extends StatelessWidget {
  const DiagramsSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _DiagramGroupCard(
          title: "Mapa da história",
          subtitle: "Linha do tempo dos eventos",
        ),
        _DiagramGroupCard(
          title: "Relações de personagens",
          subtitle: "Conflitos, alianças e segredos",
        ),
        _DiagramGroupCard(
          title: "Estrutura por atos",
          subtitle: "Setup, confronto e resolução",
        ),
        _DiagramGroupCard(
          title: "Fluxo de capítulos",
          subtitle: "Objetivo, obstáculo e gancho",
        ),
      ],
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
                  color: Color(0x26DF6EB8),
                ),
                SizedBox(width: 8),
                _DiagramChip(
                  label: "Fluxos",
                  color: Color(0x298B7D8B),
                ),
                Spacer(),
                Icon(Icons.open_in_full_rounded, color: Color(0xFF7B6E77)),
              ],
            ),
          ],
        ),
      ),
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
