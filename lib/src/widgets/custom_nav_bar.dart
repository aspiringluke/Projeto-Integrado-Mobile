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
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFD4C8CD),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                isActive: activeTab == NavTab.projects,
                label: "Projetos",
                icon: Icons.edit,
                onTap: () => onTabSelected(NavTab.projects),
              ),
            ),
            Expanded(
              child: _NavItem(
                isActive: activeTab == NavTab.ideas,
                label: "Ideias",
                icon: Icons.lightbulb_outline,
                onTap: () => onTabSelected(NavTab.ideas),
              ),
            ),
          ],
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
    final color = isActive ? Colors.white : Colors.black54;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFF9E8A98), Color(0xFFD97EB6)],
                  )
                : null,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
