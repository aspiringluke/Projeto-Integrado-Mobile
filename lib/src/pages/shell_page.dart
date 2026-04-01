import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './ideas_page.dart';
import '../widgets/custom_nav_bar.dart';
import '../widgets/funcoes_busca.dart';
import '../widgets/glass_circle_button.dart';
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
      floatingActionButton: GlassCircleButton(
        diameter: 56,
        onTap: () {},
        blurSigma: 10,
        fillColor: const Color(0xFFF2D5E3).withValues(alpha: 0.58),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.88),
            const Color(0xFFF1D1E2).withValues(alpha: 0.92),
            const Color(0xFFE9B8D4).withValues(alpha: 0.98),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderColor: Colors.white.withValues(alpha: 0.92),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDF6EB8).withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        child: const Icon(
          Icons.add_rounded,
          color: Color(0xFF171419),
          size: 31,
        ),
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
      duration: const Duration(milliseconds: 250),
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
        final directionAwareAnimation = isIncoming
            ? animation
            : ReverseAnimation(animation);
        final curved = CurvedAnimation(
          parent: directionAwareAnimation,
          curve: Curves.easeOutCubic,
        );
        final beginX = isIncoming
            ? (toIdeas ? 20.0 : -20.0)
            : 0.0;
        final endX = isIncoming
            ? 0.0
            : (toIdeas ? -20.0 : 20.0);

        final offsetAnimation = Tween<double>(
          begin: beginX,
          end: endX,
        ).animate(curved);
        final opacityAnimation = Tween<double>(
          begin: isIncoming ? 0.0 : 1.0,
          end: isIncoming ? 1.0 : 0.0,
        ).animate(curved);

        return AnimatedBuilder(
          animation: curved,
          child: child,
          builder: (context, builtChild) {
            return Opacity(
              opacity: opacityAnimation.value,
              child: Transform.translate(
                offset: Offset(offsetAnimation.value, 0),
                child: builtChild,
              ),
            );
          },
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

class _ProjectsContent extends StatefulWidget {
  const _ProjectsContent();

  @override
  State<_ProjectsContent> createState() => _ProjectsContentState();
}

class _ProjectsContentState extends State<_ProjectsContent> {
  late List<_ProjectListItem> _projects;

  bool get _isMobileReorderEnabled {
    if (kIsWeb) return false;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }

  @override
  void initState() {
    super.initState();
    _projects = List.generate(
      4,
      (index) => _ProjectListItem(
        title: 'Projeto ${index + 1}',
        unpinnedIndex: index,
      ),
    );
  }

  void _togglePinned(_ProjectListItem project) {
    setState(() {
      final currentIndex = _projects.indexOf(project);
      if (currentIndex == -1) return;

      if (!project.isPinned) {
        project.unpinnedIndex = _unpinnedIndexAt(currentIndex);
      }

      _projects.removeAt(currentIndex);
      project.isPinned = !project.isPinned;

      if (project.isPinned) {
        _projects.insert(0, project);
      } else {
        final pinnedCount = _projects.where((item) => item.isPinned).length;
        final unpinnedCount = _projects.length - pinnedCount;
        final targetUnpinnedIndex = project.unpinnedIndex.clamp(0, unpinnedCount) as int;
        _projects.insert(pinnedCount + targetUnpinnedIndex, project);
        _updateUnpinnedSlots();
      }
    });
  }

  int _unpinnedIndexAt(int listIndex) {
    var count = 0;

    for (var index = 0; index < listIndex; index += 1) {
      if (!_projects[index].isPinned) {
        count += 1;
      }
    }

    return count;
  }

  void _normalizePinnedGroups() {
    final pinned = _projects.where((item) => item.isPinned).toList(growable: false);
    final unpinned = _projects.where((item) => !item.isPinned).toList(growable: false);
    _projects = <_ProjectListItem>[
      ...pinned,
      ...unpinned,
    ];
  }

  void _updateUnpinnedSlots() {
    var unpinnedIndex = 0;

    for (final project in _projects) {
      if (!project.isPinned) {
        project.unpinnedIndex = unpinnedIndex;
        unpinnedIndex += 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildProjectCard(BuildContext context, int index) {
      final project = _projects[index];
      final card = RepaintBoundary(
        child: ProjectCard(
          title: project.title,
          isPinned: project.isPinned,
          onTogglePinned: () => _togglePinned(project),
        ),
      );

      if (_isMobileReorderEnabled) {
        return ReorderableDelayedDragStartListener(
          key: ValueKey(project.title),
          index: index,
          child: card,
        );
      }

      return KeyedSubtree(
        key: ValueKey(project.title),
        child: card,
      );
    }

    if (!_isMobileReorderEnabled) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _projects.length,
        itemBuilder: buildProjectCard,
      );
    }

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _projects.length,
      onReorder: (oldIndex, newIndex) {
        if (!_isMobileReorderEnabled) return;

        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        setState(() {
          final item = _projects.removeAt(oldIndex);
          _projects.insert(newIndex, item);
          _normalizePinnedGroups();
          _updateUnpinnedSlots();
        });
      },
      proxyDecorator: (widget, index, animation) {
        return Material(
          elevation: 12,
          color: Colors.transparent,
          shadowColor: Colors.pink.withOpacity(0.25),
          child: Opacity(
            opacity: 0.95,
            child: Transform.scale(
              scale: 1.02,
              child: widget,
            ),
          ),
        );
      },
      itemBuilder: buildProjectCard,
    );
  }
}

class _ProjectListItem {
  final String title;
  bool isPinned;
  int unpinnedIndex;

  _ProjectListItem({
    required this.title,
    this.isPinned = false,
    required this.unpinnedIndex,
  });
}
