import 'package:flutter/material.dart';
import '../widgets/funcoes_busca.dart';
import '../widgets/main_header.dart';
import '../widgets/custom_nav_bar.dart'; 
import '../widgets/project_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      bottomNavigationBar: CustomNavBar(activeTab: NavTab.projects, onTabSelected: (_) {}),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFF4B8D8),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.black87),
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
                  return ProjectCard(title: "Projeto ${index + 1}");
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
