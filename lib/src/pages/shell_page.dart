import 'package:flutter/material.dart';

import './ideas_page.dart';
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
            child: Image.asset(
              'assets/images/FUNDO.png',
              fit: BoxFit.cover,
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
            : const IdeasContent(),
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
