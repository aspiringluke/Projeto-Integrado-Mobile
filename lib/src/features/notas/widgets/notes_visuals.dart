import 'dart:ui';

import 'package:flutter/material.dart';

const Color kNotesPink = Color(0xFFDF6EB8);
const Color kNotesPlum = Color(0xFF544959);
const Color kNotesInk = Color(0xFF1F1C24);
const Color kNotesSurface = Color(0xF2FFFFFF);
const Color kNotesSurfaceSoft = Color(0xD9FFFFFF);
const Color kNotesText = Color(0xFF342F33);
const Color kNotesMutedText = Color(0xFF7C7279);
const Color kNotesStroke = Color(0xC9FFFFFF);
const Color kNotesGlow = Color(0x26DF6EB8);

LinearGradient notesSurfaceGradient({
  Color? accentColor,
  bool elevated = false,
}) {
  final accent = accentColor ?? kNotesPink;

  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: elevated ? 0.94 : 0.88),
      Color.alphaBlend(
        accent.withValues(alpha: elevated ? 0.09 : 0.05),
        Colors.white,
      ),
      const Color(0xFFF5EFF3).withValues(alpha: elevated ? 0.9 : 0.84),
    ],
    stops: const [0.0, 0.52, 1.0],
  );
}

BoxDecoration notesGlassDecoration({
  Color? accentColor,
  bool elevated = false,
  double radius = 18,
  List<BoxShadow>? shadows,
}) {
  final accent = accentColor ?? kNotesPink;

  return BoxDecoration(
    gradient: notesSurfaceGradient(accentColor: accent, elevated: elevated),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: Colors.white.withValues(alpha: elevated ? 0.9 : 0.8),
      width: 0.85,
    ),
    boxShadow:
        shadows ??
        [
          BoxShadow(
            color: accent.withValues(alpha: elevated ? 0.1 : 0.07),
            blurRadius: elevated ? 12 : 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: elevated ? 10 : 8,
            offset: const Offset(0, 3),
          ),
        ],
  );
}

BoxDecoration notesGlowDecoration({
  Color glowColor = kNotesGlow,
  double radius = 18,
}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [BoxShadow(color: glowColor, blurRadius: 22, spreadRadius: 2)],
  );
}

InputDecoration notesInputDecoration({
  required String labelText,
  String? hintText,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: prefixIcon,
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.86),
    labelStyle: const TextStyle(
      color: kNotesMutedText,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: TextStyle(color: kNotesMutedText.withValues(alpha: 0.7)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.92)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: Colors.white.withValues(alpha: 0.84),
        width: 0.9,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: kNotesPink, width: 1.2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
  );
}

class NotesGlassCard extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? accentColor;
  final bool elevated;
  final double blurSigma;
  final List<BoxShadow>? boxShadow;

  const NotesGlassCard({
    super.key,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.accentColor,
    this.elevated = false,
    this.blurSigma = 8,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: notesGlassDecoration(
              accentColor: accentColor,
              elevated: elevated,
              radius: radius,
              shadows: boxShadow,
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.16),
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.28, 0.58, 1.0],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class NotesActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? tint;

  const NotesActionPill({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final color = tint ?? kNotesPink;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.96)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.14),
                    blurRadius: 14,
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
