import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import './buttons/botao_config.dart';
import './buttons/botao_voltar.dart';

class MainHeader extends StatelessWidget {
  final bool asSliver;
  final String title;
  final String? subtitle;
  final VoidCallback? onBackPressed;
  final VoidCallback? onConfigPressed;
  final double headerHeight;
  final double titleFontSize;
  final double titleLetterSpacing;
  final EdgeInsetsGeometry contentPadding;
  final double titleHorizontalPadding;
  final bool titleShadow;
  final bool surroundSubtitleWithDots;

  const MainHeader({
    super.key,
    this.asSliver = true,
    this.title = 'WIREFRAME',
    this.subtitle,
    this.onBackPressed,
    this.onConfigPressed,
    this.headerHeight = 106,
    this.titleFontSize = 33,
    this.titleLetterSpacing = 3.6,
    this.contentPadding = const EdgeInsets.fromLTRB(14, 16, 14, 18),
    this.titleHorizontalPadding = 0,
    this.titleShadow = false,
    this.surroundSubtitleWithDots = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!asSliver) {
      return SizedBox(
        height: headerHeight,
        child: _HeaderContent(
          title: title,
          subtitle: subtitle,
          onBackPressed: onBackPressed,
          onConfigPressed: onConfigPressed,
          titleFontSize: titleFontSize,
          titleLetterSpacing: titleLetterSpacing,
          contentPadding: contentPadding,
          titleHorizontalPadding: titleHorizontalPadding,
          titleShadow: titleShadow,
          surroundSubtitleWithDots: surroundSubtitleWithDots,
        ),
      );
    }

    return SliverAppBar(
      expandedHeight: headerHeight,
      toolbarHeight: headerHeight,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: _HeaderContent(
          title: title,
          subtitle: subtitle,
          onBackPressed: onBackPressed,
          onConfigPressed: onConfigPressed,
          titleFontSize: titleFontSize,
          titleLetterSpacing: titleLetterSpacing,
          contentPadding: contentPadding,
          titleHorizontalPadding: titleHorizontalPadding,
          titleShadow: titleShadow,
          surroundSubtitleWithDots: surroundSubtitleWithDots,
        ),
      ),
    );
  }
}

class _HeaderContent extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBackPressed;
  final VoidCallback? onConfigPressed;
  final double titleFontSize;
  final double titleLetterSpacing;
  final EdgeInsetsGeometry contentPadding;
  final double titleHorizontalPadding;
  final bool titleShadow;
  final bool surroundSubtitleWithDots;

  const _HeaderContent({
    required this.title,
    required this.subtitle,
    required this.onBackPressed,
    required this.onConfigPressed,
    required this.titleFontSize,
    required this.titleLetterSpacing,
    required this.contentPadding,
    required this.titleHorizontalPadding,
    required this.titleShadow,
    required this.surroundSubtitleWithDots,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    final effectiveSubtitle = hasSubtitle
        ? (surroundSubtitleWithDots ? '...${subtitle!}...' : subtitle!)
        : '';
    final titleStyle = GoogleFonts.ralewayDots(
      color: const Color(0xFFF8EFF5),
      fontSize: titleFontSize,
      fontWeight: FontWeight.w400,
      letterSpacing: titleLetterSpacing,
      height: 1,
      shadows: titleShadow
          ? [
              Shadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 1.5),
              ),
            ]
          : null,
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
              padding: contentPadding,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: BotaoVoltar(onPressed: onBackPressed),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: BotaoConfig(onPressed: onConfigPressed),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: titleHorizontalPadding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              title.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: titleStyle,
                            ),
                          ),
                          if (hasSubtitle) ...[
                            const SizedBox(height: 6),
                            Text(
                              effectiveSubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFFF7EEF4).withValues(alpha: 0.9),
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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
