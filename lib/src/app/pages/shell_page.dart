import 'package:flutter/material.dart';

import '../../features/ideas/pages/idea_list_page.dart';
import '../../features/projects/pages/project_list_page.dart';
import '../../features/projects/widgets/create_project_dialog.dart';
import '../widgets/custom_nav_bar.dart';
import '../../shared/widgets/funcoes_busca.dart';
import '../../shared/widgets/buttons/glass_circle_button.dart';
import '../../shared/widgets/main_header.dart';

class ShellPage extends StatefulWidget {
  final NavTab initialTab;

  const ShellPage({super.key, this.initialTab = NavTab.projects});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  late NavTab _activeTab;
  late bool _toIdeas;
  late final ProjectListController _projectListController;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    _toIdeas = _activeTab == NavTab.ideas;
    _projectListController = ProjectListController();
  }

  @override
  void dispose() {
    _projectListController.dispose();
    super.dispose();
  }

  void _onTabSelected(NavTab tab) {
    if (tab == _activeTab) return;

    setState(() {
      _toIdeas = _activeTab == NavTab.projects && tab == NavTab.ideas;
      _activeTab = tab;
    });
  }

  Future<void> _onPrimaryActionPressed() async {
    if (_activeTab != NavTab.projects) return;

    final draft = await showCreateProjectTextDialog(
      context,
      availableTags: _projectListController.availableTags,
    );
    if (!mounted || draft == null) return;

    _projectListController.addProject(
      title: draft.title,
      synopsis: draft.synopsis,
      tags: draft.tags,
      coverColor: draft.coverColor,
      accentColor: draft.accentColor,
      coverImageBytes: draft.coverImageBytes,
      coverImageWidth: draft.coverImageWidth,
      coverImageHeight: draft.coverImageHeight,
      coverImageScale: draft.coverImageScale,
      coverImageOffsetX: draft.coverImageOffsetX,
      coverImageOffsetY: draft.coverImageOffsetY,
      accentImageBytes: draft.accentImageBytes,
      accentImageWidth: draft.accentImageWidth,
      accentImageHeight: draft.accentImageHeight,
      accentImageScale: draft.accentImageScale,
      accentImageOffsetX: draft.accentImageOffsetX,
      accentImageOffsetY: draft.accentImageOffsetY,
    );
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
        onTap: _onPrimaryActionPressed,
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
            child: Image.asset('assets/images/FUNDO.png', fit: BoxFit.cover),
          ),
          Column(
            children: [
              const MainHeader(asSliver: false),
              const FuncoesBusca(),
              Expanded(
                child: _AnimatedTabContent(
                  activeTab: _activeTab,
                  toIdeas: _toIdeas,
                  projectListController: _projectListController,
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
  final ProjectListController projectListController;

  const _AnimatedTabContent({
    required this.activeTab,
    required this.toIdeas,
    required this.projectListController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          fit: StackFit.expand,
          children: [...previousChildren, ?currentChild],
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
        final beginX = isIncoming ? (toIdeas ? 20.0 : -20.0) : 0.0;
        final endX = isIncoming ? 0.0 : (toIdeas ? -20.0 : 20.0);

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
            ? ProjectListPage(controller: projectListController)
            : const IdeasContent(),
      ),
    );
  }
}
