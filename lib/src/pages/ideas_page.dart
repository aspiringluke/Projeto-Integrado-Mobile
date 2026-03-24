import 'package:flutter/material.dart';

import '../widgets/custom_nav_bar.dart';
import '../widgets/funcoes_busca.dart';
import '../widgets/main_header.dart';

class IdeasPage extends StatelessWidget {
  const IdeasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      bottomNavigationBar: CustomNavBar(activeTab: NavTab.ideas, onTabSelected: (_) {}),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFF4B8D8),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF9EEF6),
                    const Color(0xFFFDF2F8),
                    const Color(0xFFF6E8F1),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -120,
            top: 180,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                width: 420,
                height: 60,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              const MainHeader(),
              const SliverToBoxAdapter(
                child: FuncoesBusca(),
              ),
              const SliverToBoxAdapter(
                child: _IdeasSwitcher(),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    const [
                      _FolderCard(title: "Pasta"),
                      _FolderCard(title: "Pasta"),
                      _IdeaCard(title: "Ideia"),
                      _IdeaCard(title: "Ideia"),
                      _IdeaCard(title: "Ideia"),
                      _IdeaCard(title: "Ideia"),
                      _IdeaCard(title: "Ideia"),
                      _IdeaCard(title: "Ideia"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IdeasSwitcher extends StatelessWidget {
  const _IdeasSwitcher();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _TopToggleButton(
              label: "Notas",
              isActive: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TopToggleButton(
              label: "Diagramas",
              isActive: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;

  const _TopToggleButton({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDAD8DC) : const Color(0xFFA8A6AB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black87 : Colors.black45,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final String title;

  const _FolderCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFFCBCACD),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.folder, color: Colors.black45),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 28,
                fontWeight: FontWeight.w400,
              ),
            ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFFCBCACD),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 32,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black38, size: 28),
          ],
        ),
      ),
    );
  }
}
