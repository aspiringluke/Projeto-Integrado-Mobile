import 'package:flutter/material.dart';
import '../widgets/custom_nav_bar.dart';
import '../widgets/funcoes_busca.dart';
import '../widgets/glass_circle_button.dart';
import '../widgets/main_header.dart';
import '../widgets/project_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      bottomNavigationBar: CustomNavBar(
        activeTab: NavTab.projects,
        onTabSelected: (_) {},
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
      body: CustomScrollView(
        slivers: [
          const MainHeader(),
          const SliverToBoxAdapter(
            child: FuncoesBusca(),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ProjectCard(title: 'Projeto ${index + 1}');
                },
                childCount: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
