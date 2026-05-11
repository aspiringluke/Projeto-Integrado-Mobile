import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class FuncoesBusca extends StatelessWidget {
  const FuncoesBusca({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: 46,
          padding: const EdgeInsets.fromLTRB(14, 5, 14, 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFFFFFFF).withValues(alpha: 0.72),
                const Color(0xFFF3F0F3).withValues(alpha: 0.62),
              ],
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.52)),
              bottom: BorderSide(color: Colors.black.withValues(alpha: 0.045)),
            ),
          ),
          child: Row(
            children: [
              const _ActionIcon(icon: Icons.filter_alt_outlined),
              const SizedBox(width: 10),
              const _ActionIcon(icon: Icons.swap_vert_rounded),
              const SizedBox(width: 10),
              const _ActionIcon(icon: Icons.auto_awesome_outlined),
              const SizedBox(width: 14),
              const Expanded(child: _SearchField()),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  static const List<double> _desaturateMatrix = <double>[
    0.65,
    0.25,
    0.10,
    0,
    0,
    0.20,
    0.65,
    0.15,
    0,
    0,
    0.16,
    0.24,
    0.60,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(_desaturateMatrix),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7D7DC).withValues(alpha: 0.18),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF9F9FB).withValues(alpha: 0.54),
                        const Color(0xFFE2E2E7).withValues(alpha: 0.38),
                        const Color(0xFFFFFFFF).withValues(alpha: 0.22),
                      ],
                      stops: const [0, 0.46, 1],
                    ),
                  ),
                ),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  transform: GradientRotation(-math.pi / 5.9),
                  colors: [
                    const Color(0x00FFFFFF),
                    const Color(0x92A9AAB2),
                    const Color(0x45D0D1D7),
                    const Color(0x00FFFFFF),
                  ],
                  stops: const [0.04, 0.24, 0.43, 0.7],
                ),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.34),
                    Colors.white.withValues(alpha: 0.04),
                    Colors.white.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.34, 1],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.86),
                  width: 1.15,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          TextField(
            cursorColor: const Color(0xFF6E6870),
            decoration: InputDecoration(
              hintText: '',
              isDense: true,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 42,
                minHeight: 34,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.search_rounded,
                  color: Colors.black.withValues(alpha: 0.9),
                  size: 29,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;

  const _ActionIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      radius: 20,
      onTap: () {},
      child: SizedBox(
        width: 30,
        height: 30,
        child: Center(
          child: Icon(icon, color: const Color(0xFF151419), size: 28),
        ),
      ),
    );
  }
}
