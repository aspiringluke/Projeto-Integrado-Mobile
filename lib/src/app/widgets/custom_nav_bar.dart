import 'dart:ui';

import 'package:flutter/material.dart';

enum NavTab { projects, ideas }

class CustomNavBar extends StatelessWidget {
  final NavTab activeTab;
  final ValueChanged<NavTab> onTabSelected;

  const CustomNavBar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.34),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const indicatorWidth = 26.0;
                  final tabWidth = constraints.maxWidth / 2;
                  const projectsUnderlineOffset = 16.0;
                  const ideasUnderlineOffset = 12.0;
                  final indicatorLeft = (activeTab == NavTab.projects ? 0 : 1) * tabWidth +
                      ((tabWidth - indicatorWidth) / 2) +
                      (activeTab == NavTab.projects
                          ? projectsUnderlineOffset
                          : ideasUnderlineOffset);

                  return Stack(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _NavItem(
                              isActive: activeTab == NavTab.projects,
                              label: 'Projetos',
                              icon: Icons.edit,
                              onTap: () => onTabSelected(NavTab.projects),
                            ),
                          ),
                          Expanded(
                            child: _NavItem(
                              isActive: activeTab == NavTab.ideas,
                              label: 'Ideias',
                              icon: Icons.lightbulb_outline,
                              onTap: () => onTabSelected(NavTab.ideas),
                            ),
                          ),
                        ],
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        left: indicatorLeft,
                        bottom: 10,
                        child: IgnorePointer(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            height: 2.4,
                            width: indicatorWidth,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEB76AE),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEB76AE).withValues(alpha: 0.26),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final bool isActive;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _NavItem({
    required this.isActive,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isActive
        ? const Color(0xFF544959)
        : const Color(0xFF544959).withValues(alpha: 0.46);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      opacity: isActive ? 1.0 : 0.58,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          splashColor: const Color(0xFFEB76AE).withValues(alpha: 0.16),
          onTap: onTap,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    scale: isActive ? 1.0 : 0.96,
                    child: Icon(icon, color: foregroundColor, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
