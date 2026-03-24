import 'package:flutter/material.dart';
import './buttons/botao_voltar.dart';
import './buttons/botao_config.dart';

class MainHeader extends StatelessWidget {
  final bool asSliver;

  const MainHeader({super.key, this.asSliver = true});

  @override
  Widget build(BuildContext context) {
    if (!asSliver) {
      return const SizedBox(
        height: 120,
        child: _HeaderContent(),
      );
    }

    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: const _HeaderContent(),
      ),
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF8B7D8B),
            Color(0xFFDF6EB8),
          ],
        ),
      ),
      child: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BotaoVoltar(),
              Text(
                "WIREFRAME",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 8.0,
                ),
              ),
              BotaoConfig(),
            ],
          ),
        ),
      ),
    );
  }
}
