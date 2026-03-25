import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import './buttons/botao_config.dart';
import './buttons/botao_voltar.dart';

class MainHeader extends StatelessWidget {
  final bool asSliver;

  const MainHeader({super.key, this.asSliver = true});

  @override
  Widget build(BuildContext context) {
    if (!asSliver) {
      return const SizedBox(
        height: 106,
        child: _HeaderContent(),
      );
    }

    return const SliverAppBar(
      expandedHeight: 106,
      toolbarHeight: 106,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: _HeaderContent(),
      ),
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent();

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.ralewayDots(
      color: const Color(0xFFF8EFF5),
      fontSize: 33,
      fontWeight: FontWeight.w400,
      letterSpacing: 3.6,
      height: 1,
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF726876),
            Color(0xFFB083AA),
            Color(0xFFDF6EB8),
          ],
          stops: [0, 0.56, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: -56,
            top: -34,
            child: IgnorePointer(
              child: _HeaderGlow(
                size: 170,
                colors: [
                  const Color(0x26FFFFFF),
                  const Color(0x00FFFFFF),
                ],
              ),
            ),
          ),
          Positioned(
            right: -26,
            top: -44,
            child: IgnorePointer(
              child: _HeaderGlow(
                size: 190,
                colors: [
                  const Color(0x34F7C6E2),
                  const Color(0x00F7C6E2),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned(
                    left: 0,
                    child: BotaoVoltar(),
                  ),
                  Text(
                    'WIREFRAME',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: titleStyle,
                  ),
                  const Positioned(
                    right: 0,
                    child: BotaoConfig(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderGlow extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _HeaderGlow({
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
