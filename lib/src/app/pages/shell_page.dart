import 'dart:ui';

import 'package:flutter/material.dart';

import '../../features/projects/controllers/project_list_controller.dart';
import './idea_list_page.dart';
import '../../features/projects/pages/project_list_page.dart';
import '../../features/projects/widgets/create_project_dialog.dart';
import '../widgets/custom_nav_bar.dart';
import '../../shared/widgets/funcoes_busca.dart';
import '../../shared/widgets/buttons/glass_circle_button.dart';
import '../../shared/widgets/main_header.dart';
import '../../features/notas/widgets/notes_visuals.dart';

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
  final IdeasContentController _ideasContentController =
      IdeasContentController();
  bool _showIdeasQuickActions = false;

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
      _showIdeasQuickActions = false;
    });
  }

  Future<void> _onPrimaryActionPressed() async {
    if (_activeTab == NavTab.projects) {
      final draft = await showCreateProjectTextDialog(
        context,
        availableTags: _projectListController.availableTags,
      );
      if (!mounted || draft == null) return;

      await _projectListController.addProject(
        title: draft.title,
        synopsis: draft.synopsis,
        tags: draft.tags,
        coverColor: draft.coverColor,
        accentColor: draft.accentColor,
        coverImage: draft.coverImage,
      );
      return;
    }

    if (!_ideasContentController.isNotesView) return;

    setState(() {
      _showIdeasQuickActions = !_showIdeasQuickActions;
    });
  }

  Future<void> _onCreateNotePressed() async {
    await _ideasContentController.onCreateNoteRequested();
    if (!mounted) return;
    setState(() => _showIdeasQuickActions = false);
  }

  Future<void> _onCreateFolderPressed() async {
    await _ideasContentController.onCreateFolderRequested();
    if (!mounted) return;
    setState(() => _showIdeasQuickActions = false);
  }

  Widget _buildFloatingActionArea() {
    final showQuickActions =
        _activeTab == NavTab.ideas && _showIdeasQuickActions;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: showQuickActions
              ? Column(
                  key: const ValueKey('ideas_quick_actions'),
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _IdeasQuickActionButton(
                      icon: Icons.note_add_outlined,
                      label: 'Nova nota',
                      onTap: _onCreateNotePressed,
                    ),
                    const SizedBox(height: 10),
                    _IdeasQuickActionButton(
                      icon: Icons.create_new_folder_outlined,
                      label: 'Nova pasta',
                      onTap: _onCreateFolderPressed,
                    ),
                    const SizedBox(height: 12),
                  ],
                )
              : const SizedBox.shrink(
                  key: ValueKey('ideas_quick_actions_empty'),
                ),
        ),
        GlassCircleButton(
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
          child: Icon(
            showQuickActions ? Icons.close_rounded : Icons.add_rounded,
            color: const Color(0xFF171419),
            size: 31,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final showQuickActions =
        _activeTab == NavTab.ideas && _showIdeasQuickActions;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      bottomNavigationBar: CustomNavBar(
        activeTab: _activeTab,
        onTabSelected: _onTabSelected,
      ),
      floatingActionButton: _buildFloatingActionArea(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/FUNDO.png', fit: BoxFit.cover),
          ),
          if (showQuickActions)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() => _showIdeasQuickActions = false);
                },
                child: const SizedBox.expand(),
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
                  projectListController: _projectListController,
                  ideasContentController: _ideasContentController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IdeasQuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IdeasQuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.24),
                    kNotesPink.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.74)),
                boxShadow: [
                  BoxShadow(
                    color: kNotesPink.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: kNotesPlum),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: kNotesPlum,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedTabContent extends StatelessWidget {
  final NavTab activeTab;
  final bool toIdeas;
  final ProjectListController projectListController;
  final IdeasContentController ideasContentController;

  const _AnimatedTabContent({
    required this.activeTab,
    required this.toIdeas,
    required this.projectListController,
    required this.ideasContentController,
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
            : IdeasContent(controller: ideasContentController),
      ),
    );
  }
}
