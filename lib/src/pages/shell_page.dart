import 'package:flutter/material.dart';

import '../widgets/custom_nav_bar.dart';
import '../widgets/funcoes_busca.dart';
import '../widgets/main_header.dart';
import '../widgets/project_card.dart';

class ShellPage extends StatefulWidget {
  final NavTab initialTab;

  const ShellPage({super.key, this.initialTab = NavTab.projects});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  late NavTab _activeTab;
  late bool _toIdeas;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    _toIdeas = _activeTab == NavTab.ideas;
  }

  void _onTabSelected(NavTab tab) {
    if (tab == _activeTab) return;

    setState(() {
      _toIdeas = _activeTab == NavTab.projects && tab == NavTab.ideas;
      _activeTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      bottomNavigationBar: CustomNavBar(
        activeTab: _activeTab,
        onTabSelected: _onTabSelected,
      ),
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
          Column(
            children: [
              const MainHeader(asSliver: false),
              const FuncoesBusca(),
              Expanded(
                child: _AnimatedTabContent(
                  activeTab: _activeTab,
                  toIdeas: _toIdeas,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedTabContent extends StatelessWidget {
  final NavTab activeTab;
  final bool toIdeas;

  const _AnimatedTabContent({required this.activeTab, required this.toIdeas});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ...previousChildren,
            // ignore: use_null_aware_elements
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final isIncoming = child.key == ValueKey(activeTab);
        final incomingOffset = toIdeas ? const Offset(1, 0) : const Offset(-1, 0);
        final outgoingOffset = toIdeas ? const Offset(-1, 0) : const Offset(1, 0);

        final slideAnimation = Tween<Offset>(
          begin: isIncoming ? incomingOffset : Offset.zero,
          end: isIncoming ? Offset.zero : outgoingOffset,
        ).animate(
          CurvedAnimation(
            parent: isIncoming ? animation : ReverseAnimation(animation),
            curve: Curves.easeInOutCubic,
          ),
        );

        final fadeAnimation = Tween<double>(
          begin: isIncoming ? 0.96 : 1,
          end: isIncoming ? 1 : 0.92,
        ).animate(
          CurvedAnimation(
            parent: isIncoming ? animation : ReverseAnimation(animation),
            curve: Curves.easeInOut,
          ),
        );

        return ClipRect(
          child: SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(activeTab),
        child: activeTab == NavTab.projects
            ? const _ProjectsContent()
            : const _IdeasContent(),
      ),
    );
  }
}

class _ProjectsContent extends StatelessWidget {
  const _ProjectsContent();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 4,
      itemBuilder: (context, index) {
        return ProjectCard(title: "Projeto ${index + 1}");
      },
    );
  }
}

class _IdeasContent extends StatelessWidget {
  const _IdeasContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: const [
        _IdeasSwitcher(),
        SizedBox(height: 12),
        _FolderCard(title: "Pasta"),
        _FolderCard(title: "Pasta"),
        _IdeaCard(title: "Ideia"),
        _IdeaCard(title: "Ideia"),
        _IdeaCard(title: "Ideia"),
        _IdeaCard(title: "Ideia"),
        _IdeaCard(title: "Ideia"),
        _IdeaCard(title: "Ideia"),
      ],
    );
  }
}

class _IdeasSwitcher extends StatelessWidget {
  const _IdeasSwitcher();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _TopToggleButton(label: "Notas", isActive: true)),
        SizedBox(width: 12),
        Expanded(child: _TopToggleButton(label: "Diagramas", isActive: false)),
      ],
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
